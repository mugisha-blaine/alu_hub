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

  String selectedStudyYear = 'Year 1';

  final List<String> studyYears = ['Year 1', 'Year 2', 'Year 3', 'Year 4'];

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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void submitApplication() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!agreedToTerms) {
      showMessage('Please confirm that your information is correct.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('You must sign in before applying.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final repository = ref.read(applicationRepositoryProvider);

    repository
        .hasAlreadyApplied(
          studentId: user.uid,
          opportunityId: widget.opportunity.id,
        )
        .then((alreadyApplied) {
          if (alreadyApplied) {
            throw Exception('You have already applied for this opportunity.');
          }

          final application = ApplicationModel(
            id: '',
            opportunityId: widget.opportunity.id,
            opportunityTitle: widget.opportunity.title,
            startupId: widget.opportunity.startupId,
            startupName: widget.opportunity.startupName,
            studentId: user.uid,
            studentName: fullNameController.text.trim(),
            studentEmail: emailController.text.trim(),
            phone: phoneController.text.trim(),
            studyYear: selectedStudyYear,
            portfolioUrl: portfolioController.text.trim(),
            motivation: motivationController.text.trim(),
            status: 'Submitted',
          );

          return repository.submitApplication(application);
        })
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
          if (!mounted) {
            return;
          }

          final message = error.toString().contains('already applied')
              ? 'You have already applied for this opportunity.'
              : 'Unable to submit application: $error';

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
                decoration: const InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: requiredValidator,
              ),

              const SizedBox(height: 18),

              _FieldLabel(label: 'ALU email', textColor: textColor),

              const SizedBox(height: 8),

              TextFormField(
                controller: emailController,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter your ALU email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }

                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
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
                decoration: const InputDecoration(
                  hintText: 'Enter your phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: requiredValidator,
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
                  return DropdownMenuItem(value: year, child: Text(year));
                }).toList(),
                onChanged: isLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            selectedStudyYear = value;
                          });
                        }
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
                decoration: const InputDecoration(
                  hintText: 'GitHub, LinkedIn, or portfolio link',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
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
                decoration: const InputDecoration(
                  hintText:
                      'Explain why you are interested in this opportunity...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please write your motivation';
                  }

                  if (value.trim().length < 30) {
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

              FilledButton(
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
            ],
          ),
        ),
      ),
    );
  }

  static String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
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
