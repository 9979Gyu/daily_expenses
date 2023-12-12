import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dailyexpenses.dart';

void main() {
  runApp(const MaterialApp(
    home: LoginScreen(),
  ));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController ipController = TextEditingController();

  _saveValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ipAddress', ipController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: 'https://w7.pngwing.com/pngs/978/821/'
                        'png-transparent-money-finance-wallet-payment-daily-'
                        'expenses-saving-service-personal-finance.png'
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: ipController,
                decoration: const InputDecoration(
                  labelText: 'IP Address',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  String username = usernameController.text;
                  String password = passwordController.text;

                  if(username == "1" && password == "1" ) {
                    // call function to set data in shared pref
                    try {
                      await _saveValue();
                    } catch (e) {
                      print("Error saving IP address: $e");
                    }

                    // Navigate to daily expense screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DailyExpensesApp(username: username),
                      ),
                    );
                  }
                  else{
                    //show error message or handle invalid login
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Login Failed'),
                          content: const Text('Invalid username or password.'),
                          actions: [
                            TextButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      }
                    );
                  }
                },
                child: const Text('Login')
            ),
          ],
        ),
      ),
    );
  }
}

