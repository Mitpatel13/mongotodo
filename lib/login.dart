import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongotodo/homepage.dart';
import 'package:mongotodo/signup.dart';

import 'api.dart';

class LoginCtr extends GetxController {
  RxBool login = false.obs;
}

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final c = Get.put(LoginCtr());

  void _handleLogin() async {
    c.login.value = true;
    final email = emailController.text;
    final password = passwordController.text;

    final db = await Db.create(baseURL);
    await db.open();
    final usersCollection = db.collection(collactionName);

    final user = await usersCollection.findOne(where.eq('email', email));
    print(user);
    if (user != null && user['password'] == password) {
      // Successful login
      print('Login successful');
      c.login.value = false;
      Get.offAll(DashboardPage());
    } else {
      Get.snackbar("Please signup", "");

      c.login.value = false;
      // Failed login
      print('Login failed');
    }

    await db.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email')),
            TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password')),
            SizedBox(height: 16),
            Obx(() {
              return c.login.value == false
                  ? ElevatedButton(
                      onPressed: _handleLogin, child: Text('Login'))
                  : CircularProgressIndicator();
            }),
            InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignupPage(),
                      ));
                },
                child: RichText(
                    text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        children:<TextSpan>[ TextSpan(text: "Signup",style: TextStyle(color: Colors.deepPurple))],

                        text: "If you have no acoount please "))),
          ],
        ),
      ),
    );
  }
}
