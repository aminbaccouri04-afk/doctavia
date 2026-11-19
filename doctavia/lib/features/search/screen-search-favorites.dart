import 'package:flutter/material.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:doctavia/core/providers/provider-discovery.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/widgets/widget-shimmer-loaders.dart';
import 'package:doctavia/core/widgets/widget-empty-state.dart';
import 'package:doctavia/features/search/widgets/widget-search-doctor-mini-card.dart';

class ScreenSearchFavorites extends StatefulWidget {
  const ScreenSearchFavorites({super.key});

  @override
  State<ScreenSearchFavorites> createState() => _ScreenSearchFavoritesState();
}

class _ScreenSearchFavoritesState extends State<ScreenSearchFavorites> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoveryProvider>().fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscoveryProvider>();

    return WidgetScaffold(
      title: AppContent.get('search.screen.favorites'),
      body: provider.isLoading
          ? const ShimmerList(itemCount: 4, child: WidgetShimmerDoctorCard())
          : provider.favoriteDoctors.isEmpty
              ? WidgetEmptyState(
                  title: AppContent.get('search.screen.noFavorites'),
                  subtitle: AppContent.get('search.screen.noFavoritesSub'),
                  icon: Icons.favorite_border,
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  itemCount: provider.favoriteDoctors.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final doc = provider.favoriteDoctors[index];
                    return WidgetSearchDoctorMiniCard(
                      doctor: doc,
                      isFavorite: true,
                      onTap: () => context.push('/search/doctor/${doc.id}'),
                      onFavoriteToggle: () => provider.toggleDoctorFavorite(doc.id),
                    );
                  },
                ),
    );
  }
}
