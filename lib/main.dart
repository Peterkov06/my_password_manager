import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'ServiceCard.dart';
import 'databaseBoxes.dart';
import 'loginScreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter('database');
   AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );
  final FlutterSecureStorage secureStorage = FlutterSecureStorage(aOptions: _getAndroidOptions());
  Hive.registerAdapter(ServiceCardAdapter());
  database = await Hive.openBox('');

  runApp(MyApp(secureStorage: secureStorage, hasLoginPass: await secureStorage.containsKey(key: 'loginPass'),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.secureStorage, required this.hasLoginPass});
  final FlutterSecureStorage secureStorage;
  final bool hasLoginPass;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: LoginScreen(secureStorage: secureStorage, hasPassword: hasLoginPass),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.secureStorage});
  final String title;
  final secureStorage;

  @override
  State<MyHomePage> createState() => _MyHomePageState(secureStorage);
}

class _MyHomePageState extends State<MyHomePage> {
  var currentNewService = TextEditingController();
  var currentNewUsername = TextEditingController();
  var currentNewPassword = TextEditingController();
  final FlutterSecureStorage secureStorage;

  _MyHomePageState(this.secureStorage);

  @override
  void deactivate() {
    database.close();
    super.deactivate();
  }

  @override
  void initState() {
    openBox();
    super.initState();
  }

  Future openBox()
  async {
    var containsEncryptionKey = await secureStorage.containsKey(key: 'encryptionKey');
    if (!containsEncryptionKey) {
      var key = Hive.generateSecureKey();
      await secureStorage.write(key: 'encryptionKey', value: base64UrlEncode(key));
    }
    final key = await secureStorage.read(key: 'encryptionKey');
    var encryptionKey = base64Url.decode(key.toString());
    database.close();
    database = await Hive.openBox<ServiceCard>('serviceCard', encryptionCipher: HiveAesCipher(encryptionKey));
    setState(() {});
  }

  void addCard(int newIndex, List<String> prev)
  {
    print(prev);
    setState(() { 
      database.put(newIndex, ServiceCard(serviceName: currentNewService.text, userName: currentNewUsername.text, currentPassword: currentNewPassword.text, previousPass: prev));
      currentNewPassword.clear();
      currentNewService.clear();
      currentNewUsername.clear();
    });
  }

  void deleteCard(int ind)
  {
    int cycle = database.length - 1;
    for (var i = ind; i < cycle; i++) {
      ServiceCard copyCard = database.get(i + 1);
      database.delete(i);
      database.put(i, copyCard);
    }
    database.delete(cycle);
    setState(() {
      
    });
  }

