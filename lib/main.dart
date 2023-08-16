import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'view/home/home.dart';
import './view/screens/register_with_phone.dart';
import './firebase_options.dart';
import './view/screens/splash_screen.dart';
import './view/screens/profile_info.dart';
import 'package:provider/provider.dart';
import './logic/UserProfileData.dart';

void main() async {
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
    return ChangeNotifierProvider.value(
      value: UserProfileData(),
      child: MaterialApp(
        title: 'Chat Clone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // textButtonTheme: const TextButtonThemeData(style: ButtonStyle(foregroundColor:  ))),
          // colorScheme: ColorScheme.fromSwatch(
          //   primarySwatch: Colors.amber,  backgroundColor: Colors.white
          // ),
          //colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
          useMaterial3: true,
        ),
        home: const AuthenticationState(),
      ),
    );
  }
}

class AuthenticationState extends StatelessWidget {
  const AuthenticationState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasData) {
          if (snapshot.data!.displayName != '' &&
              snapshot.data!.displayName != null) {
            return const Home();
          } else {
            return ProfileInfo(
              phoneNo: snapshot.data!.phoneNumber!,
              isThisFirstScreen: true,
            );
          }
        }

        return const RegisterWithPhoneNumber();
      },
    );
  }
}
