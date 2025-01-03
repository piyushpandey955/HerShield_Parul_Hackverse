

// import 'package:hershield/screens/profile_screen.dart';
// import 'auth_service.dart';
// import 'login_screen.dart';
// import '../widgets/button.dart';
// import '../widgets/textfield.dart';
// import 'package:flutter/material.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _auth = AuthService();

//   final _name = TextEditingController();
//   final _email = TextEditingController();
//   final _password = TextEditingController();

//   @override
//   void dispose() {
//     super.dispose();
//     _name.dispose();
//     _email.dispose();
//     _password.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 25),
//         child: Column(
//           children: [
//             const Spacer(),
//             const Text("Signup",
//                 style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
//             const SizedBox(
//               height: 50,
//             ),
//             CustomTextField(
//               hint: "Enter Name",
//               label: "Name",
//               controller: _name,
//             ),
//             const SizedBox(height: 20),
//             CustomTextField(
//               hint: "Enter Email",
//               label: "Email",
//               controller: _email,
//             ),
//             const SizedBox(height: 20),
//             CustomTextField(
//               hint: "Enter Password",
//               label: "Password",
//               isPassword: true,
//               controller: _password,
//             ),
//             const SizedBox(height: 30),
//             CustomButton(
//               label: "Signup",
//               onPressed: _signup,
//             ),
//             const SizedBox(height: 5),
//             Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//               const Text("Already have an account? "),
//               InkWell(
//                 onTap: () => goToLogin(context),
//                 child: const Text("Login", style: TextStyle(color: Colors.red)),
//               )
//             ]),
//             const Spacer()
//           ],
//         ),
//       ),
//     );
//   }

//   goToLogin(BuildContext context) => Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//       );

//   goToProfile(BuildContext context) => Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const ProfileScreen()),
//       );

//   _signup() async {
//     await _auth.createUserWithEmailAndPassword(_email.text, _password.text);
//     // After successful signup, navigate to Profile Screen
//     goToProfile(context);
//   }
// }

import 'package:flutter/material.dart';
import 'package:hershield/screens/profile_screen.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import '../screens/personality_test_screen.dart';
import '../widgets/button.dart';
import '../widgets/textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const Spacer(),
            const Text("Signup",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
            const SizedBox(
              height: 50,
            ),
            CustomTextField(
              hint: "Enter Name",
              label: "Name",
              controller: _name,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Email",
              label: "Email",
              controller: _email,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Password",
              label: "Password",
              isPassword: true,
              controller: _password,
            ),
            const SizedBox(height: 30),
            CustomButton(
              label: "Signup",
              onPressed: _navigateToPersonalityTest,
            ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Already have an account? "),
              InkWell(
                onTap: () => goToLogin(context),
                child: const Text("Login", style: TextStyle(color: Colors.red)),
              )
            ]),
            const Spacer()
          ],
        ),
      ),
    );
  }

  void _navigateToPersonalityTest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalityTestScreen(
          onTestComplete: (int score) async {
            if (score >= 28) {
              // If the test score is satisfactory, proceed with signup
              await _signup();
            } else {
              // Show a message and ask the user to retake the test
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please retake the personality test to continue."),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _signup() async {
    try {
      await _auth.createUserWithEmailAndPassword(_email.text, _password.text);
      // Navigate to Profile Screen after successful signup
      goToProfile(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Signup failed: ${e.toString()}"),
        ),
      );
    }
  }

  void goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void goToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }
}