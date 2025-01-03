// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'auth/login_screen.dart';
// import 'home_screen.dart';

// class Wrapper extends StatelessWidget {
//   const Wrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context, snapshot) {
//       if(snapshot.connectionState == ConnectionState.waiting){
//         return const Center(child: CircularProgressIndicator(),
//         );
//       }else if(snapshot.hasError){
//         return const Center(child: Text("Error"),
//         );
//       }else{
//         if(snapshot.data == null){
//           return const LoginScreen();
//         }else{
//           return const HomeScreen();
//         }
//       }
//     },),);
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hershield/widgets/bottom_nav.dart';
import 'auth/login_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("An error occurred. Please try again."),
            );
          } else {
            // Check if the user is logged in
            if (snapshot.data == null) {
              return const LoginScreen(); // Navigate to login if no user is authenticated
            } else {
              return const BottomNavBar(); // Navigate to the Bottom Navigation Bar
            }
          }
        },
      ),
    );
  }
}