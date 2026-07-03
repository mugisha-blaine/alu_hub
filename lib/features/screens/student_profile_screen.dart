import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'login_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() {
    return _StudentProfileScreenState();
  }
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  String role = 'Student';

  @override
  void initState() {
    super.initState();

    loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    bioController.dispose();

    super.dispose();
  }

  void showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void loadProfile() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });

      showMessage('Please sign in again.');
      return;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((document) {
          if (!mounted) {
            return;
          }

          final data = document.data();

          setState(() {
            nameController.text =
                data?['name']?.toString() ?? user.displayName ?? '';

            emailController.text =
                data?['email']?.toString() ?? user.email ?? '';

            phoneController.text = data?['phone']?.toString() ?? '';

            bioController.text = data?['bio']?.toString() ?? '';

            role = data?['role']?.toString() ?? 'Student';

            isLoading = false;
          });
        })
        .catchError((error) {
          if (!mounted) {
            return;
          }

          setState(() {
            isLoading = false;
          });

          showMessage('Unable to load profile: $error');
        });
  }

  void saveProfile() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('Please sign in again.');
      return;
    }

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final bio = bioController.text.trim();

    if (name.isEmpty) {
      showMessage('Please enter your full name.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
          'name': name,
          'phone': phone,
          'bio': bio,
          'updatedAt': FieldValue.serverTimestamp(),
        })
        .then((_) {
          return user.updateDisplayName(name);
        })
        .then((_) {
          if (!mounted) {
            return;
          }

          setState(() {});

          showMessage('Profile updated successfully.');
        })
        .catchError((error) {
          showMessage('Unable to update profile: $error');
        })
        .whenComplete(() {
          if (mounted) {
            setState(() {
              isSaving = false;
            });
          }
        });
  }

  void confirmSignOut() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                signOut();
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  void signOut() {
    FirebaseAuth.instance
        .signOut()
        .then((_) {
          if (!mounted) {
            return;
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const LoginScreen();
              },
            ),
            (route) => false,
          );
        })
        .catchError((error) {
          showMessage('Unable to sign out: $error');
        });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white10
                      : Colors.black.withOpacity(0.05),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.12),
                    child: Text(
                      nameController.text.isNotEmpty
                          ? nameController.text[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    nameController.text.isEmpty
                        ? 'ALU Student'
                        : nameController.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    emailController.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: mutedTextColor),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'Personal Information',
              style: TextStyle(
                color: textColor,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Full name',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: nameController,
              enabled: !isSaving,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {
                setState(() {});
              },
              decoration: const InputDecoration(
                hintText: 'Enter your full name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Email',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: emailController,
              enabled: false,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Phone number',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: phoneController,
              enabled: !isSaving,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Enter your phone number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'About you',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: bioController,
              enabled: !isSaving,
              maxLines: 4,
              maxLength: 250,
              decoration: const InputDecoration(
                hintText: 'Write a short description about yourself',
                prefixIcon: Icon(Icons.info_outline_rounded),
              ),
            ),

            const SizedBox(height: 22),

            FilledButton.icon(
              onPressed: isSaving ? null : saveProfile,
              icon: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(isSaving ? 'Saving...' : 'Save Changes'),
            ),

            const SizedBox(height: 14),

            OutlinedButton.icon(
              onPressed: isSaving ? null : confirmSignOut,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
