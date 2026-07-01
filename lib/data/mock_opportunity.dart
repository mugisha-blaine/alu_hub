import '../models/opportunity.dart';

const List<Opportunity> mockOpportunities = [
  Opportunity(
    id: 'opportunity_1',
    title: 'Flutter Development Intern',
    startupName: 'AfriTech Solutions',
    category: 'Software Development',
    location: 'Kigali, Rwanda',
    workType: 'Hybrid',
    deadline: 'July 15, 2026',
    description:
        'Support the development of a mobile platform designed for African university students.',
    skills: ['Flutter', 'Dart', 'Firebase'],
    isVerified: true,
  ),
  Opportunity(
    id: 'opportunity_2',
    title: 'Digital Marketing Intern',
    startupName: 'Impact Media Lab',
    category: 'Marketing',
    location: 'Remote',
    workType: 'Remote',
    deadline: 'July 18, 2026',
    description:
        'Help create social media campaigns and digital content for youth-focused projects.',
    skills: ['Social Media', 'Content Creation', 'Communication'],
    isVerified: true,
  ),
  Opportunity(
    id: 'opportunity_3',
    title: 'Business Research Assistant',
    startupName: 'Growth Africa Network',
    category: 'Business Research',
    location: 'ALU Rwanda Campus',
    workType: 'Part-time',
    deadline: 'July 21, 2026',
    description:
        'Conduct market research and support business analysis for early-stage ventures.',
    skills: ['Research', 'Data Analysis', 'Report Writing'],
    isVerified: false,
  ),
  Opportunity(
    id: 'opportunity_4',
    title: 'UI/UX Design Intern',
    startupName: 'Kora Creative Studio',
    category: 'Design',
    location: 'Kigali, Rwanda',
    workType: 'On-site',
    deadline: 'July 25, 2026',
    description:
        'Design simple and accessible digital experiences for startup products.',
    skills: ['Figma', 'Wireframing', 'User Research'],
    isVerified: true,
  ),
];
