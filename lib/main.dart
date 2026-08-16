import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BondhuSocialApp());
}

class BondhuSocialApp extends StatelessWidget {
  const BondhuSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bondhu Social',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const PhoneLoginPage(),
    );
  }
}

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  String verificationId = '';
  bool otpSent = false;
  bool loading = false;
  String message = '';

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() => message = 'মোবাইল নাম্বার দিন।');
      return;
    }

    setState(() {
      loading = true;
      message = '';
    });

    await auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (credential) async {
        await auth.signInWithCredential(credential);

        if (!mounted) return;

        setState(() {
          loading = false;
          message = 'Login সফল হয়েছে।';
        });
      },
      verificationFailed: (FirebaseAuthException error) {
        if (!mounted) return;

        setState(() {
          loading = false;
          message = error.message ?? 'OTP পাঠানো যায়নি।';
        });
      },
      codeSent: (String id, int? resendToken) {
        if (!mounted) return;

        setState(() {
          verificationId = id;
          otpSent = true;
          loading = false;
          message = 'OTP পাঠানো হয়েছে।';
        });
      },
      codeAutoRetrievalTimeout: (String id) {
        verificationId = id;
      },
    );
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.length != 6) {
      setState(() => message = '৬ সংখ্যার OTP দিন।');
      return;
    }

    setState(() {
      loading = true;
      message = '';
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await auth.signInWithCredential(credential);

      if (!mounted) return;

      setState(() {
        loading = false;
        message = 'Login সফল হয়েছে।';
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      setState(() {
        loading = false;
        message = error.message ?? 'OTP ভুল হয়েছে।';
      });
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bondhu Social'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 50),

              const Icon(
                Icons.people_alt,
                size: 90,
              ),

              const SizedBox(height: 20),

              const Text(
                'Bondhu Social',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'মোবাইল নাম্বার দিয়ে Login করুন',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 35),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'মোবাইল নাম্বার',
                  hintText: '+8801XXXXXXXXX',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : sendOtp,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'OTP পাঠান',
                          style: TextStyle(fontSize: 17),
                        ),
                ),
              ),

              if (otpSent) ...[
                const SizedBox(height: 25),

                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: loading ? null : verifyOtp,
                    child: const Text(
                      'Verify OTP',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              if (message.isNotEmpty)
                Text(
                  message,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
