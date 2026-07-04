import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/opportunity.dart';
import '../../providers/opportunity_provider.dart';

class EditOpportunityScreen extends ConsumerStatefulWidget {
  final Opportunity opportunity;

  const EditOpportunityScreen({super.key, required this.opportunity});

  @override
  ConsumerState<EditOpportunityScreen> createState() {
    return _EditOpportunityScreenState();
  }
}

class _EditOpportunityScreenState extends ConsumerState<EditOpportunityScreen> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController locationController;
  late final TextEditingController skillsController;
  late final TextEditingController descriptionController;
  late final TextEditingController deadlineController;

  late String selectedCategory;
  late String selectedWorkType;
  late DateTime selectedDeadline;

  bool isSaving = false;

  final List<String> categories = [
    'Software Development',
    'Marketing',
    'Design',
    'Business Research',
    'Operations',
  ];

  final List<String> workTypes = ['Remote', 'On-site', 'Hybrid', 'Part-time'];

  @override
  void initState() {
    super.initState();

    final opportunity = widget.opportunity;

    titleController = TextEditingController(text: opportunity.title);

    locationController = TextEditingController(text: opportunity.location);

    skillsController = TextEditingController(
      text: opportunity.skills.join(', '),
    );

    descriptionController = TextEditingController(
      text: opportunity.description,
    );

    selectedCategory = categories.contains(opportunity.category)
        ? opportunity.category
        : categories.first;

    selectedWorkType = workTypes.contains(opportunity.workType)
        ? opportunity.workType
        : workTypes.first;

    selectedDeadline = opportunity.deadline;

    deadlineController = TextEditingController(
      text: formatDate(selectedDeadline),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    skillsController.dispose();
    descriptionController.dispose();
    deadlineController.dispose();

    super.dispose();
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  void showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void chooseDeadline() {
    showDatePicker(
      context: context,
      initialDate: selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    ).then((date) {
      if (date == null || !mounted) {
        return;
      }

      setState(() {
        selectedDeadline = date;
        deadlineController.text = formatDate(date);
      });
    });
  }

  void saveOpportunity() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    final skills = skillsController.text
        .split(',')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();

    final updatedOpportunity = widget.opportunity.copyWith(
      title: titleController.text.trim(),
      category: selectedCategory,
      location: locationController.text.trim(),
      workType: selectedWorkType,
      deadline: selectedDeadline,
      description: descriptionController.text.trim(),
      skills: skills,
    );

    ref
        .read(opportunityRepositoryProvider)
        .updateOpportunity(updatedOpportunity)
        .then((_) {
          if (!mounted) {
            return;
          }

          showMessage('Opportunity updated successfully.');

          Navigator.pop(context);
        })
        .catchError((error) {
          showMessage('Unable to update opportunity: $error');
        })
        .whenComplete(() {
          if (mounted) {
            setState(() {
              isSaving = false;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Opportunity')),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const _FieldLabel('Opportunity title'),

              TextFormField(
                controller: titleController,
                enabled: !isSaving,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.work_outline_rounded),
                ),
                validator: requiredValidator,
              ),

              const SizedBox(height: 18),

              const _FieldLabel('Category'),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          selectedCategory = value;
                        });
                      },
              ),

              const SizedBox(height: 18),

              const _FieldLabel('Work arrangement'),

              DropdownButtonFormField<String>(
                value: selectedWorkType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.schedule_outlined),
                ),
                items: workTypes.map((workType) {
                  return DropdownMenuItem(
                    value: workType,
                    child: Text(workType),
                  );
                }).toList(),
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          selectedWorkType = value;
                        });
                      },
              ),

              const SizedBox(height: 18),

              const _FieldLabel('Location'),

              TextFormField(
                controller: locationController,
                enabled: !isSaving,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: requiredValidator,
              ),

              const SizedBox(height: 18),

              const _FieldLabel('Required skills'),

              TextFormField(
                controller: skillsController,
                enabled: !isSaving,
                decoration: const InputDecoration(
                  hintText: 'Flutter, Dart, Firebase',
                  prefixIcon: Icon(Icons.psychology_outlined),
                ),
                validator: requiredValidator,
              ),

              const SizedBox(height: 18),

              const _FieldLabel('Application deadline'),

              TextFormField(
                controller: deadlineController,
                enabled: !isSaving,
                readOnly: true,
                onTap: chooseDeadline,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month_outlined),
                ),
                validator: requiredValidator,
              ),

              const SizedBox(height: 18),

              const _FieldLabel('Description'),

              TextFormField(
                controller: descriptionController,
                enabled: !isSaving,
                maxLines: 6,
                maxLength: 800,
                decoration: const InputDecoration(
                  hintText: 'Describe the opportunity.',
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 30) {
                    return 'Write at least 30 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 22),

              FilledButton.icon(
                onPressed: isSaving ? null : saveOpportunity,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
