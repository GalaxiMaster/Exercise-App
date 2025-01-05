
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
          infoBox('Password: ', '***********', Icons.edit, (){
            
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