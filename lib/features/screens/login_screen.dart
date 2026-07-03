import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../navigation/main_navigation.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  void showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
    );
  }

  void signIn() {
    debugPrint('Sign In button clicked');

    if (!formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        )
        .then((userCredential) {
          final user = userCredential.user;

          if (user == null) {
            throw Exception('Firebase could not find the signed-in user.');
          }

          debugPrint('Authentication successful');
          debugPrint('User UID: ${user.uid}');

          return FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get()
              .then((userDocument) {
                return {'user': user, 'document': userDocument};
              });
        })
        .then((result) {
          final user = result['user'] as User;

          final userDocument =
              result['document'] as DocumentSnapshot<Map<String, dynamic>>;

          if (!userDocument.exists) {
            debugPrint('Firestore profile does not exist');

            FirebaseAuth.instance.signOut();

            showMessage(
              'Your account exists, but your profile is missing from Firestore. Register again.',
            );

            return;
          }

          final userData = userDocument.data();

          final userName =
              userData?['name']?.toString() ??
              user.displayName ??
              user.email?.split('@').first ??
              'ALU User';

          final role = userData?['role']?.toString() ?? 'Student';

          debugPrint('Profile found');
          debugPrint('Name: $userName');
          debugPrint('Role: $role');

          if (!mounted) {
            return;
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) {
                return MainNavigation(userName: userName, role: role);
              },
            ),
            (route) => false,
          );
        })
        .catchError((error) {
          debugPrint('Login error: $error');

          if (error is FirebaseAuthException) {
            String message = 'Sign in failed. Please try again.';

            if (error.code == 'invalid-credential' ||
                error.code == 'wrong-password' ||
                error.code == 'user-not-found') {
              message = 'The email or password is incorrect.';
            } else if (error.code == 'invalid-email') {
              message = 'Please enter a valid email address.';
            } else if (error.code == 'user-disabled') {
              message = 'This account has been disabled.';
            } else if (error.code == 'network-request-failed') {
              message = 'Check your internet connection.';
            } else if (error.code == 'too-many-requests') {
              message = 'Too many attempts. Try again later.';
            } else {
              message = 'Authentication error: ${error.code}.';
            }

            showMessage(message);
            return;
          }

          if (error is FirebaseException) {
            showMessage(
              'Firebase error: ${error.code}. '
              '${error.message ?? ''}',
            );
            return;
          }

          showMessage('An unexpected error occurred: $error');
        })
        .whenComplete(() {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        });
  }

  void resetPassword() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showMessage('Enter your email address first.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      showMessage('Please enter a valid email address.');
      return;
    }

    FocusScope.of(context).unfocus();

    FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
        .then((_) {
          showMessage('A password-reset link has been sent to your email.');
        })
        .catchError((error) {
          debugPrint('Password reset error: $error');

          if (error is FirebaseAuthException) {
            String message = 'The password-reset email could not be sent.';

            if (error.code == 'invalid-email') {
              message = 'Please enter a valid email address.';
            } else if (error.code == 'network-request-failed') {
              message = 'Check your internet connection.';
            } else if (error.code == 'too-many-requests') {
              message = 'Too many requests. Try again later.';
            }

            showMessage(message);
            return;
          }

          showMessage('Unable to send the password-reset email.');
        });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Sign in to discover ALU startup opportunities.',
                  style: TextStyle(color: mutedTextColor, fontSize: 15),
                ),

                const SizedBox(height: 32),

                Text(
                  'Email',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: emailController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';

                    if (email.isEmpty) {
                      return 'Please enter your email';
                    }

                    if (!email.contains('@') || !email.contains('.')) {
                      return 'Please enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Text(
                  'Password',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: passwordController,
                  enabled: !isLoading,
                  obscureText: hidePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!isLoading) {
                      signIn();
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }

                    if (value.length < 6) {
                      return 'Password must contain at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading ? null : resetPassword,
                    child: const Text('Forgot password?'),
                  ),
                ),

                const SizedBox(height: 16),

                FilledButton(
                  onPressed: isLoading ? null : signIn,
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Sign In'),
                ),

                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Do not have an account?',
                        style: TextStyle(color: mutedTextColor),
                      ),
                    ),

                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const RegisterScreen();
                                  },
                                ),
                              );
                            },
                      child: const Text('Create account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
