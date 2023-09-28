import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'ServiceCard.dart';
import 'databaseBoxes.dart';
import 'loginScreen.dart';

void main() async{
  await Hive.initFlutter();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  runApp(MyApp(secureStorage: secureStorage,));
  if (await secureStorage.containsKey(key: 'loginPass'))
  {
    var containsEncryptionKey = await secureStorage.containsKey(key: 'encryptionKey');
    if (!containsEncryptionKey) {
      var key = Hive.generateSecureKey();
      await secureStorage.write(key: 'encryptionKey', value: base64UrlEncode(key));
    }
    final key = await secureStorage.read(key: 'encryptionKey');
    var encryptionKey = base64Url.decode(key.toString());
    Hive.registerAdapter(ServiceCardAdapter());
    database = await Hive.openBox<ServiceCard>('serviceCard', encryptionCipher: HiveAesCipher(encryptionKey));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.secureStorage});
  final secureStorage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: /*MyHomePage(title: 'Password Manager')*/ LoginScreen(secureStorage: secureStorage,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var currentNewService = TextEditingController();
  var currentNewUsername = TextEditingController();
  var currentNewPassword = TextEditingController();

  addCard(int newIndex)
  {
      
    setState(() { 
      database.put(newIndex, ServiceCard(serviceName: currentNewService.text, userName: currentNewUsername.text, currentPassword: currentNewPassword.text));
      currentNewPassword.clear();
      currentNewService.clear();
      currentNewUsername.clear();
    });
  }

  deleteCard(int ind)
  {
    setState(() {database.deleteAt(ind);});
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
          return Slidable(
            direction: Axis.horizontal,
            endActionPane: ActionPane(
              motion: const ScrollMotion(), 
              children:[ SlidableAction(
                onPressed: (context) {deleteCard(index);},
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),]
      
      ),
            child: CardWidget(index: index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context, 
            builder: (context) => AlertDialog(
            title: const Text('Add new service'),
            content: Form(
              child: 
              Column(children: [
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
            ],)),
            actions: [
              ElevatedButton(onPressed: () { Navigator.pop(context, true); addCard(database.length);}, child: const Text('Save'),)
            ],
    ));

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
    required this.index,
  });
  final int index;

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  bool isVisible = false;
  final thisPassword = TextEditingController();
  late ServiceCard currCard;

  @override
  void initState() {
    currCard = database.getAt(widget.index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currCard.serviceName, textScaleFactor: 1.5, textAlign: TextAlign.left,),
            Text(currCard.userName, textScaleFactor: 1.1, textAlign: TextAlign.left,),
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
    );
  }
}

class AppCard extends StatefulWidget {
  const AppCard({super.key});

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  @override
  Widget build(BuildContext context) {
    return const Card(
      color: Colors.green,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(
              title: Text('App Pass'),
              subtitle: Text('Account'),
            ),
            Row(
              children: [
                Flexible(
                  child: TextField(
                  decoration: InputDecoration(hintText: 'Pass', border: OutlineInputBorder()),
                ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.remove_red_eye),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.copy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

