import 'package:exercise_app/Pages/home.dart';
import 'package:exercise_app/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, 'Sign In'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            spacing: 25,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.white38,
                      width: 2,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.white38,
                      width: 2,
                    ),
                  ),
                ),
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: () async {
                  // Input validation
                  if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all fields')),
                    );
                    return;
                  }

                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_usernameController.text)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid email')),
                    );
                    return;
                  }
                  try {
                    await _auth.signInWithEmailAndPassword(
                      email: _usernameController.text.trim(),
                      password: _passwordController.text,
                    );
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  } on FirebaseAuthException catch (e) {
                    String message;
                    switch (e.code) {
                      case 'user-not-found':
                        try {
                          await _auth.createUserWithEmailAndPassword(
                            email: _usernameController.text.trim(),
                            password: _passwordController.text,
                          );
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomePage()),
                          );
                          return;
                        } catch (e) {
                          message = 'Error creating account';
                        }
                        break;
                      case 'invalid-credential':
                        message = 'Invalid credential';
                        break;
                      case 'invalid-email':
                        message = 'Invalid email format';
                        break;
                      case 'user-disabled':
                        message = 'This account has been disabled';
                        break;
                      default:
                        message = 'An error occurred: ${e.message}';
                    }
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red[300],
                        content: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(
                        'An unexpected error occurred: $e',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    );
                  }                
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 100),
                  child: Text('Sign In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}