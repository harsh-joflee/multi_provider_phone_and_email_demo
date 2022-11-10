import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'main.dart';

class OtpVerificationScreen extends StatelessWidget {
  OtpVerificationScreen({
    Key? key,
    required this.verificationId,
    required this.email,
    required this.mobileNumber,
    this.isGoogleLogin,
    this.oAuthGoogleCredentials,
  }) : super(key: key);

  final String verificationId;
  final String email;
  final String mobileNumber;
  final bool? isGoogleLogin;
  final OAuthCredential? oAuthGoogleCredentials;

  TextEditingController otpController = TextEditingController();

  Future<AuthCredential> emailPasswordLogin(String email) async {
    AuthCredential userCredential =
        EmailAuthProvider.credential(email: email, password: '12341234');
    return userCredential;
  }

  Future<void> otpSubmitted({
    required String verifyId,
    required String emailValue,
    required BuildContext context,
  }) async {
    AuthCredential otherProviderCredentials = isGoogleLogin ?? false
        ? GoogleAuthProvider.credential(
            idToken: oAuthGoogleCredentials?.idToken)
        : await emailPasswordLogin(emailValue);
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verifyId,
      smsCode: otpController.text,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    try {
      final userCredential = await FirebaseAuth.instance.currentUser
          ?.linkWithCredential(otherProviderCredentials);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "provider-already-linked":
          print("The provider has already been linked to the user.");
          break;
        case "invalid-credential":
          print("The provider's credential is not valid.");
          break;
        case "credential-already-in-use":
          print("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          break;
        case "email-already-in-use":
          print("The email address is already in use by another account.");
          break;
        // See the API reference for the full list of error codes.
        default:
          print("Unknown error.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Screen'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          Text('Mobile Number :- $mobileNumber'),
          const SizedBox(height: 10),
          Text('Email Address :- $email'),
          const SizedBox(height: 10),
          CommonTextField(
            hintText: 'Enter OTP here',
            textController: otpController,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await otpSubmitted(
                verifyId: verificationId,
                emailValue: email,
                context: context,
              );
            },
            child: const Text(
              'LOGIN',
            ),
          ),
        ],
      ),
    );
  }
}
