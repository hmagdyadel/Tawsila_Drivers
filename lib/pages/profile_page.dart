import 'package:flutter/material.dart';
import 'package:tawsila_driver/global/global.dart';
import 'package:tawsila_driver/splash/splash_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text('Sign out'),
        onPressed: () {
          firebaseAuth.signOut();
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => const SplashView()));
        },
      ),
    );
  }
}
