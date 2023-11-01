import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_password_manager/AppThemes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  runApp(MyApp(secureStorage: secureStorage, hasLoginPass: await secureStorage.containsKey(key: 'loginPass'), prefs: preferences,));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.secureStorage, required this.hasLoginPass, required this.prefs});
  final FlutterSecureStorage secureStorage;
  final SharedPreferences prefs;
  final bool hasLoginPass;
  final bool isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:(context) => ThemeProvider(prefs),
      builder: (context, child) {
        final themeProvider = Provider.of<ThemeProvider>(context);

        return MaterialApp(
        title: 'Password Manager',
        themeMode: themeProvider.themeMode,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        home: LoginScreen(secureStorage: secureStorage, hasPassword: hasLoginPass),);
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.secureStorage});
  final String title;
  final FlutterSecureStorage secureStorage;

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

  void addCard(int newIndex, List<String> prev, bool clear)
  {
    setState(() { 
      database.put(newIndex, ServiceCard(serviceName: currentNewService.text, userName: currentNewUsername.text, currentPassword: currentNewPassword.text, previousPass: prev));
      if (clear)
      {
        currentNewPassword.clear();
        currentNewService.clear();
        currentNewUsername.clear();
      }
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

  void modifyCard(bool isModify, int currIndex)
  {
    late ServiceCard thisCard;
    List<String> currPrevPass;
    late String titleTxt;
    if (isModify)
    {
      thisCard = database.get(currIndex);
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
    String prevPass = currentNewPassword.text;

    showDialog(
            context: context, 
            builder: (context) { 
              return StatefulBuilder(
              builder: (context, setState) {   
              return AlertDialog(
              title: Text(titleTxt),
              content: Form(
                child: 
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [Flexible(
                        child: TextField(
                          controller: currentNewService,
                        decoration: const InputDecoration(label: Text('Service name'), border: OutlineInputBorder()),
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
                        decoration: const InputDecoration(label: Text('Username'), border: OutlineInputBorder()),
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
                          autocorrect: false,
                          keyboardType: TextInputType.visiblePassword,
                          controller: currentNewPassword,
                        decoration: const InputDecoration(label: Text('Password'), border: OutlineInputBorder()),
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
                          child: ElevatedButton(
                            child: const Text('Generate password'),
                            onPressed: () {
                              const String specials = "~`!@#\$%^&*()_-+={[}]|\\:;\"'<,>.?/";
                              int length = Random().nextInt(3) + 15;
                              String genPass = '';
                              for (var i = 0; i < length; i++) {
                                int type = 0;
                                if (i == 0)
                                {
                                  type = Random().nextInt(2);
                                }
                                else 
                                {
                                  type = Random().nextInt(3);
                                }
                                switch (type) {
                                  case 0:
                                    int loUp = Random().nextInt(2);
                                    switch (loUp)
                                    {
                                      case 0:
                                        genPass += String.fromCharCode(Random().nextInt(26) + 97);
                                        break;
                                      case 1:
                                        genPass += String.fromCharCode(Random().nextInt(26) + 65);
                                        break;
                                    }
                                    break;
                                  case 1:
                                    genPass += String.fromCharCode(Random().nextInt(10) + 48);
                                    break;
                                  case 2:
                                    genPass += specials[Random().nextInt(specials.length)];
                                    break;
                                }
                              }
                              currentNewPassword.text = genPass;
                            },
                            ),
                        )
                      ),]
                    ),
                  ),
                  if (isModify)
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Previous password(s):', style: TextStyle(fontSize: 18, color: Colors.black),),
                      ),
                    ),
            
                  if (isModify && currPrevPass.isNotEmpty)
                    Expanded(
                      child: SizedBox(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        child: ListView.builder(
                          itemCount: currPrevPass.length,
                          itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Flex(
                              direction: Axis.horizontal,
                              children: [
                                Flexible(
                                  child: TextField(
                                  readOnly: true,
                                  controller: TextEditingController(text: currPrevPass[(currPrevPass.length - 1) - index]),
                                  decoration: const InputDecoration(hintText: 'Username', border: OutlineInputBorder()),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: currPrevPass[(currPrevPass.length - 1) - index]));
                                    const snackBar = SnackBar(
                                      content: Text('Copied password!'),
                                      duration: Duration(seconds: 1),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    },
                                  child: const Icon(Icons.copy),
                                ),
                                TextButton(
                                  onPressed: () {
                                      showDialog(context: context, builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Delete previous password?'),
                                          content: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(onPressed: () {
                                                Navigator.pop(context);
                                              }, child: const Text('Back')),
                                              ElevatedButton(onPressed: () {
                                                setState(() {
                                                  currPrevPass.removeAt((currPrevPass.length - 1) -index);
                                                  addCard(currIndex, currPrevPass.toList(), !isModify);
                                                  Navigator.pop(context);
                                                });
                                              }, child: const Text('Delete')),
                                            ],
                                          ),
                                        );
                                      },);
                                    },
                                  child: const Icon(Icons.delete),
                                ),
                              ]
                            ),
                          );
                        },),
                      ),
                    )
            
              ],)),
              actions: [
                ElevatedButton(onPressed: () { 
                  if (!isModify)
                  {
                    Navigator.pop(context, true); 
                  }
                  int putInd;
            
                  if (isModify)
                  {
                    putInd = currIndex;
                    if (prevPass != currentNewPassword.text)
                    {
                      currPrevPass.add(prevPass);
                      prevPass = currentNewPassword.text;
                    }
                  }
                  else
                  {
                    putInd = database.length;
                  }
                  setState(() {
                    addCard(putInd, currPrevPass.toList(), !isModify);
                  },);
                  }, 
                  child: const Text('Save'),),
            
                ElevatedButton(onPressed: () { 
                  Navigator.pop(context, true); 
                  }, 
                  child: const Text('Exit'),)
              ],
              );}
            );}).then((value) {currentNewPassword.clear(); currentNewService.clear(); currentNewUsername.clear();} )
    ;
  }

  void changeMasterPass(TextEditingController prevCont, TextEditingController newCont, TextEditingController newAgainCont) async{    
    var currPass = await secureStorage.read(key: 'loginPass');
    if (int.parse(prevCont.text.hashCode.toString()) == int.parse(currPass.toString()))
    {
      if (newCont.text == newAgainCont.text && newCont.text != '' && newCont.text != prevCont.text)
      {
        secureStorage.write(key: 'loginPass', value: newCont.text.hashCode.toString());
        if (context.mounted)
        {
          showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: const Text('New password set!', textAlign: TextAlign.center,),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }, child: const Text('OK')),
              ],
            ),
          );
        },);
        }  
      }
      else if (mounted && newAgainCont.text != newCont.text)
      {
        showError('New passwords are not the same!');
      }
      else if (mounted && newCont.text == '')
      {
        showError('New password is not set!');
      }
      else if (mounted && newCont.text == prevCont.text)
      {
        showError('New password is same as before!');
      }
    }
    else
    {
      if (context.mounted)
      {
        showError('Current password incorrect!');
      }
    }
  }

  void showError(String message)
  {
    showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Text(message, textAlign: TextAlign.center,),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(onPressed: () {
                  Navigator.pop(context);
                }, child: const Text('Back')),
              ],
            ),
          );
        },);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title, style: Theme.of(context).textTheme.displayLarge,),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: MenuAnchor(builder: (context, controller, child) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(Icons.dehaze),
                tooltip: 'Show menu',
              );
            }, 
            menuChildren: [
              MenuItemButton(
                child: const Text('Change master password'), 
                onPressed: () {
                  var prevCont = TextEditingController();
                  var newCont = TextEditingController();
                  var newAgainCont = TextEditingController();

                  showDialog(context: context, builder: (context) {
                    return AlertDialog(
                      title: const Text('Change master password'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Flex(
                              direction: Axis.horizontal,
                              children: [Flexible(
                                child: TextField(
                                  controller: prevCont,
                                  autocorrect: false,
                                  obscureText: true,
                                decoration: const InputDecoration(label: Text('Current password'), border: OutlineInputBorder()),
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
                                  controller: newCont,
                                  autocorrect: false,
                                  obscureText: true,
                                decoration: const InputDecoration(label: Text('New password'), border: OutlineInputBorder()),
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
                                  controller: newAgainCont,
                                  autocorrect: false,
                                  obscureText: true,
                                decoration: const InputDecoration(label: Text('New password again'), border: OutlineInputBorder()),
                              ),
                              ),]
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(onPressed: () {
                                Navigator.pop(context);
                              }, child: const Text('Back')),
                              ElevatedButton(onPressed: () {
                                changeMasterPass(prevCont, newCont, newAgainCont);
                                setState(() {});
                              }, child: const Text('Save')),
                            ],
                          ),
                        ],
                      ),
                    );
                  },);
                },),
              SwitchListTile.adaptive(
                title: Text('Dark mode:', style: Theme.of(context).textTheme.displayMedium,),
                value: themeProvider.isDarkMode, 
                onChanged: (value) {
                  final provider = Provider.of<ThemeProvider>(context, listen: false);
                  provider.toggleTheme(value);

                },
              )
            ],),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: database.length,
        itemBuilder: (context, index) {
          return CardWidget(index: index, parentDeleteCard: deleteCard, modifyCard: modifyCard,);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          modifyCard(false, 0);
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
                      Text(currCard.serviceName, textScaleFactor: 1.5, textAlign: TextAlign.left, style: Theme.of(context).textTheme.displayMedium,),
                      Text(currCard.userName, textScaleFactor: 1.1, textAlign: TextAlign.left, style: Theme.of(context).textTheme.displayMedium,),
                    ],
                  ),
                ),
                TextButton(onPressed: () {
                    widget.modifyCard(true, widget.index);
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
                child: const Icon(Icons.copy,),
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