  void modifyCard(bool isModify, ServiceCard thisCard, int currIndex)
  {
    List<String> currPrevPass;
    late String titleTxt;
    if (isModify)
    {
      titleTxt = 'Modify service';
      currentNewService.text = thisCard.serviceName;
      currentNewPassword.text = thisCard.currentPassword;
      currentNewUsername.text = thisCard.userName;
      currPrevPass = thisCard.previousPass;
    }
    else
    {
      currPrevPass = [];
      titleTxt = 'Add new service';
    }

    showDialog(
            context: context, 
            builder: (context) => AlertDialog(
            title: Text(titleTxt),
            content: Form(
              child: 
              Column(
                children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [Flexible(
                      child: TextField(
                        controller: currentNewService,
                      decoration: const InputDecoration(hintText: 'Service name', border: OutlineInputBorder()),
                    ),
                    ),]
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [Flexible(
                      child: TextField(
                        controller: currentNewUsername,
                      decoration: const InputDecoration(hintText: 'Username', border: OutlineInputBorder()),
                    ),
                    ),]
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [Flexible(
                      child: TextField(
                        controller: currentNewPassword,
                      decoration: const InputDecoration(hintText: 'Password', border: OutlineInputBorder()),
                    ),
                    ),]
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [Flexible(
                      child: Center(
                        child: TextButton(
                          child: const Text('Generate password'),
                          onPressed: () {
                            const String letters_lower = 'abcdefghijklmnopqrstuvwxyz';
                            const String letters_Upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
                            const String numbers = '123456789';
                            const String specials = "~`!@#\$%^&*()_-+={[}]|\\:;\"'<,>.?/";
                            int length = Random().nextInt(3) + 15;
                            String genPass = '';
                            for (var i = 0; i < length; i++) {
                              int type = Random().nextInt(3);
                              switch (type) {
                                case 0:
                                  int loUp = Random().nextInt(2);
                                  switch (loUp)
                                  {
                                    case 0:
                                      genPass += letters_lower[Random().nextInt(letters_lower.length)];
                                      break;
                                    case 1:
                                      genPass += letters_Upper[Random().nextInt(letters_Upper.length)];
                                      break;
                                  }
                                  break;
                                case 1:
                                  genPass += numbers[Random().nextInt(numbers.length)];
                                  break;
                                case 2:
                                  genPass += specials[Random().nextInt(specials.length)];
                                  break;
                              }
                            }
                            currentNewPassword.text = genPass;
                            setState(() {  });
                          },
                          ),
                      )
                    ),]
                  ),
                ),

                if (isModify && thisCard.previousPass.isNotEmpty)
                  Expanded(
                    child: SizedBox(
                      width: double.maxFinite,
                      height: double.maxFinite,
                      child: ListView.builder(
                        itemCount: thisCard.previousPass.length,
                        itemBuilder: (context, index) {
                        return ListTile(title: Text(currPrevPass[index]),);
                      },),
                    ),
                  )

            ],)),
            actions: [
              ElevatedButton(onPressed: () { 
                Navigator.pop(context, true); 
                int putInd;

                if (isModify)
                {
                  putInd = currIndex;
                  if (thisCard.currentPassword != currentNewPassword.text)
                  {
                    currPrevPass.add(thisCard.currentPassword);
                  }
                }
                else
                {
                  putInd = database.length;
                }
                addCard(putInd, currPrevPass.toList());
                }, 
                child: const Text('Save'),)
            ],
    )).then((value) {currentNewPassword.clear(); currentNewService.clear(); currentNewUsername.clear(); currPrevPass.clear();} )
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: database.length,
        itemBuilder: (context, index) {
          return CardWidget(index: index, parentDeleteCard: deleteCard, modifyCard: modifyCard,);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          modifyCard(false, ServiceCard(serviceName: '', userName: '', currentPassword: '', previousPass: []), 0);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
  }
}

class CardWidget extends StatefulWidget {
  const CardWidget({
    super.key,
    required this.index, required this.parentDeleteCard, required this.modifyCard
  });
  final int index;
  final Function parentDeleteCard;
  final Function modifyCard;

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  bool isVisible = false;
  final thisPassword = TextEditingController();
  late ServiceCard currCard;

    @override
  void didUpdateWidget(covariant CardWidget oldWidget) {
    currCard = database.get(widget.index);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    currCard = database.get(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      direction: Axis.horizontal,
      endActionPane: ActionPane(
        motion: const ScrollMotion(), 
        children:[ SlidableAction(
          onPressed: (context) {
            widget.parentDeleteCard(widget.index);
          },
          backgroundColor: const Color(0xFFFE4A49),
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'Delete',
        ),]),
      child: Card(
      color: Colors.green,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currCard.serviceName, textScaleFactor: 1.5, textAlign: TextAlign.left,),
                      Text(currCard.userName, textScaleFactor: 1.1, textAlign: TextAlign.left,),
                    ],
                  ),
                ),
                TextButton(onPressed: () {
                    widget.modifyCard(true, currCard, widget.index);
                  }, 
                  child: const Icon(Icons.edit, )),
              ],
            ),
             Row(
            children: [
              Flexible(
                child: TextField(
                  readOnly: true,
                  obscureText: !isVisible,
                  controller: TextEditingController(text: currCard.currentPassword),
                decoration: const InputDecoration(hintText: 'Pass', border: OutlineInputBorder()),
              ),
              ),
              TextButton(
                onPressed: () {
                  isVisible = !isVisible; 
                  setState(() {
                });},
                child: const Icon(Icons.remove_red_eye),
                ),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: thisPassword.text));
                  const snackBar = SnackBar(
                    content: Text('Copied password!'),
                    duration: Duration(seconds: 1),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                child: const Icon(Icons.copy),
                ),
            ],
          ),
          ],
        ),
      ),
    ),
          );
     
  }
}