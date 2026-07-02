import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_colors.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  // This key controls and validates the login form.
  final formKey = GlobalKey<FormState>();

  // These controllers collect the email and password.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Controls whether the password is visible.
  bool hidePassword = true;

  // Prevents the button from being pressed twice while signing in.
  bool isLoading = false;

  @override
  void dispose() {
    // Controllers should be removed when the screen closes.
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          )
          .timeout(const Duration(seconds: 20));

      if (!mounted) {
        return;
      }

      // Return to the first route.
      // AuthGate will detect the signed-in user
      // and open the correct dashboard.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on TimeoutException {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Firebase took too long to respond. Check your internet connection.',
          ),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      String message = 'Sign in failed. Please try again.';

      if (error.code == 'invalid-credential' ||
          error.code == 'wrong-password' ||
          error.code == 'user-not-found') {
        message = 'The email or password is incorrect.';
      } else if (error.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (error.code == 'user-disabled') {
        message = 'This account has been disabled.';
      } else if (error.code == 'too-many-requests') {
        message = 'Too many attempts. Please wait and try again.';
      } else if (error.code == 'network-request-failed') {
        message = 'Check your internet connection.';
      } else {
        message = 'Firebase error: ${error.code}. ${error.message ?? ''}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unexpected error: $error')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email address first.')),
      );

      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A password reset email has been sent.')),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      String message = 'Unable to send the password reset email.';

      if (error.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (error.code == 'user-not-found') {
        message = 'No account was found with this email.';
      } else if (error.code == 'network-request-failed') {
        message = 'Check your internet connection.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
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
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }

                    if (!value.contains('@') || !value.contains('.')) {
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
                      tooltip: hidePassword ? 'Show password' : 'Hide password',
                      onPressed: () {
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
                    Text(
                      'Do not have an account?',
                      style: TextStyle(color: mutedTextColor),
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
