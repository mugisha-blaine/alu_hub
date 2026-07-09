import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../models/application.dart';
import '../../models/opportunity.dart';
import '../../providers/application_provider.dart';
import 'application_success_screen.dart';

class ApplicationFormScreen extends ConsumerStatefulWidget {
  final Opportunity opportunity;

  const ApplicationFormScreen({super.key, required this.opportunity});

  @override
  ConsumerState<ApplicationFormScreen> createState() {
    return _ApplicationFormScreenState();
  }
}

class _ApplicationFormScreenState extends ConsumerState<ApplicationFormScreen> {
  final formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final motivationController = TextEditingController();
  final portfolioController = TextEditingController();

  final List<String> studyYears = ['Year 1', 'Year 2', 'Year 3'];

  String selectedStudyYear = 'Year 1';

  bool agreedToTerms = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    fullNameController.text = user?.displayName ?? '';

    emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    motivationController.dispose();
    portfolioController.dispose();

    super.dispose();
  }

  void showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
  }

  bool isAllowedStudentEmail(String email) {
    return email.trim().toLowerCase().endsWith('@alustudent.com');
  }

  String readableErrorMessage(Object error) {
    final errorText = error.toString().toLowerCase();

    if (errorText.contains('already applied')) {
      return 'You have already applied for this opportunity.';
    }

    if (errorText.contains('permission-denied')) {
      return 'The application could not be submitted. Check that your account is a Student account and that the opportunity is still active.';
    }

    if (errorText.contains('network')) {
      return 'Check your internet connection and try again.';
    }

    return 'Unable to submit the application. Please try again.';
  }

  void submitApplication() {
    final formIsValid = formKey.currentState?.validate() ?? false;

    if (!formIsValid) {
      return;
    }

    if (!agreedToTerms) {
      showMessage('Please confirm that the information provided is correct.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('You must sign in before applying.');
      return;
    }

    if (widget.opportunity.id.isEmpty) {
      showMessage('This opportunity could not be identified.');
      return;
    }

    if (widget.opportunity.startupId.isEmpty) {
      showMessage('The startup information is missing.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    final application = ApplicationModel(
      id: '',
      opportunityId: widget.opportunity.id,
      opportunityTitle: widget.opportunity.title,
      startupId: widget.opportunity.startupId,
      startupName: widget.opportunity.startupName,
      studentId: user.uid,
      studentName: fullNameController.text.trim(),
      studentEmail: emailController.text.trim().toLowerCase(),
      phone: phoneController.text.trim(),
      studyYear: selectedStudyYear,
      portfolioUrl: portfolioController.text.trim(),
      motivation: motivationController.text.trim(),
      status: 'Submitted',
    );

    final repository = ref.read(applicationRepositoryProvider);

    repository
        .submitApplication(application)
        .then((_) {
          if (!mounted) {
            return;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ApplicationSuccessScreen(
                  opportunityTitle: widget.opportunity.title,
                  startupName: widget.opportunity.startupName,
                );
              },
            ),
          );
        })
        .catchError((error) {
          showMessage(readableErrorMessage(error));
        })
        .whenComplete(() {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    return Scaffold(
      appBar: AppBar(title: const Text('Apply')),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                widget.opportunity.title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                widget.opportunity.startupName,
                style: TextStyle(color: mutedTextColor, fontSize: 15),
              ),

              const SizedBox(height: 26),

              _FieldLabel(label: 'Full name', textColor: textColor),

              const SizedBox(height: 8),

              TextFormField(
                controller: fullNameController,
                enabled: !isLoading,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) {
                  final name = value?.trim() ?? '';

                  if (name.isEmpty) {
                    return 'Please enter your full name';
                  }

                  if (name.length < 2) {
                    return 'Please enter a valid name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _FieldLabel(label: 'ALU email', textColor: textColor),

              const SizedBox(height: 8),

              TextFormField(
                controller: emailController,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'name@alustudent.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  final email = value?.trim().toLowerCase() ?? '';

                  if (email.isEmpty) {
                    return 'Please enter your email';
                  }

                  if (!email.contains('@') || !email.contains('.')) {
                    return 'Please enter a valid email';
                  }

                  if (!isAllowedStudentEmail(email)) {
                    return 'Use your @alustudent.com email';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _FieldLabel(label: 'Phone number', textColor: textColor),

              const SizedBox(height: 8),

              TextFormField(
                controller: phoneController,
                enabled: !isLoading,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Enter your phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  final phone = value?.trim() ?? '';

                  if (phone.isEmpty) {
                    return 'Please enter your phone number';
                  }

                  if (phone.length < 8) {
                    return 'Please enter a valid phone number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _FieldLabel(label: 'Current study year', textColor: textColor),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: selectedStudyYear,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: studyYears.map((year) {
                  return DropdownMenuItem<String>(
                    value: year,
                    child: Text(year),
                  );
                }).toList(),
                onChanged: isLoading
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          selectedStudyYear = value;
                        });
                      },
              ),

              const SizedBox(height: 18),

              _FieldLabel(
                label: 'Portfolio link',
                textColor: textColor,
                optional: true,
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: portfolioController,
                enabled: !isLoading,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'GitHub, LinkedIn, or portfolio link',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
                validator: (value) {
                  final link = value?.trim() ?? '';

                  if (link.isEmpty) {
                    return null;
                  }

                  final uri = Uri.tryParse(link);

                  if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                    return 'Enter a complete link, for example https://github.com/name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _FieldLabel(
                label: 'Why are you interested?',
                textColor: textColor,
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: motivationController,
                enabled: !isLoading,
                maxLines: 6,
                maxLength: 500,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText:
                      'Explain why you are interested in this opportunity...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  final motivation = value?.trim() ?? '';

                  if (motivation.isEmpty) {
                    return 'Please write your motivation';
                  }

                  if (motivation.length < 30) {
                    return 'Please write at least 30 characters';
                  }

                  return null;
                },
              ),

              CheckboxListTile(
                value: agreedToTerms,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  'I confirm that the information provided is correct.',
                  style: TextStyle(color: textColor, fontSize: 14),
                ),
                onChanged: isLoading
                    ? null
                    : (value) {
                        setState(() {
                          agreedToTerms = value ?? false;
                        });
                      },
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : submitApplication,
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Application'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final Color textColor;
  final bool optional;

  const _FieldLabel({
    required this.label,
    required this.textColor,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
        ),
        if (optional) ...[
          const SizedBox(width: 5),
          const Text(
            '(Optional)',
            style: TextStyle(color: AppColors.mutedText, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
