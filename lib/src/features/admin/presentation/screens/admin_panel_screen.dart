import 'package:flutter/material.dart';

import '../../../../core/app_color_scheme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/domain/models/founder_profile.dart';
import '../../../community/domain/models/community_message.dart';
import '../../domain/models/admin_stats.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({
    super.key,
    required this.adminRepository,
    required this.onBack,
  });

  final AdminRepository adminRepository;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            _AdminHeader(onBack: onBack),
            Container(
              color: context.colors.surface,
              child: TabBar(
                labelColor: context.colors.gold,
                unselectedLabelColor: context.colors.muted,
                indicatorColor: context.colors.gold,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: context.colors.gold.withValues(alpha: .14),
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Members'),
                  Tab(text: 'Announce'),
                  Tab(text: 'Moderation'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _OverviewTab(adminRepository: adminRepository),
                  _MembersTab(adminRepository: adminRepository),
                  _AnnounceTab(adminRepository: adminRepository),
                  _ModerationTab(adminRepository: adminRepository),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 37, 18, 14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(color: context.colors.gold.withValues(alpha: .18)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Text(
              '←',
              style: TextStyle(color: context.colors.muted, fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          const AppTitle('Admin Panel', size: 19),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: context.colors.red.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.colors.red.withValues(alpha: .3)),
            ),
            child: Text(
              'FilAfrik Team',
              style: TextStyle(
                color: context.colors.red,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overview tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.adminRepository});

  final AdminRepository adminRepository;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminStats>(
      future: adminRepository.loadStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data;
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 104),
          children: [
            const SectionLabel('PLATFORM OVERVIEW'),
            const SizedBox(height: 10),
            _StatTile(
              emoji: '👥',
              label: 'Total Members',
              value: stats?.totalMembers.toString() ?? '...',
            ),
            const SizedBox(height: 8),
            _StatTile(
              emoji: '🆕',
              label: 'New This Week',
              value: stats?.newThisWeek.toString() ?? '...',
            ),
            const SizedBox(height: 8),
            _StatTile(
              emoji: '💬',
              label: 'Active Chat Rooms',
              value: stats?.activeRooms.toString() ?? '...',
            ),
            const SizedBox(height: 24),
            const SectionLabel('ADMIN ACTIONS'),
            const SizedBox(height: 10),
            const _AdminActionNote(
              emoji: '🏅',
              text:
                  'Grant or revoke Accredited status from the Members tab or directly on a business profile in the Directory.',
            ),
            const SizedBox(height: 8),
            const _AdminActionNote(
              emoji: '📢',
              text:
                  'Post announcements to all members from the Announce tab. They will receive an in-app notification.',
            ),
            const SizedBox(height: 8),
            const _AdminActionNote(
              emoji: '🛡️',
              text:
                  'Review and delete community posts from the Moderation tab.',
            ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: context.colors.muted, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: context.colors.gold,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              fontFamily: 'Playfair Display',
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminActionNote extends StatelessWidget {
  const _AdminActionNote({required this.emoji, required this.text});

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: context.colors.gold.withValues(alpha: .14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.colors.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Members tab ───────────────────────────────────────────────────────────────

class _MembersTab extends StatefulWidget {
  const _MembersTab({required this.adminRepository});

  final AdminRepository adminRepository;

  @override
  State<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<_MembersTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FounderProfile> _filtered(List<FounderProfile> members) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return members;
    return members.where((m) {
      return m.displayName.toLowerCase().contains(q) ||
          m.businessName.toLowerCase().contains(q) ||
          m.email.toLowerCase().contains(q) ||
          m.industry.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            height: 43,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.gold.withValues(alpha: .18),
              ),
            ),
            child: Row(
              children: [
                const Text('🔍', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 7),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    cursorColor: context.colors.gold,
                    style: TextStyle(color: context.colors.text, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search members...',
                      hintStyle:
                          TextStyle(color: context.colors.dim, fontSize: 13),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<FounderProfile>>(
            stream: widget.adminRepository.watchAllMembers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: context.colors.gold),
                );
              }
              final members = _filtered(snapshot.data ?? []);
              if (members.isEmpty) {
                return Center(
                  child: Text(
                    'No members found.',
                    style: TextStyle(color: context.colors.muted),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 104),
                itemCount: members.length,
                separatorBuilder: (_, i) => const SizedBox(height: 7),
                itemBuilder: (context, index) => _MemberRow(
                  member: members[index],
                  adminRepository: widget.adminRepository,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MemberRow extends StatefulWidget {
  const _MemberRow({required this.member, required this.adminRepository});

  final FounderProfile member;
  final AdminRepository adminRepository;

  @override
  State<_MemberRow> createState() => _MemberRowState();
}

class _MemberRowState extends State<_MemberRow> {
  bool _isToggling = false;
  late bool _isAccredited;

  @override
  void initState() {
    super.initState();
    _isAccredited = widget.member.isAccredited;
  }

  @override
  void didUpdateWidget(covariant _MemberRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isToggling) {
      _isAccredited = widget.member.isAccredited;
    }
  }

  Future<void> _toggle() async {
    if (_isToggling) return;
    setState(() => _isToggling = true);
    try {
      final newValue = !_isAccredited;
      await widget.adminRepository.setAccreditation(
        widget.member.uid,
        isAccredited: newValue,
      );
      if (mounted) setState(() => _isAccredited = newValue);
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials(widget.member.displayName);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.gold.withValues(alpha: .18)),
      ),
      child: Row(
        children: [
          Avatar(initials: initials),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.member.displayName.trim().isEmpty
                      ? 'Unnamed'
                      : widget.member.displayName,
                  style: TextStyle(
                    color: context.colors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.member.businessName.trim().isEmpty
                      ? widget.member.email
                      : widget.member.businessName,
                  style: TextStyle(color: context.colors.muted, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (_isToggling)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: context.colors.gold,
                strokeWidth: 1.5,
              ),
            )
          else
            GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _isAccredited
                      ? context.colors.gold.withValues(alpha: .15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isAccredited
                        ? context.colors.gold
                        : context.colors.muted.withValues(alpha: .35),
                  ),
                ),
                child: Text(
                  _isAccredited ? 'Accredited' : 'Listed',
                  style: TextStyle(
                    color: _isAccredited
                        ? context.colors.gold
                        : context.colors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'FC';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }
}

// ── Announce tab ──────────────────────────────────────────────────────────────

class _AnnounceTab extends StatefulWidget {
  const _AnnounceTab({required this.adminRepository});

  final AdminRepository adminRepository;

  @override
  State<_AnnounceTab> createState() => _AnnounceTabState();
}

class _AnnounceTabState extends State<_AnnounceTab> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isPinned = false;
  bool _isPosting = false;
  String? _successMessage;
  String? _errorText;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      setState(() => _errorText = 'Title and content are required.');
      return;
    }
    if (_isPosting) return;
    setState(() {
      _isPosting = true;
      _errorText = null;
      _successMessage = null;
    });
    try {
      await widget.adminRepository.postAnnouncement(
        title: title,
        content: content,
        isPinned: _isPinned,
      );
      if (mounted) {
        _titleController.clear();
        _contentController.clear();
        setState(() {
          _isPinned = false;
          _successMessage = 'Announcement posted to all members.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorText = 'Failed to post. Try again.');
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 104),
      children: [
        const SectionLabel('NEW ANNOUNCEMENT'),
        const SizedBox(height: 10),
        AppTextField(
          label: 'Title',
          controller: _titleController,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 10),
        AppTextField(
          label: 'Content',
          controller: _contentController,
          maxLines: 5,
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.gold.withValues(alpha: .18),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Pin announcement',
                style: TextStyle(color: context.colors.muted, fontSize: 13),
              ),
              const Spacer(),
              Switch(
                value: _isPinned,
                onChanged: (v) => setState(() => _isPinned = v),
                activeThumbColor: context.colors.gold,
                activeTrackColor: context.colors.gold.withValues(alpha: .4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_errorText != null) ErrorMessage(_errorText!),
        if (_successMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              _successMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        PrimaryButton(
          label: _isPosting ? 'Posting...' : 'Post to All Members',
          onPressed: _isPosting ? () {} : _post,
        ),
        const SizedBox(height: 28),
        const SectionLabel('RECENT ANNOUNCEMENTS'),
        const SizedBox(height: 10),
        _RecentAnnouncements(adminRepository: widget.adminRepository),
      ],
    );
  }
}

class _RecentAnnouncements extends StatelessWidget {
  const _RecentAnnouncements({required this.adminRepository});

  final AdminRepository adminRepository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: adminRepository.watchAnnouncements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: context.colors.gold,
                strokeWidth: 1.5,
              ),
            ),
          );
        }
        final announcements = snapshot.data ?? [];
        if (announcements.isEmpty) {
          return Text(
            'No announcements yet.',
            style: TextStyle(color: context.colors.muted, fontSize: 12),
          );
        }
        return Column(
          children: announcements.map((ann) {
            final title = ann['title'] as String? ?? 'Untitled';
            final content = ann['content'] as String? ?? '';
            final isPinned = ann['isPinned'] as bool? ?? false;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: context.colors.gold
                        .withValues(alpha: isPinned ? .3 : .18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isPinned) ...[
                          const Text('📌', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: context.colors.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content.length > 100
                          ? '${content.substring(0, 100)}...'
                          : content,
                      style: TextStyle(
                        color: context.colors.muted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ── Moderation tab ────────────────────────────────────────────────────────────

class _ModerationTab extends StatelessWidget {
  const _ModerationTab({required this.adminRepository});

  final AdminRepository adminRepository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CommunityMessage>>(
      stream: adminRepository.watchRecentPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: context.colors.gold),
          );
        }
        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No posts to moderate.',
                style: TextStyle(color: context.colors.muted),
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
          itemCount: posts.length,
          separatorBuilder: (_, i) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _PostRow(
            post: posts[index],
            adminRepository: adminRepository,
          ),
        );
      },
    );
  }
}

class _PostRow extends StatefulWidget {
  const _PostRow({required this.post, required this.adminRepository});

  final CommunityMessage post;
  final AdminRepository adminRepository;

  @override
  State<_PostRow> createState() => _PostRowState();
}

class _PostRowState extends State<_PostRow> {
  bool _isDeleting = false;

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.colors.surface,
        title: Text(
          'Delete Post?',
          style: TextStyle(color: ctx.colors.text, fontSize: 16),
        ),
        content: Text(
          '"${widget.post.content.length > 80 ? '${widget.post.content.substring(0, 80)}...' : widget.post.content}"',
          style: TextStyle(color: ctx.colors.muted, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: ctx.colors.muted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFB05050)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isDeleting = true);
    try {
      await widget.adminRepository.deletePost(widget.post.id);
    } catch (_) {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: context.colors.gold.withValues(alpha: .18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.post.roomId,
                      style: TextStyle(
                        color: context.colors.gold,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '· ${widget.post.authorName}',
                        style: TextStyle(
                          color: context.colors.muted,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      widget.post.displayTime,
                      style: TextStyle(
                        color: context.colors.dim,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  widget.post.content.length > 120
                      ? '${widget.post.content.substring(0, 120)}...'
                      : widget.post.content,
                  style: TextStyle(
                    color: context.colors.text,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (_isDeleting)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Color(0xFFB05050),
                strokeWidth: 1.5,
              ),
            )
          else
            GestureDetector(
              onTap: _confirmDelete,
              child: Icon(
                Icons.delete_outline,
                color: const Color(0xFFB05050).withValues(alpha: .7),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
