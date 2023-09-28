import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_password_manager/main.dart';

class LoginScreen extends StatelessWidget {
   LoginScreen({super.key, required this.secureStorage});
  var loginPass = TextEditingController();
  final secureStorage;

  void login(BuildContext cont)
  {
    
    Navigator.push(cont, MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Password manager',)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Login', textScaleFactor: 2,),
            Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: TextField(controller: loginPass,)),
                TextButton(onPressed: () {
                  login(context);
                }, child: Text('Login'))
              ],
            )
        ]),
      ),
    );
  }
}