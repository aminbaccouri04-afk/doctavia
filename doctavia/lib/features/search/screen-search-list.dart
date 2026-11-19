import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/widget-shimmer-loaders.dart';
import 'package:doctavia/core/providers/provider-discovery.dart';
import 'package:doctavia/core/providers/provider-specialty.dart';
import 'package:doctavia/features/search/widgets/widget-search-doctor-mini-card.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';

class ScreenSearchList extends StatefulWidget {
  final String? initialSpecialty;
  const ScreenSearchList({super.key, this.initialSpecialty});

  @override
  State<ScreenSearchList> createState() => _ScreenSearchListState();
}

class _ScreenSearchListState extends State<ScreenSearchList> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialSpecialty;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final specProv = context.read<SpecialtyProvider>();
      if (specProv.specialties.isEmpty) {
        specProv.fetchSpecialties();
      }
      context.read<DiscoveryProvider>().searchDoctors(specialty: _selectedCategory);
    });
  }

  void _triggerSearch() {
    context.read<DiscoveryProvider>().searchDoctors(specialty: _selectedCategory);
  }

  void _showSortSheet() {
    final provider = context.read<DiscoveryProvider>();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radius2xl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppContent.get('search.screen.sortBy'),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSortOption(provider, 'Rating', Icons.star_outline, AppContent.get('search.screen.topRated')),
            _buildSortOption(provider, 'Reviews', Icons.group_outlined, AppContent.get('search.screen.mostPopular')),
            _buildSortOption(provider, 'Name', Icons.sort_by_alpha, AppContent.get('search.screen.nameAZ')),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(DiscoveryProvider provider, String value, IconData icon, String label) {
    final isSelected = provider.currentSort == value;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : null),
      title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : null)),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        provider.sortResults(value);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<DiscoveryProvider>();
    final specProv = context.watch<SpecialtyProvider>();

    return WidgetScaffold(
      title: AppContent.get('search.screen.title'),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          tooltip: AppContent.get('search.screen.favorites'),
          onPressed: () => context.push('/search/favorites'),
        ),
        IconButton(
          icon: const Icon(Icons.map_outlined),
          tooltip: AppContent.get('search.screen.mapView'),
          onPressed: () => context.push('/map'),
        ),
      ],
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: AppContent.get('search.screen.searchHint'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: _showSortSheet,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                ),
                onSubmitted: (_) => _triggerSearch(),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: specProv.specialties.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = _selectedCategory == null;
                      return ChoiceChip(
                        label: Text(AppContent.get('search.screen.filterAll')),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = null;
                          });
                          _triggerSearch();
                        },
                      );
                    }

                    final cat = specProv.specialties[index - 1].name;
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? cat : null;
                        });
                        _triggerSearch();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.lg),

          Expanded(
            child: provider.isLoading 
              ? const ShimmerList(itemCount: 5, child: WidgetShimmerDoctorCard())
              : provider.errorMessage != null
                  ? Center(child: Text(provider.errorMessage!, style: TextStyle(color: theme.colorScheme.error)))
                  : provider.searchResults.isEmpty
                      ? Center(child: Text(AppContent.get('search.screen.noResults')))
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                          itemCount: provider.searchResults.length,
                          separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final doc = provider.searchResults[index];
                            return WidgetSearchDoctorMiniCard(
                              doctor: doc,
                              isFavorite: provider.isFavorite(doc.id),
                              onTap: () => context.push('/search/doctor/${doc.id}'),
                              onFavoriteToggle: () => provider.toggleDoctorFavorite(doc.id),
                            );
                          },
                        )
          ),
        ],
      ),
    );
  }
}


// _DoctorCard was replaced by WidgetSearchDoctorMiniCard for consistency
