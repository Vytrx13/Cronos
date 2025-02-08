import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screen.dart';
import 'package:teste_cronos/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _firebaseAuth = FirebaseAuth.instance;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cronos App',
      theme: ThemeData.light(),
      home: StreamBuilder<User?>(
        stream: _firebaseAuth.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingScreen(); // Show a loading screen if the authentication state is still loading
          } else if (snapshot.hasData && snapshot.data != null) {
            return HomeScreen(); // User is logged in, show the home screen
          } else {
            return const LoginScreen(); // User is not logged in, show the login screen
          }
        },
      ),
    );
  }
}
