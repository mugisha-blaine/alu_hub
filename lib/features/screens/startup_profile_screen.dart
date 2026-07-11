import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'login_screen.dart';

class StartupProfileScreen extends StatefulWidget {
  const StartupProfileScreen({super.key});

  @override
  State<StartupProfileScreen> createState() {
    return _StartupProfileScreenState();
  }
}

class _StartupProfileScreenState extends State<StartupProfileScreen> {
  final startupNameController = TextEditingController();

  final emailController = TextEditingController();

  final phoneController = TextEditingController();

  final websiteController = TextEditingController();

  final locationController = TextEditingController();

  final descriptionController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  String role = 'Startup';

  @override
  void initState() {
    super.initState();

    loadStartupProfile();
  }

  @override
  void dispose() {
    startupNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    locationController.dispose();
    descriptionController.dispose();

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

  void loadStartupProfile() {
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
            startupNameController.text =
                data?['name']?.toString() ??
                data?['startupName']?.toString() ??
                user.displayName ??
                '';

            emailController.text =
                data?['email']?.toString() ?? user.email ?? '';

            phoneController.text = data?['phone']?.toString() ?? '';

            websiteController.text = data?['website']?.toString() ?? '';

            locationController.text = data?['location']?.toString() ?? '';

            descriptionController.text =
                data?['description']?.toString() ??
                data?['bio']?.toString() ??
                '';

            role = data?['role']?.toString() ?? 'Startup';

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

          showMessage('Unable to load startup profile: $error');
        });
  }

  void saveStartupProfile() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('Please sign in again.');
      return;
    }

    final startupName = startupNameController.text.trim();

    if (startupName.isEmpty) {
      showMessage('Please enter the startup name.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
          'name': startupName,
          'startupName': startupName,
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'website': websiteController.text.trim(),
          'location': locationController.text.trim(),
          'description': descriptionController.text.trim(),
          'role': role,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        .then((_) {
          return user.updateDisplayName(startupName);
        })
        .then((_) {
          if (!mounted) {
            return;
          }

          setState(() {});

          showMessage('Startup profile updated successfully.');
        })
        .catchError((error) {
          showMessage('Unable to update startup profile: $error');
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
        title: const Text('Startup Profile'),
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
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
                    child: Text(
                      startupNameController.text.isNotEmpty
                          ? startupNameController.text[0].toUpperCase()
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
                    startupNameController.text.isEmpty
                        ? 'ALU Startup'
                        : startupNameController.text,
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
                      color: AppColors.primaryBlue.withValues(alpha: 0.12),
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
              'Startup Information',
              style: TextStyle(
                color: textColor,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 18),

            _FieldLabel(label: 'Startup name', textColor: textColor),

            const SizedBox(height: 8),

            TextField(
              controller: startupNameController,
              enabled: !isSaving,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {
                setState(() {});
              },
              decoration: const InputDecoration(
                hintText: 'Enter startup name',
                prefixIcon: Icon(Icons.business_outlined),
              ),
            ),

            const SizedBox(height: 18),

            _FieldLabel(label: 'Email', textColor: textColor),

            const SizedBox(height: 8),

            TextField(
              controller: emailController,
              enabled: false,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),

            const SizedBox(height: 18),

            _FieldLabel(label: 'Phone number', textColor: textColor),

            const SizedBox(height: 8),

            TextField(
              controller: phoneController,
              enabled: !isSaving,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Enter phone number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),

            const SizedBox(height: 18),

            _FieldLabel(label: 'Website', textColor: textColor),

            const SizedBox(height: 8),

            TextField(
              controller: websiteController,
              enabled: !isSaving,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText: 'https://example.com',
                prefixIcon: Icon(Icons.language_outlined),
              ),
            ),

            const SizedBox(height: 18),

            _FieldLabel(label: 'Location', textColor: textColor),

            const SizedBox(height: 8),

            TextField(
              controller: locationController,
              enabled: !isSaving,
              decoration: const InputDecoration(
                hintText: 'Example: Kigali, Rwanda',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),

            const SizedBox(height: 18),

            _FieldLabel(label: 'Startup description', textColor: textColor),

            const SizedBox(height: 8),

            TextField(
              controller: descriptionController,
              enabled: !isSaving,
              maxLines: 5,
              maxLength: 400,
              decoration: const InputDecoration(
                hintText: 'Describe your startup and its mission',
                prefixIcon: Icon(Icons.info_outline_rounded),
              ),
            ),

            const SizedBox(height: 22),

            FilledButton.icon(
              onPressed: isSaving ? null : saveStartupProfile,
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

class _FieldLabel extends StatelessWidget {
  final String label;
  final Color textColor;

  const _FieldLabel({required this.label, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
    );
  }
}
