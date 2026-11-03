class CommunityRoom {
  const CommunityRoom({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.lastActive,
    this.exclusive = false,
  });

  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final String lastActive;
  final bool exclusive;
}

const defaultCommunityRooms = [
  CommunityRoom(
    id: 'general_introductions',
    emoji: '👋',
    title: 'General Introductions',
    subtitle: 'Introduce yourself & connect',
    lastActive: '',
  ),
  CommunityRoom(
    id: 'capital_funding',
    emoji: '📊',
    title: 'Capital & Funding',
    subtitle: 'Grants, funding & investors',
    lastActive: '',
  ),
  CommunityRoom(
    id: 'marketing_digital_growth',
    emoji: '📣',
    title: 'Marketing & Digital Growth',
    subtitle: 'Brand, social & growth strategy',
    lastActive: '',
  ),
  CommunityRoom(
    id: 'ops_systems_professionalism',
    emoji: '🛠',
    title: 'Ops & Systems',
    subtitle: 'Operations, tools & professionalism',
    lastActive: '',
  ),
  CommunityRoom(
    id: 'scaling_hiring',
    emoji: '🚀',
    title: 'Scaling & Hiring',
    subtitle: 'Growth, team & hiring',
    lastActive: '',
  ),
];
