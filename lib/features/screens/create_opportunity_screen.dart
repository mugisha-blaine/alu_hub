import 'package:flutter/material.dart';

class CreateOpportunityScreen extends StatefulWidget {
  const CreateOpportunityScreen({super.key});

  @override
  State<CreateOpportunityScreen> createState() {
    return _CreateOpportunityScreenState();
  }
}

class _CreateOpportunityScreenState extends State<CreateOpportunityScreen> {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final skillsController = TextEditingController();
  final deadlineController = TextEditingController();

  String selectedCategory = 'Software Development';
  String selectedWorkType = 'Remote';

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

  void publishOpportunity() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opportunity published successfully')),
    );

    Navigator.pop(context);
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
              onChanged: (value) {
                if (value != null) {
                  selectedCategory = value;
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
              onChanged: (value) {
                if (value != null) {
                  selectedWorkType = value;
                }
              },
            ),
            const SizedBox(height: 18),
            const _FieldTitle('Location'),
            TextFormField(
              controller: locationController,
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
              onPressed: publishOpportunity,
              child: const Text('Publish Opportunity'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> selectDeadline() async {
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      deadlineController.text =
          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
    }
  }

  static String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
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
