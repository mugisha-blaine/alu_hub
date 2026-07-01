import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/opportunity.dart';
import 'application_success_screen.dart';

class ApplicationFormScreen extends StatefulWidget {
  final Opportunity opportunity;

  const ApplicationFormScreen({super.key, required this.opportunity});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final motivationController = TextEditingController();
  final portfolioController = TextEditingController();

  String selectedStudyYear = 'Year 1';

  final List<String> studyYears = ['Year 1', 'Year 2', 'Year 3', 'Year 4'];

  bool agreedToTerms = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    motivationController.dispose();
    portfolioController.dispose();

    super.dispose();
  }

  void submitApplication() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm that your information is correct.'),
        ),
      );

      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationSuccessScreen(
          opportunityTitle: widget.opportunity.title,
          startupName: widget.opportunity.startupName,
        ),
      ),
    );
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
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _FieldLabel(label: 'ALU email', textColor: textColor),

              const SizedBox(height: 8),

              TextFormField(
                controller: emailController,
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
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Enter your phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _FieldLabel(label: 'Current study year', textColor: textColor),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedStudyYear,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: studyYears.map((year) {
                  return DropdownMenuItem(value: year, child: Text(year));
                }).toList(),
                onChanged: (value) {
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
                maxLines: 6,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText:
                      'Explain why you are interested in this opportunity...',
                  alignLabelWithHint: true,
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

              const SizedBox(height: 8),

              CheckboxListTile(
                value: agreedToTerms,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  'I confirm that the information provided is correct.',
                  style: TextStyle(color: textColor, fontSize: 14),
                ),
                onChanged: (value) {
                  setState(() {
                    agreedToTerms = value ?? false;
                  });
                },
              ),

              const SizedBox(height: 18),

              FilledButton(
                onPressed: submitApplication,
                child: const Text('Submit Application'),
              ),

              const SizedBox(height: 20),
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
