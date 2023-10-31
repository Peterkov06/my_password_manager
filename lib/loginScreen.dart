import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_password_manager/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.secureStorage, required this.hasPassword});
  final FlutterSecureStorage secureStorage;
  final bool hasPassword;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var loginPass = TextEditingController();
  var buttonName = '';
  late bool hasLoginPass;

  @override
  void initState() {
    hasLoginPass = widget.hasPassword;
    if (widget.hasPassword == true)
    {
      buttonName = 'Login';
    }
    else
    {
      buttonName = 'Register';
    }
    super.initState();
  }

  Future<void> login(BuildContext cont)
  async {
    bool isAllowed = false;
    if (hasLoginPass == false)
    {
      widget.secureStorage.write(key: 'loginPass', value: loginPass.text.hashCode.toString());
      isAllowed = true;
    }
    else
    {
      final pass = await widget.secureStorage.read(key: 'loginPass');
      final passHash = int.parse(pass.toString());
      if (passHash == loginPass.text.hashCode)
      {
        isAllowed = true;
      }
    }
    if(isAllowed == true && mounted)
    {
      toHomePage(cont);
    }
    else if (!isAllowed && mounted)
    {
      showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: const Text('Incorrect password!', textAlign: TextAlign.center,),
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
    
  }

  void toHomePage(BuildContext cont)
  {
    Navigator.pushReplacement(cont, MaterialPageRoute(builder: (context) => MyHomePage(title: 'Password manager', secureStorage: widget.secureStorage,)));
  }


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 140, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text('Login', textScaleFactor: 2),
            Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: TextField(controller: loginPass, style: Theme.of(context).textTheme.displaySmall, obscureText: true,)),
                TextButton(onPressed: () {
                  login(context);
                }, child: Text(buttonName))
              ],
            )
        ]),
      ),
    );
  }
}