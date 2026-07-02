import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

enum AccountRole { student, startup }

class RoleSelectionScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const RoleSelectionScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<RoleSelectionScreen> createState() {
    return _RoleSelectionScreenState();
  }
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  AccountRole? selectedRole;
  bool isLoading = false;

  Future<void> completeRegistration() async {
    // The user must select Student or Startup.
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your account type.')),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    User? createdUser;

    try {
      final String roleName = selectedRole == AccountRole.student
          ? 'Student'
          : 'Startup';

      // Create the Firebase Authentication account.
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: widget.email.trim(),
            password: widget.password,
          );

      createdUser = userCredential.user;

      if (createdUser == null) {
        throw Exception('Firebase could not create the user account.');
      }

      // Save the name in Firebase Authentication.
      await createdUser.updateDisplayName(widget.name.trim());

      // Save the complete user profile in Firestore.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(createdUser.uid)
          .set({
            'uid': createdUser.uid,
            'name': widget.name.trim(),
            'email': widget.email.trim(),
            'role': roleName,
            'phone': '',
            'location': '',
            'studyYear': '',
            'skills': <String>[],
            'interests': <String>[],
            'portfolioUrl': '',
            'profileImageUrl': '',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully.')),
      );

      // Return to the first screen.
      // AuthGate will detect the signed-in user and open
      // the correct Student or Startup interface.
      Navigator.popUntil(context, (route) => route.isFirst);
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      String message;

      if (error.code == 'email-already-in-use') {
        message =
            'An account already exists with this email. Please sign in instead.';
      } else if (error.code == 'invalid-email') {
        message = 'The email address is invalid.';
      } else if (error.code == 'weak-password') {
        message = 'The password is too weak. Use at least 6 characters.';
      } else if (error.code == 'operation-not-allowed') {
        message = 'Email and password registration is not enabled in Firebase.';
      } else if (error.code == 'network-request-failed') {
        message = 'Check your internet connection and try again.';
      } else if (error.code == 'too-many-requests') {
        message = 'Too many attempts. Please wait and try again.';
      } else {
        message = 'Firebase error: ${error.code}. ${error.message ?? ''}';
      }

      debugPrint('Firebase Auth error code: ${error.code}');

      debugPrint('Firebase Auth error message: ${error.message}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
      );
    } on FirebaseException catch (error) {
      // The Firebase Authentication account may have been
      // created even when saving the Firestore profile failed.
      // Delete it so the user can register again.
      if (createdUser != null) {
        try {
          await createdUser.delete();
        } catch (deleteError) {
          debugPrint('Could not delete incomplete user: $deleteError');
        }
      }

      if (!mounted) {
        return;
      }

      debugPrint('Firestore error code: ${error.code}');

      debugPrint('Firestore error message: ${error.message}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile saving failed: '
            '${error.code}. ${error.message ?? ''}',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (error) {
      if (createdUser != null) {
        try {
          await createdUser.delete();
        } catch (deleteError) {
          debugPrint('Could not delete incomplete user: $deleteError');
        }
      }

      if (!mounted) {
        return;
      }

      debugPrint('Unexpected registration error: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $error'),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final Color mutedTextColor = isDarkMode
        ? Colors.white70
        : AppColors.mutedText;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Role')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),

              Text(
                'How will you use ALU_HUB?',
                style: TextStyle(
                  color: textColor,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Your role helps us personalize your experience.',
                style: TextStyle(color: mutedTextColor, fontSize: 15),
              ),

              const SizedBox(height: 30),

              _RoleCard(
                title: 'Student',
                description:
                    'Discover internships, projects, and practical experience.',
                icon: Icons.school_outlined,
                selected: selectedRole == AccountRole.student,
                onTap: isLoading
                    ? null
                    : () {
                        setState(() {
                          selectedRole = AccountRole.student;
                        });
                      },
              ),

              const SizedBox(height: 16),

              _RoleCard(
                title: 'Startup',
                description:
                    'Create a startup profile, post opportunities, and manage applicants.',
                icon: Icons.business_center_outlined,
                selected: selectedRole == AccountRole.startup,
                onTap: isLoading
                    ? null
                    : () {
                        setState(() {
                          selectedRole = AccountRole.startup;
                        });
                      },
              ),

              const Spacer(),

              FilledButton(
                onPressed: isLoading ? null : completeRegistration,
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Complete Registration'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color cardColor = isDarkMode
        ? AppColors.darkCard
        : AppColors.lightCard;

    final Color textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final Color mutedTextColor = isDarkMode
        ? Colors.white70
        : AppColors.mutedText;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.accentBlue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accentBlue
                      : AppColors.primaryBlue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : AppColors.primaryBlue,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      description,
                      style: TextStyle(color: mutedTextColor, height: 1.35),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.accentBlue : AppColors.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
