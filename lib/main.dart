import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path_provider/path_provider.dart';
import 'ServiceCard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Password Manager'),
    );
  }
}

class FileManager
{
  Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
  }

  Future<File> get _file async {
    final path = await _localPath;
    return File('$path/datas.txt');
  }

  Future<File> writeToFile(String data)
  async {
    final datasFile = await _file;
    return datasFile.writeAsString(data);
  }

  Future<String> readFile() async
  {
    final file = await _file;

    final readData = await file.readAsString();
    return(readData);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ServiceCard> dynamicCards = [];
  final currentNewService = TextEditingController();
  final currentNewUsername = TextEditingController();
  final currentNewPassword = TextEditingController();

  addCard()
  {

    dynamicCards.add(ServiceCard(currentPassword: currentNewPassword.text, serviceName: currentNewService.text, userName: currentNewUsername.text));
    currentNewPassword.clear();
    currentNewService.clear();
    currentNewUsername.clear();

    setState(() { });
  }

  deleteCard(int ind)
  {
    dynamicCards.removeAt(ind);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: dynamicCards.length,
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
            child: CardWidget(dynamicCards: dynamicCards, index: index,),
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
              ElevatedButton(onPressed: () { Navigator.pop(context, true); addCard();}, child: const Text('Save'),)
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
    required this.dynamicCards, this.index,
  });

  final List<ServiceCard> dynamicCards;
  final index;

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  bool isVisible = false;
  final thisPassword = TextEditingController();

  @override
  void initState() {
    thisPassword.text = widget.dynamicCards[widget.index].currentPassword;
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
            Text(widget.dynamicCards[widget.index].serviceName, textScaleFactor: 1.5, textAlign: TextAlign.left,),
            Text(widget.dynamicCards[widget.index].userName, textScaleFactor: 1.1, textAlign: TextAlign.left,),
             Row(
            children: [
              Flexible(
                child: TextField(
                  readOnly: true,
                  obscureText: !isVisible,
                  controller: thisPassword,
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

