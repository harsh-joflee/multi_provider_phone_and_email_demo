import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:multi_provider_phone_and_email_demo/otp_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //INIT FIREBASE APP
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  bool isEmail = true;

  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // return credential;

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+918401830836',
      verificationCompleted: (PhoneAuthCredential credential) {
        log(credential.toString(), name: 'verificationCompleted');
      },
      verificationFailed: (FirebaseAuthException e) {
        log(e.toString(), name: 'verificationFailed');
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => OtpVerificationScreen(
                verificationId: verificationId,
                email: '',
                mobileNumber: '+918401830836',
                isGoogleLogin: true,
                oAuthGoogleCredentials: credential,
              ),
            ));
        log('VERIFICATION ID :- $verificationId && RESEND TOKEN :- $resendToken',
            name: 'codeSent');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        log('VERIFICATION ID :- $verificationId',
            name: 'codeAutoRetrievalTimeout');
      },
      timeout: const Duration(seconds: 40),
    );

    // Once signed in, return the UserCredential
    // UserCredential userCredential =
    //     await FirebaseAuth.instance.signInWithCredential(credential);
    // return userCredential;
  }

  void signOut() async {
    print('SIGNOUT METHOD CALLED');
    if (await GoogleSignIn().isSignedIn()) {
      await GoogleSignIn()
          .signOut()
          .then((value) => print('Google SignOut Successfully'));
    }

    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance
          .signOut()
          .then((value) => print('Firebase Instance SignOut Successfully'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: EmailForm(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.apple),
        onPressed: () async {
          await signInWithGoogle();
        },
      ),
    );
  }
}

class EmailForm extends StatelessWidget {
  EmailForm({Key? key}) : super(key: key);

  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();

  Future<void> onPressLogin(BuildContext context) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: mobileNumberController.text,
      verificationCompleted: (PhoneAuthCredential credential) {
        log(credential.toString(), name: 'verificationCompleted');
      },
      verificationFailed: (FirebaseAuthException e) {
        log(e.toString(), name: 'verificationFailed');
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => OtpVerificationScreen(
                verificationId: verificationId,
                email: emailController.text,
                mobileNumber: mobileNumberController.text,
              ),
            ));
        log('VERIFICATION ID :- $verificationId && RESEND TOKEN :- $resendToken',
            name: 'codeSent');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        log('VERIFICATION ID :- $verificationId',
            name: 'codeAutoRetrievalTimeout');
      },
      timeout: const Duration(seconds: 40),
    );
  }

  Future<void> onSignIn() async {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: emailController.text, password: '12341234');
    print(userCredential.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        children: [
          CommonTextField(
            hintText: 'email',
            textController: emailController,
          ),
          const SizedBox(height: 10),
          CommonTextField(
            hintText: 'phone number',
            textController: mobileNumberController,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await onPressLogin(context);
              // await onSignIn();
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

class CommonTextField extends StatelessWidget {
  CommonTextField({
    Key? key,
    this.textController,
    this.validator,
    this.suffixIcon,
    this.keyboardType,
    this.onSuffixIconTap,
    this.hintText,
    this.scrollPadding,
    this.showSuffixIcon,
    this.suffixIconSize,
    this.hintStyle,
    this.obscureText,
    this.maxlines,
    this.inputFormatters,
    this.onPrefixIconTap,
    this.prefixIcon,
    this.prefixIconSize,
    this.showPrefixIcon,
    this.onFieldSubmitted,
    this.textInputAction,
    this.borderColor,
    this.errorBorderColor,
    this.textFieldBackGroundColor,
    this.isShowBorder,
    this.isUnderlineBorder,
    this.onChanged,
  }) : super(key: key);
  final String? hintText;
  final IconData? suffixIcon;
  final String? prefixIcon;
  final TextEditingController? textController;
  final TextInputType? keyboardType;
  final VoidCallback? onSuffixIconTap;
  final VoidCallback? onPrefixIconTap;
  String? Function(String?)? validator;
  final double? scrollPadding;
  final double? suffixIconSize;
  final double? prefixIconSize;
  final int? maxlines;
  final bool? showSuffixIcon;
  final bool? showPrefixIcon;
  final TextStyle? hintStyle;
  final bool? obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final Color? borderColor;
  final Color? errorBorderColor;
  final Color? textFieldBackGroundColor;
  final bool? isShowBorder;
  final bool? isUnderlineBorder;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: textFieldBackGroundColor,
      child: TextFormField(
        controller: textController,
        textInputAction: textInputAction,
        validator: validator,
        keyboardType: keyboardType,
        scrollPadding: EdgeInsets.only(bottom: scrollPadding ?? 100),
        obscureText: obscureText ?? false,
        inputFormatters: inputFormatters,
        maxLines: maxlines ?? 1,
        onFieldSubmitted: onFieldSubmitted,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: showPrefixIcon ?? false
              ? IconButton(
                  onPressed: onPrefixIconTap,
                  icon: Image.asset(
                    prefixIcon ?? '',
                    height: prefixIconSize ?? 10,
                  ),
                )
              : null,
          border: isShowBorder ?? true
              ? isUnderlineBorder ?? false
                  ? UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: borderColor ?? Colors.grey,
                      ),
                    )
                  : OutlineInputBorder(
                      borderSide: BorderSide(
                        color: borderColor ?? Colors.grey,
                      ),
                    )
              : InputBorder.none,
          errorBorder: isShowBorder ?? true
              ? isUnderlineBorder ?? false
                  ? UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: errorBorderColor ?? Colors.red.shade400,
                      ),
                    )
                  : OutlineInputBorder(
                      borderSide: BorderSide(
                        color: errorBorderColor ?? Colors.red.shade400,
                      ),
                    )
              : InputBorder.none,
          contentPadding: showSuffixIcon ?? false
              ? const EdgeInsets.only(top: 10, left: 10, right: 10)
              : const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
          isDense: true,
          hintText: hintText,
          hintStyle: hintStyle ??
              TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
          suffixIcon: showSuffixIcon ?? false
              ? IconButton(
                  onPressed: onSuffixIconTap,
                  icon: Icon(
                    suffixIcon,
                    size: suffixIconSize,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
