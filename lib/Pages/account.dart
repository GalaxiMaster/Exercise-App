
import 'dart:async';

import 'package:exercise_app/Pages/sign_in.dart';
import 'package:exercise_app/encryption_controller.dart';
import 'package:exercise_app/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  final User accountDetails;
  const AccountPage({super.key, required this.accountDetails});
  @override
  // ignore: library_private_types_in_public_api
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late User account;

  
  @override
  initState(){
    account = widget.accountDetails;
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, 'Account'),
      body: Column(
        children: [
          infoBox('Email: ', account.email, Icons.edit, () async {
            try {
              String? newEmail = await showDialog(
                context: context,
                builder: (BuildContext context) => ChangeEmailDialog(),
              );

              if (newEmail != null) {
                // If we got here, the email update was successful

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Verification email sent. Please check your email to complete the change.'),
                    duration: Duration(seconds: 5),
                  ),
                );

              }
            } catch (e) {
              // This should rarely happen since errors are handled in the dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('An unexpected error occurred: $e')),
              );
            }
          }),
          infoBox('Password: ', '***********', Icons.edit, () async{
            try{
              String? newPass = await showDialog(
                context: context,
                builder: (BuildContext context) => ChangePasswordDialog(),
              );
              await reAuthUser(account);

              if (newPass != null) {
                await account.updatePassword(newPass);
                writeToSecureStorage('password', newPass);
              }
            } catch(e){
              ScaffoldMessenger.of(context).showSnackBar(
                errorSnackBar(e),
              );
            }
          }),
          GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Icon(
                    Icons.power_settings_new, 
                    color: Colors.red,
                    size: 32.5,
                  ),
                  Text(
                    'Sign out', 
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget infoBox(String key, String? value, IconData icon, Function function) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Text(
                        key,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          value ?? '',
                          style: const TextStyle(
                            color: Colors.white70, 
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => function(),
                  child: Icon(icon),
                )
              ],
            ),
          ),
          const Divider(color: Colors.white70,),
        ],
      ),
    );
  }
}

Future<void> reAuthUser(account, {String? email}) async {
  try {
    String? oldPass = await readFromSecureStorage('password');
    if (account.email == null) throw 'Somehow your account doesnt have an email';
    if (oldPass == null) throw 'Failed to fetch auth details';
    
    String decryptedPass = decrypt(oldPass); // Add error handling here
    AuthCredential credential = EmailAuthProvider.credential(
      email: email ?? account.email ?? '', 
      password: decryptedPass
    );
    await account.reauthenticateWithCredential(credential);
  } catch (e) {
    throw 'Failed to authenticate: ${e.toString()}';
  }
}
class ChangeEmailDialog extends StatefulWidget {
  const ChangeEmailDialog({super.key});

  @override
  _ChangeEmailDialogState createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<ChangeEmailDialog> {
  final TextEditingController newEmail = TextEditingController();
  String? error;
  bool isLoading = false;
  
  @override
  void dispose() {
    newEmail.dispose();
    super.dispose();
  }

  Future<void> updateEmail() async {
    // First check email format
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(newEmail.text)) {
      setState(() {
        error = 'Invalid email format';
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Get the current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          error = 'No user signed in';
          isLoading = false;
        });
        return;
      }
      reAuthUser(user);
      await user.verifyBeforeUpdateEmail(newEmail.text);
      Navigator.pop(context, newEmail.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            error = 'This email is already in use';
            break;
          case 'invalid-email':
            error = 'Invalid email format';
            break;
          case 'requires-recent-login':
            error = 'Please sign in again to change email';
            break;
          default:
            error = 'Error updating email';
        }
      });
    } catch (e) {
      setState(() {
        error = 'An unexpected error occurred';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Email'),
      content: SizedBox(
        width: double.maxFinite,
        child: TextField(
          controller: newEmail,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: 'New Email',
            labelStyle: const TextStyle(fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            errorText: error,
            suffixIcon: isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : null,
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [  
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
          ),
          onPressed: isLoading ? null : updateEmail,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Change'),
          ),
        ),
      ],
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmNewPassword = TextEditingController();
  Set error1Set = {};
  String? error1;
  Set error2Set = {};
  String? error2;

  @override
  void dispose() {
    newPassword.dispose();
    confirmNewPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: const TextStyle(fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                errorText: error1,
              ),
              onChanged: (value) => setState((){
                if (value.length < 6){
                  error1Set.add('Password must be at least 6 characters');
                } else{
                  error1Set.remove('Password must be at least 6 characters');
                }
                if (!value.contains(RegExp(r'.*\d.*'))) {
                  error1Set.add('Password must contain a number');
                } else{
                  error1Set.remove('Password must contain a number');
                }
                if (error1Set.isNotEmpty){
                  error1 = error1Set.join('\n');
                } else{
                  error1 = null;
                }
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmNewPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: const TextStyle(fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                errorText: error2,
              ),
              onChanged: (value) => setState((){
                if (value.length < 6){
                  error2Set.add('Password must be at least 6 characters');
                } else{
                  error2Set.remove('Password must be at least 6 characters');
                }
                if (!value.contains(RegExp(r'.*\d.*'))) {
                  error2Set.add('Password must contain a number');
                } else{
                  error2Set.remove('Password must contain a number');
                }
                if (error2Set.isNotEmpty){
                  error2 = error2Set.join('\n');
                } else{
                  error2 = null;
                }
              }),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [  
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.black),
          ),
          onPressed: () {
            setState(() {
              if (error1 != null || error2 != null) {
                return;
              }
              else if (newPassword.text.isEmpty) {
                error1Set.add('Password cannot be empty');
              } else if (confirmNewPassword.text.isEmpty) {
                error2Set.add('Password cannot be empty');
              } else if (newPassword.text != confirmNewPassword.text) {
                error1 = 'Passwords do not match';
                error2 = 'Passwords do not match';
              } else {
                error1 = null;
                Navigator.pop(context, newPassword.text); // Return the password or handle further.
              }
            });
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 60),
            child: Text('Change'),
          ),
        ),
      ],
    );
  }
}
