import 'package:flutter/material.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() {
    return _PersonalInformationScreenState();
  }
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController(text: 'Mugisha Blaine');

  final emailController = TextEditingController(text: 'student@alustudent.com');

  final phoneController = TextEditingController();

  final locationController = TextEditingController(text: 'Kigali, Rwanda');

  String selectedStudyYear = 'Year 1';

  final studyYears = ['Year 1', 'Year 2', 'Year 3', 'Year 4'];

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    super.dispose();
  }

  void saveInformation() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personal information saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Information')),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Update Your Information',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),

              const SizedBox(height: 8),

              Text(
                'Keep your profile details accurate and up to date.',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.65),
                ),
              ),

              const SizedBox(height: 25),

              const _FieldLabel('Full name'),

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

              const _FieldLabel('Email'),

              const SizedBox(height: 8),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
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

              const _FieldLabel('Phone number'),

              const SizedBox(height: 8),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Enter your phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),

              const SizedBox(height: 18),

              const _FieldLabel('Location'),

              const SizedBox(height: 8),

              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  hintText: 'Enter your location',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),

              const SizedBox(height: 18),

              const _FieldLabel('Current study year'),

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

              const SizedBox(height: 28),

              FilledButton(
                onPressed: saveInformation,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String title;

  const _FieldLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.w800));
  }
}
