import 'dart:async';
import 'package:exercise_app/Functions/account_functions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:exercise_app/Pages/Account/sign_in.dart';
import 'package:exercise_app/Functions/encryption_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends ConsumerState<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EncryptionService _encryptionService = EncryptionService.instance;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSub;

  @override
  initState() {
    super.initState();
    GoogleSignIn.instance
        .initialize(
      serverClientId: dotenv.get('serverClientId'),
    ).then((_) {
      _authSub = GoogleSignIn.instance.authenticationEvents.listen(
        (event) async {
          final ok = await googleSignIn(event, ref, _encryptionService);
          if (ok && mounted) {
            Navigator.of(context).popUntil((r) => r.isFirst);
          }
        },
        onError: (e) => debugPrint('Authentication event error: $e'),
      );
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            spacing: 25,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AutofillGroup(
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.white38,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    TextField(
                      controller: _passwordController,
                      autofillHints: const [AutofillHints.password],
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
                  ]
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final ok = await emailPassSignIn(
                            auth: _auth,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            encryptionService: _encryptionService,
                            ref: ref
                          );
                          if (ok && context.mounted) {
                            Navigator.of(context).popUntil((r) => r.isFirst);
                          }
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                      },
                      child: Text(
                        'Already have an account? Sign In',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white24)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white24)),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            await GoogleSignIn.instance.initialize(
                              serverClientId: dotenv.get('serverClientId'),
                            );
                            await GoogleSignIn.instance.authenticate();
                          } on GoogleSignInException catch (e) {
                            debugPrint(
                                'Error signing in with Google: ${e.code} ${e.description}');
                          } catch (e, st) {
                            debugPrint('Unexpected error signing in with Google: $e');
                            debugPrint('$st');
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.white38, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Image.asset(
                          'assets/google_logo.png',
                          height: 20,
                          width: 20,
                        ),
                        label: const Text(
                          'Sign Up with Google',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  SnackBar errorSnackBar(String text) =>  SnackBar(
    backgroundColor: const Color.fromRGBO(21, 21, 21, 1),
    content: Text(
      text,
      style: const TextStyle(
        color: Colors.red,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    )
  );
}