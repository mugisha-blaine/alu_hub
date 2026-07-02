import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'login_screen.dart';
import 'role_selection_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  void continueRegistration() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return RoleSelectionScreen(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                Text(
                  'Join ALU_HUB',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Create your account to discover or post opportunities.',
                  style: TextStyle(
                    color: mutedTextColor,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 28),

                _FieldLabel(text: 'Full name', color: textColor),

                const SizedBox(height: 8),

                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }

                    if (value.trim().length < 3) {
                      return 'Name must contain at least 3 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _FieldLabel(text: 'Email', color: textColor),

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

                const SizedBox(height: 18),

                _FieldLabel(text: 'Password', color: textColor),

                const SizedBox(height: 8),

                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Create a password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
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
                      return 'Please create a password';
                    }

                    if (value.length < 6) {
                      return 'Password must contain at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _FieldLabel(text: 'Confirm password', color: textColor),

                const SizedBox(height: 8),

                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: hideConfirmPassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Enter the password again',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hideConfirmPassword = !hideConfirmPassword;
                        });
                      },
                      icon: Icon(
                        hideConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }

                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                FilledButton(
                  onPressed: continueRegistration,
                  child: const Text('Continue'),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: mutedTextColor),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const LoginScreen();
                            },
                          ),
                        );
                      },
                      child: const Text('Sign in'),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _FieldLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w700),
    );
  }
}
