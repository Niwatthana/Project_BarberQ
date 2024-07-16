import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:barberapp/firebase_options.dart';
import 'package:barberapp/loginpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barber App',
      theme: ThemeData(
        // This is the theme of your applicati
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FlutterSplashScreen.scale(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 244, 242, 240),
            Color.fromARGB(255, 244, 242, 240),
          ],
        ),
        childWidget: SizedBox(
          //height: 50,
          child: Image.asset("assets/icons/barbersceen.gif"),
        ),
        duration: const Duration(milliseconds: 1800),
        animationDuration: const Duration(milliseconds: 1000),
        nextScreen: LoginPage(),
      ),
    );
  }
}
