import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/opportunity.dart';
import '../../providers/opportunity_provider.dart';

class CreateOpportunityScreen extends ConsumerStatefulWidget {
  final String startupName;

  const CreateOpportunityScreen({super.key, required this.startupName});

  @override
  ConsumerState<CreateOpportunityScreen> createState() {
    return _CreateOpportunityScreenState();
  }
}

class _CreateOpportunityScreenState
    extends ConsumerState<CreateOpportunityScreen> {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final skillsController = TextEditingController();
  final deadlineController = TextEditingController();

  String selectedCategory = 'Software Development';
  String selectedWorkType = 'Remote';

  DateTime? selectedDeadline;
  bool isLoading = false;

  final categories = [
    'Software Development',
    'Marketing',
    'Design',
    'Business Research',
    'Operations',
  ];

  final workTypes = ['Remote', 'On-site', 'Hybrid', 'Part-time'];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    skillsController.dispose();
    deadlineController.dispose();

    super.dispose();
  }

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  void publishOpportunity() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an application deadline.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You must sign in first.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    final skills = skillsController.text
        .split(',')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();

    final opportunity = Opportunity(
      id: '',
      startupId: user.uid,
      title: titleController.text.trim(),
      startupName: widget.startupName,
      category: selectedCategory,
      location: locationController.text.trim(),
      workType: selectedWorkType,
      deadline: selectedDeadline!,
      description: descriptionController.text.trim(),
      skills: skills,
      isActive: true,
      isVerified: false,
    );

    ref
        .read(opportunityRepositoryProvider)
        .createOpportunity(opportunity)
        .then((_) {
          if (!mounted) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opportunity published successfully.'),
            ),
          );

          Navigator.pop(context);
        })
        .catchError((error) {
          if (!mounted) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to publish opportunity: $error')),
          );
        })
        .whenComplete(() {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        });
  }

  void selectDeadline() {
    showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    ).then((date) {
      if (date == null || !mounted) {
        return;
      }

      setState(() {
        selectedDeadline = date;
        deadlineController.text = '${date.day}/${date.month}/${date.year}';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Opportunity')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _FieldTitle('Opportunity title'),
            TextFormField(
              controller: titleController,
              enabled: !isLoading,
              decoration: const InputDecoration(
                hintText: 'Example: Flutter Development Intern',
                prefixIcon: Icon(Icons.work_outline_rounded),
              ),
              validator: requiredValidator,
            ),
            const SizedBox(height: 18),
            const _FieldTitle('Category'),
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 18),
            const _FieldTitle('Work arrangement'),
            DropdownButtonFormField<String>(
              initialValue: selectedWorkType,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.schedule_outlined),
              ),
              items: workTypes.map((workType) {
                return DropdownMenuItem(value: workType, child: Text(workType));
              }).toList(),
              onChanged: isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          selectedWorkType = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 18),
            const _FieldTitle('Location'),
            TextFormField(
              controller: locationController,
              enabled: !isLoading,
              decoration: const InputDecoration(
                hintText: 'Example: Kigali, Rwanda',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: requiredValidator,
            ),
            const SizedBox(height: 18),
            const _FieldTitle('Required skills'),
            TextFormField(
              controller: skillsController,
              enabled: !isLoading,
              decoration: const InputDecoration(
                hintText: 'Flutter, Dart, Firebase',
                prefixIcon: Icon(Icons.psychology_outlined),
              ),
              validator: requiredValidator,
            ),
            const SizedBox(height: 18),
            const _FieldTitle('Application deadline'),
            TextFormField(
              controller: deadlineController,
              enabled: !isLoading,
              readOnly: true,
              decoration: const InputDecoration(
                hintText: 'Select deadline',
                prefixIcon: Icon(Icons.calendar_month_outlined),
              ),
              onTap: selectDeadline,
              validator: requiredValidator,
            ),
            const SizedBox(height: 18),
            const _FieldTitle('Description'),
            TextFormField(
              controller: descriptionController,
              enabled: !isLoading,
              maxLines: 6,
              maxLength: 800,
              decoration: const InputDecoration(
                hintText:
                    'Describe the role, responsibilities, and expected outcomes.',
              ),
              validator: (value) {
                if (value == null || value.trim().length < 30) {
                  return 'Write at least 30 characters';
                }

                return null;
              },
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: isLoading ? null : publishOpportunity,
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Publish Opportunity'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldTitle extends StatelessWidget {
  final String title;

  const _FieldTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
