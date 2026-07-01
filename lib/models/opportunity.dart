class Opportunity {
  final String id;
  final String title;
  final String startupName;
  final String category;
  final String location;
  final String workType;
  final String deadline;
  final String description;
  final List<String> skills;
  final bool isVerified;

  const Opportunity({
    required this.id,
    required this.title,
    required this.startupName,
    required this.category,
    required this.location,
    required this.workType,
    required this.deadline,
    required this.description,
    required this.skills,
    this.isVerified = false,
  });
}
