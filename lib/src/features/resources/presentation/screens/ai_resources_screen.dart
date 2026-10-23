import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/app_color_scheme.dart';
import '../../../auth/domain/models/founder_profile.dart';
import '../../domain/models/resource_item.dart';
import '../../domain/repositories/resource_repository.dart';

class AIResourcesScreen extends StatefulWidget {
  const AIResourcesScreen({
    super.key,
    required this.profile,
    required this.resourceRepository,
  });

  final FounderProfile? profile;
  final ResourceRepository resourceRepository;

  @override
  State<AIResourcesScreen> createState() => _AIResourcesScreenState();
}

class _AIResourcesScreenState extends State<AIResourcesScreen> {
  ResourcesResult? _result;
  bool _isLoading = false;
  String? _error;
  String _filter = 'grants';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    final profile = widget.profile;
    if (profile == null ||
        profile.industry.trim().isEmpty ||
        profile.needs.isEmpty) {
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = refresh
          ? await widget.resourceRepository.refreshResources(profile)
          : await widget.resourceRepository.getResources(profile);
      if (mounted) {
        setState(() => _result = result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = _friendlyError(e));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _friendlyError(Object e) {
    debugPrint('[AIResourcesScreen] Error: $e');
    final msg = e.toString().toLowerCase();
    if (msg.contains('unauthenticated')) {
      return 'Please sign in again to access AI resources.';
    }
    if (msg.contains('permission-denied') || msg.contains('permission denied')) {
      return 'Access denied. Check Firestore rules and try again.';
    }
    if (msg.contains('not-found') || msg.contains('no documents')) {
      return 'Resources not yet available. Check back soon.';
    }
    if (msg.contains('network') ||
        msg.contains('unavailable') ||
        msg.contains('failed to fetch')) {
      return 'No connection. Check your network and try again.';
    }
    if (msg.contains('timeout') || msg.contains('deadline')) {
      return 'Request timed out. Please try again.';
    }
    return 'Could not load resources. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final businessName = profile?.businessName.trim();

    return SafeArea(
      child: Column(
        children: [
          _Header(businessName: businessName),
          _FilterRow(
            selected: _filter,
            onFilter: (f) => setState(() => _filter = f),
            onRefresh: _isLoading ? null : () => _load(refresh: true),
          ),
          Expanded(child: _body(profile)),
        ],
      ),
    );
  }

  Widget _body(FounderProfile? profile) {
    if (profile == null ||
        profile.industry.trim().isEmpty ||
        profile.needs.isEmpty) {
      return const _EmptyProfile();
    }
    if (_isLoading && _result == null) {
      return const _LoadingState();
    }
    if (_error != null && _result == null) {
      return _ErrorState(message: _error!, onRetry: () => _load());
    }
    final result = _result;
    if (result == null) {
      return const _LoadingState();
    }
    return _ResultList(result: result, filter: _filter);
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.businessName});

  final String? businessName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 40, 18, 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(color: context.colors.gold.withValues(alpha: .18)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Resources',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              color: context.colors.text,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            businessName != null && businessName!.isNotEmpty
                ? 'Personalised for $businessName'
                : 'Personalised for your business',
            style: TextStyle(color: context.colors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Filter row ────────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.selected,
    required this.onFilter,
    required this.onRefresh,
  });

  final String selected;
  final ValueChanged<String> onFilter;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(color: context.colors.gold.withValues(alpha: .18)),
        ),
      ),
      child: Row(
        children: [
          _Pill(label: 'Grants', active: selected == 'grants', onTap: () => onFilter('grants')),
          const SizedBox(width: 6),
          _Pill(label: 'Tools', active: selected == 'tools', onTap: () => onFilter('tools')),
          const SizedBox(width: 6),
          _Pill(label: 'Tips', active: selected == 'tips', onTap: () => onFilter('tips')),
          const Spacer(),
          GestureDetector(
            onTap: onRefresh,
            child: Opacity(
              opacity: onRefresh == null ? .4 : 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  border: Border.all(color: context.colors.gold.withValues(alpha: .18)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '↻  Refresh',
                  style: TextStyle(color: context.colors.muted, fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
        decoration: BoxDecoration(
          color: active ? context.colors.gold : Colors.transparent,
          border: Border.all(
            color: active
                ? context.colors.gold
                : context.colors.gold.withValues(alpha: .35),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? context.colors.background : context.colors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Result list ───────────────────────────────────────────────────────────────

class _ResultList extends StatelessWidget {
  const _ResultList({required this.result, required this.filter});

  final ResourcesResult result;
  final String filter;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
      children: switch (filter) {
        'grants' => result.grants.map((g) => _GrantCard(grant: g)).toList(),
        'tools' => result.tools.map((t) => _ToolCard(tool: t)).toList(),
        'tips' => result.tips.map((t) => _TipCard(tip: t)).toList(),
        _ => [],
      },
    );
  }
}

// ── Grant card ────────────────────────────────────────────────────────────────

class _GrantCard extends StatelessWidget {
  const _GrantCard({required this.grant});

  final GrantResource grant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border.all(color: context.colors.gold.withValues(alpha: .18)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              grant.name,
              style: TextStyle(
                fontFamily: 'Playfair Display',
                color: context.colors.text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.colors.gold.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    grant.amount,
                    style: TextStyle(
                      color: context.colors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  grant.deadline,
                  style: TextStyle(color: context.colors.dim, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              grant.description,
              style: TextStyle(
                color: context.colors.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            if (grant.eligibility.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '✓  ${grant.eligibility}',
                style: TextStyle(color: context.colors.green, fontSize: 11),
              ),
            ],
            if (grant.url.isNotEmpty) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _open(grant.url),
                child: Text(
                  'Learn more →',
                  style: TextStyle(
                    color: context.colors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ── Tool card ─────────────────────────────────────────────────────────────────

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool});

  final ToolResource tool;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border.all(color: context.colors.gold.withValues(alpha: .18)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    tool.name,
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      color: context.colors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: tool.isFree
                        ? context.colors.green.withValues(alpha: .14)
                        : context.colors.gold.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: tool.isFree
                          ? context.colors.green.withValues(alpha: .3)
                          : context.colors.gold.withValues(alpha: .2),
                    ),
                  ),
                  child: Text(
                    tool.isFree ? 'Free' : 'Paid',
                    style: TextStyle(
                      color: tool.isFree ? context.colors.green : context.colors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              tool.category,
              style: TextStyle(color: context.colors.gold, fontSize: 10),
            ),
            const SizedBox(height: 6),
            Text(
              tool.description,
              style: TextStyle(
                color: context.colors.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            if (tool.url.isNotEmpty) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _open(tool.url),
                child: Text(
                  'Open tool →',
                  style: TextStyle(
                    color: context.colors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ── Tip card ──────────────────────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final FounderTip tip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border.all(color: context.colors.gold.withValues(alpha: .18)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(tip.categoryEmoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip.title,
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      color: context.colors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tip.body,
              style: TextStyle(
                color: context.colors.muted,
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty / loading / error states ────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: context.colors.gold,
              strokeWidth: 2.5,
            ),
            const SizedBox(height: 20),
            Text(
              'Loading your resources…',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.muted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: context.colors.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(
                    color: context.colors.background,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProfile extends StatelessWidget {
  const _EmptyProfile();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✨', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 14),
            Text(
              'Complete your profile to unlock personalised grants, tools, and tips.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.muted,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add your industry and business needs in the Me tab.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.dim, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
