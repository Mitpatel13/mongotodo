import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'api.dart';
import 'homepage.dart';


class SignUpCtr extends GetxController {
  RxBool signUp = false.obs;
}

class SignupPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final c = Get.put(SignUpCtr());

  void _handleSignup() async {
    c.signUp.value = true;
    final email = emailController.text;
    final password = passwordController.text;

    final db = await Db.create(baseURL);
    await db.open();
    final usersCollection = db.collection(collactionName);

    final existingUser = await usersCollection.findOne(
        where.eq('email', email));

    if (existingUser != null) {
       Get.snackbar("User already exist please login", "");
      // User already exists
      print('User already exists');
      c.signUp.value = false;
    } else {
      c.signUp.value = true;


      // Create a new user
      await usersCollection.insert({'email': email, 'password': password});
      c.signUp.value = false;

      await Get.offAll(DashboardPage());
      print('User registered successfully');
    }

    await db.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailController,
                decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController,
                decoration: InputDecoration(labelText: 'Password')),
            SizedBox(height: 16),
            Obx(() {
              return    c.signUp.value ==false?
              ElevatedButton(
                  onPressed: _handleSignup, child: Text('Sign Up')):CircularProgressIndicator();
            }),
          ],
        ),
      ),
    );
  }
}
