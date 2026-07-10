import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'login_screen.dart';

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
  final founderAluEmailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String selectedRole = 'Student';

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    founderAluEmailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  bool isValidEmail(String email) {
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    return emailPattern.hasMatch(email.trim().toLowerCase());
  }

  bool isAllowedAluEmail(String email) {
    return email.trim().toLowerCase().endsWith('@alustudent.com');
  }

  String getNameLabel() {
    if (selectedRole == 'Startup') {
      return 'Startup name';
    }

    return 'Full name';
  }

  String getNameHint() {
    if (selectedRole == 'Startup') {
      return 'Enter your startup name';
    }

    return 'Enter your full name';
  }

  void showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
  }

  String readableRegistrationError(Object error) {
    if (error is FirebaseAuthException) {
      if (error.code == 'email-already-in-use') {
        return 'An account already exists with this email.';
      }

      if (error.code == 'invalid-email') {
        return 'Please enter a valid email address.';
      }

      if (error.code == 'weak-password') {
        return 'Use a stronger password with at least 6 characters.';
      }

      if (error.code == 'network-request-failed') {
        return 'Check your internet connection and try again.';
      }

      if (error.code == 'operation-not-allowed') {
        return 'Email and password registration is not enabled.';
      }

      return 'Registration failed: ${error.message ?? error.code}';
    }

    final errorText = error.toString();

    if (errorText.contains('permission-denied')) {
      return 'Your profile could not be created. Check your email and account type.';
    }

    return 'Unable to create account. Please try again.';
  }

  void createAccount() {
    final formIsValid = formKey.currentState?.validate() ?? false;

    if (!formIsValid) {
      return;
    }

    FocusScope.of(context).unfocus();

    final name = nameController.text.trim();

    final email = emailController.text.trim().toLowerCase();

    final founderAluEmail = founderAluEmailController.text.trim().toLowerCase();

    final password = passwordController.text;

    if (selectedRole == 'Student' && !isAllowedAluEmail(email)) {
      showMessage('Student accounts require an @alustudent.com email.');
      return;
    }

    if (selectedRole == 'Startup' && !isAllowedAluEmail(founderAluEmail)) {
      showMessage('The startup founder must provide an @alustudent.com email.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((userCredential) {
          final user = userCredential.user;

          if (user == null) {
            throw Exception('Firebase could not create the account.');
          }

          final userData = <String, dynamic>{
            'uid': user.uid,
            'name': name,
            'email': email,
            'role': selectedRole,
            'phone': '',
            'bio': '',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };

          if (selectedRole == 'Startup') {
            userData.addAll({
              'startupName': name,
              'founderName': '',
              'founderAluEmail': founderAluEmail,
              'website': '',
              'location': '',
              'description': '',
              'isVerified': false,
              'verificationStatus': 'Pending',
              'verificationMessage': '',
            });
          } else {
            userData.addAll({
              'skills': <String>[],
              'interests': <String>[],
              'studyYear': '',
              'portfolioUrl': '',
            });
          }

          return FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(userData)
              .then((_) {
                return user.updateDisplayName(name);
              });
        })
        .then((_) {
          if (!mounted) {
            return;
          }

          showMessage(
            selectedRole == 'Startup'
                ? 'Startup account created. Your account is awaiting administrator verification.'
                : 'Student account created successfully.',
          );

          Navigator.popUntil(context, (route) => route.isFirst);
        })
        .catchError((error) {
          final message = readableRegistrationError(error);

          final currentUser = FirebaseAuth.instance.currentUser;

          if (currentUser != null) {
            currentUser.delete().catchError((deleteError) {
              debugPrint('Unable to remove incomplete account: $deleteError');
            });
          }

          showMessage(message);
        })
        .whenComplete(() {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        });
  }

  void openLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const LoginScreen();
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
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Join ALU Hub',
                style: TextStyle(
                  color: textColor,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Create a student or startup account.',
                style: TextStyle(
                  color: mutedTextColor,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Account type',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.people_outline_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 'Student', child: Text('Student')),
                  DropdownMenuItem(value: 'Startup', child: Text('Startup')),
                ],
                onChanged: isLoading
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          selectedRole = value;

                          if (selectedRole == 'Student') {
                            founderAluEmailController.clear();
                          }
                        });

                        formKey.currentState?.validate();
                      },
              ),

              const SizedBox(height: 20),

              Text(
                getNameLabel(),
                style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: nameController,
                enabled: !isLoading,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: getNameHint(),
                  prefixIcon: Icon(
                    selectedRole == 'Startup'
                        ? Icons.business_outlined
                        : Icons.person_outline_rounded,
                  ),
                ),
                validator: (value) {
                  final name = value?.trim() ?? '';

                  if (name.isEmpty) {
                    return selectedRole == 'Startup'
                        ? 'Please enter your startup name'
                        : 'Please enter your full name';
                  }

                  if (name.length < 2) {
                    return 'Name must contain at least 2 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              Text(
                selectedRole == 'Startup'
                    ? 'Startup account email'
                    : 'Student email',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: emailController,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: selectedRole == 'Student'
                      ? 'name@alustudent.com'
                      : 'startup@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  final email = value?.trim().toLowerCase() ?? '';

                  if (email.isEmpty) {
                    return 'Please enter your email address';
                  }

                  if (!isValidEmail(email)) {
                    return 'Please enter a valid email address';
                  }

                  if (selectedRole == 'Student' && !isAllowedAluEmail(email)) {
                    return 'Students must use an @alustudent.com email';
                  }

                  return null;
                },
              ),

              if (selectedRole == 'Student') ...[
                const SizedBox(height: 7),
                Text(
                  'Student accounts require an official @alustudent.com email.',
                  style: TextStyle(color: mutedTextColor, fontSize: 12),
                ),
              ],

              if (selectedRole == 'Startup') ...[
                const SizedBox(height: 20),

                Text(
                  'Founder ALU email',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: founderAluEmailController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'founder@alustudent.com',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  validator: (value) {
                    if (selectedRole != 'Startup') {
                      return null;
                    }

                    final email = value?.trim().toLowerCase() ?? '';

                    if (email.isEmpty) {
                      return 'Please enter the founder ALU email';
                    }

                    if (!isValidEmail(email)) {
                      return 'Please enter a valid email address';
                    }

                    if (!isAllowedAluEmail(email)) {
                      return 'Founder must use an @alustudent.com email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 7),

                Text(
                  'The administrator will review this ALU email before approving the startup.',
                  style: TextStyle(color: mutedTextColor, fontSize: 12),
                ),
              ],

              const SizedBox(height: 20),

              Text(
                'Password',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: passwordController,
                enabled: !isLoading,
                obscureText: hidePassword,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Create a password',
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
                    return 'Please enter a password';
                  }

                  if (value.length < 6) {
                    return 'Password must contain at least 6 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              Text(
                'Confirm password',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: confirmPasswordController,
                enabled: !isLoading,
                obscureText: hideConfirmPassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!isLoading) {
                    createAccount();
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Enter password again',
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                  suffixIcon: IconButton(
                    onPressed: isLoading
                        ? null
                        : () {
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

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : createAccount,
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Account'),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'Already have an account?',
                      style: TextStyle(color: mutedTextColor),
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : openLogin,
                    child: const Text('Sign In'),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
