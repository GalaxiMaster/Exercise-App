
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, 'Account'),
      body: Column(
        children: [
          infoBox('Email: ', account.email, Icons.edit, (){

          }),
          infoBox('Password: ', '***********', Icons.edit, () async{
            String? result = await showDialog(
              context: context,
              builder: (BuildContext context) => ChangePasswordDialog(),
            );
            if (result != null) {
              await account.updatePassword(result);
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
                    Row(
                      spacing: 25,
                      children: [
                        Text(
                          key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          value ?? '',
                          style: const TextStyle(
                            color: Colors.white70, 
                            fontSize: 20,
                          ),
                        )
                      ],
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
      content: Column(
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
      actionsAlignment: MainAxisAlignment.center,
      actions: [  
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.black),
          ),
          onPressed: () {
            setState(() {
              if (newPassword.text.isEmpty) {
                error1 = 'Password cannot be empty';
              } else if (confirmNewPassword.text.isEmpty) {
                error2 = 'Password cannot be empty';
              } else if (newPassword.text != confirmNewPassword.text) {
                error1 = 'Passwords do not match';
                error2 = 'Passwords do not match';
              } else {
                error1 = null;
                Navigator.pop(context, newPassword.text); // Return the password or handle further.
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: const Text('Change'),
          ),
        ),
      ],
    );
  }
}
