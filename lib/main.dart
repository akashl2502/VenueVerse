import 'package:VenueVerse/components/Colors.dart';
import 'package:VenueVerse/pages/Getstarted.dart';
import 'package:VenueVerse/pages/Userdetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isloading = true;
  bool _exitsuser = false;
  bool _user = false;
  String uid = '';
  String email = '';
  @override
  void initState() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isloading = false;
        uid = user.uid;
        _exitsuser = true;
        email = user.email!;
      });
    } else {
      setState(() {
        _isloading = false;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isloading) {
      return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Appcolor.firstgreen, primary: Appcolor.firstgreen),
          useMaterial3: true,
        ),
        home: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Appcolor.firstgreen, primary: Appcolor.firstgreen),
        useMaterial3: true,
      ),
      home: _exitsuser
          ? userdetails(
              uid: uid,
              email: email,
            )
          : Getstarted(),
    );
  }
}
