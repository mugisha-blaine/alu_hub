import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../navigation/main_navigation.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Show loading while Firebase checks the saved login session.
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = authSnapshot.data;

        // No authenticated user means show onboarding.
        if (user == null) {
          return const LoginScreen();
        }

        // Read the signed-in user's profile from Firestore.
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            if (profileSnapshot.hasError) {
              return _ProfileErrorScreen(
                message: 'Unable to load your profile.',
              );
            }

            final userDocument = profileSnapshot.data;

            if (userDocument == null || !userDocument.exists) {
              return const _ProfileErrorScreen(
                message:
                    'Your Firebase account exists, but your profile was not found.',
              );
            }

            final userData = userDocument.data();

            final userName =
                userData?['name']?.toString() ??
                user.displayName ??
                user.email?.split('@').first ??
                'ALU User';

            final role = userData?['role']?.toString() ?? 'Student';

            return MainNavigation(userName: userName, role: role);
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ProfileErrorScreen extends StatelessWidget {
  final String message;

  const _ProfileErrorScreen({required this.message});

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 75,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Profile Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 25),
                FilledButton(
                  onPressed: signOut,
                  child: const Text('Return to Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
