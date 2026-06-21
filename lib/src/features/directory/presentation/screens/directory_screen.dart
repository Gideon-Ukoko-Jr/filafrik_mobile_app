import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/domain/models/founder_profile.dart';
import '../../domain/repositories/directory_repository.dart';
import '../widgets/directory_widgets.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({
    super.key,
    required this.directoryRepository,
    required this.onProfileSelected,
  });

  final DirectoryRepository directoryRepository;
  final ValueChanged<FounderProfile> onProfileSelected;

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedIndustry = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FounderProfile> _filterProfiles(List<FounderProfile> profiles) {
    final query = _searchController.text.trim().toLowerCase();

    return profiles.where((profile) {
      final matchesIndustry =
          _selectedIndustry == 'All' || profile.industry == _selectedIndustry;
      if (!matchesIndustry) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      return [
        profile.businessName,
        profile.displayName,
        profile.industry,
        profile.city,
        profile.website,
        profile.bio,
      ].whereType<String>().any((value) => value.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<FounderProfile>>(
        stream: widget.directoryRepository.watchFounderProfiles(),
        builder: (context, snapshot) {
          final profiles = snapshot.data ?? const <FounderProfile>[];
          final industries = [
            'All',
            ...profiles
                .map((profile) => profile.industry.trim())
                .where((industry) => industry.isNotEmpty)
                .toSet()
                .toList()
              ..sort(),
          ];

          if (!industries.contains(_selectedIndustry)) {
            _selectedIndustry = 'All';
          }

          final filteredProfiles = _filterProfiles(profiles);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DirectoryHeader(founderCount: profiles.length),
              DirectorySearchFilters(
                controller: _searchController,
                industries: industries,
                selectedIndustry: _selectedIndustry,
                onIndustrySelected: (industry) {
                  setState(() => _selectedIndustry = industry);
                },
                onSearchChanged: (_) => setState(() {}),
              ),
              Expanded(
                child: DirectoryResults(
                  isLoading:
                      snapshot.connectionState == ConnectionState.waiting,
                  profiles: filteredProfiles,
                  onProfileSelected: widget.onProfileSelected,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DirectoryHeader extends StatelessWidget {
  const DirectoryHeader({super.key, required this.founderCount});

  final int founderCount;

  @override
  Widget build(BuildContext context) {
    final subtitle = founderCount == 0
        ? 'No founder businesses available'
        : '$founderCount founders & businesses';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 37, 18, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.gold.withValues(alpha: .18)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppTitle('Directory', size: 19),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class DirectorySearchFilters extends StatelessWidget {
  const DirectorySearchFilters({
    super.key,
    required this.controller,
    required this.industries,
    required this.selectedIndustry,
    required this.onIndustrySelected,
    required this.onSearchChanged,
  });

  final TextEditingController controller;
  final List<String> industries;
  final String selectedIndustry;
  final ValueChanged<String> onIndustrySelected;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.gold.withValues(alpha: .18)),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 43,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withValues(alpha: .18)),
            ),
            child: Row(
              children: [
                const Text('🔍', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 7),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onSearchChanged,
                    cursorColor: AppColors.gold,
                    style: const TextStyle(color: AppColors.text, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Search businesses...',
                      hintStyle: TextStyle(color: AppColors.dim, fontSize: 13),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: 29,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final industry = industries[index];
                return DirectoryFilterPill(
                  label: industry,
                  selected: selectedIndustry == industry,
                  onTap: () => onIndustrySelected(industry),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemCount: industries.length,
            ),
          ),
        ],
      ),
    );
  }
}

class DirectoryResults extends StatelessWidget {
  const DirectoryResults({
    super.key,
    required this.isLoading,
    required this.profiles,
    required this.onProfileSelected,
  });

  final bool isLoading;
  final List<FounderProfile> profiles;
  final ValueChanged<FounderProfile> onProfileSelected;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }

    if (profiles.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No matching businesses available.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return DirectoryCard(
          profile: profile,
          onTap: () => onProfileSelected(profile),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 9),
      itemCount: profiles.length,
    );
  }
}
