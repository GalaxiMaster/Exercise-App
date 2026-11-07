import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise_app/Functions/Cloud/sync_controller.dart';
import 'package:exercise_app/Functions/encryption_controller.dart';
import 'package:exercise_app/Pages/Account/username_popup.dart';
import 'package:exercise_app/Functions/Cloud/social_services.dart';
import 'package:exercise_app/main.dart';
import 'package:exercise_app/utils.dart';
import 'package:exercise_app/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<bool> googleSignIn(
  GoogleSignInAuthenticationEvent event,
  WidgetRef ref,
  EncryptionService encryptionService,
) async {
  if (event is! GoogleSignInAuthenticationEventSignIn) return false;

  try {
    final auth = event.user.authentication;
    final credential = GoogleAuthProvider.credential(idToken: auth.idToken);

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    await encryptionService.writeToSecureStorage(
      key: 'authIdToken',
      value: encryptionService.encrypt(auth.idToken ?? ''),
    );

    bool isNew = userCredential.additionalUserInfo?.isNewUser ?? false;
    if (isNew) {
      // TODO createDefaultPermissions(userCredential); // do something?
    }

    await handleCloudData(ref);

    return true;
  } catch (e, st) {
    showSnackBar(errorSnackBar('Error handling authentication event: $e'));
    debugPrint('$e\n$st');
    return false;
  }
}

Future<void> handleCloudData(WidgetRef ref) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final social = SocialService(); // temporarily thrown this in here
    final profile = await social.getProfile(user.uid);
    if (profile == null) {
      final BuildContext? ctx = navigatorKey.currentContext;
      if (ctx == null && !ctx!.mounted) return; // todo make safer because this sucks
      String? username = await showUsernameDialog(ctx, required: true);
      if (username == null) return;
      await social.setUsernameAndProfile(username, photoUrl: user.photoURL);
    }

    final exists = (await FirebaseFirestore.instance
      .collection('User Data')
      .doc(user.uid)
      .get())
    .exists;

    final syncProvider = ref.read(syncServiceProvider);
    exists ? await syncProvider.restoreDataFromCloud(ref) : await syncProvider.syncAllData();
  }
}

Future<bool> emailPassSignIn({
  required TextEditingController emailController, 
  required TextEditingController passwordController, 
  required EncryptionService encryptionService, 
  required WidgetRef ref, 
  required FirebaseAuth auth,
  bool createAccount = false
}) async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      showSnackBar(errorSnackBar('Please fill in all fields'));
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
      showSnackBar(errorSnackBar('Invalid email format'));
      return false;
    }
    try {
      if (createAccount) {
        await auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
      } else {
        await auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
      }

      await handleCloudData(ref);
      
      encryptionService.writeToSecureStorage(
        key: 'password',
        value: encryptionService.encrypt(passwordController.text)
      );
      return true;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-credential':
          message = 'Invalid Email or Password';
          break;
        case 'user-not-found':
          message = 'Invalid Email or Password';
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
      showSnackBar(errorSnackBar(message));
      return false;
    } catch (e) {
      showSnackBar(errorSnackBar('An unexpected error occurred: $e'));
      return false;
    }
}