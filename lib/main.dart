import 'package:flutter/material.dart';
import 'ServiceCard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Password Manager'),
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
  List<ServiceCard> dynamicCards = [];

  addCard()
  {
    dynamicCards.add(new ServiceCard(currentPassword: 'jani', serviceName: 'youtube', userName: 'none'));

    setState(() { });
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
          return Card(
            color: Colors.green,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text(dynamicCards[index].serviceName),
                    subtitle: Text(dynamicCards[index].userName),
                  ),
                  const Row(
                  children: [
                    Flexible(
                      child: TextField(
                      decoration: InputDecoration(hintText: 'Pass', border: OutlineInputBorder()),
                    ),
                    ),
                    TextButton(
                      child: Icon(Icons.remove_red_eye),
                      onPressed: null,
                      ),
                    TextButton(
                      child: Icon(Icons.copy),
                      onPressed: null,
                      ),
                  ],
                ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addCard,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

