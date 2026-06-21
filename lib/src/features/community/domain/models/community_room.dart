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
    id: 'general',
    emoji: '💬',
    title: 'General',
    subtitle: 'Open to all members',
    lastActive: '2 min ago',
  ),
  CommunityRoom(
    id: 'tech_innovation',
    emoji: '💻',
    title: 'Tech & Innovation',
    subtitle: 'Founders in tech',
    lastActive: '15 min ago',
  ),
  CommunityRoom(
    id: 'food_hospitality',
    emoji: '🍽',
    title: 'Food & Hospitality',
    subtitle: 'Restaurant & catering',
    lastActive: '1 hr ago',
  ),
  CommunityRoom(
    id: 'finance_funding',
    emoji: '📊',
    title: 'Finance & Funding',
    subtitle: 'Capital & legal',
    lastActive: 'Yesterday',
  ),
];

const accreditedLoungeRoom = CommunityRoom(
  id: 'accredited_lounge',
  emoji: '👑',
  title: 'Accredited Lounge',
  subtitle: 'FilAfrik Accredited only',
  lastActive: '',
  exclusive: true,
);
