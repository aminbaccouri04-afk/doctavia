import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doctavia/core/providers/provider-family.dart';
import 'package:doctavia/core/providers/provider-clinical.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/features/vault/widgets/widget-vault-profile-selector.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/widgets/widget-shimmer-loaders.dart';
import 'package:doctavia/features/vault/widgets/widget-vault-records-tab.dart';
import 'package:doctavia/features/vault/widgets/widget-vault-prescriptions-tab.dart';

class ScreenVaultDashboard extends StatefulWidget {
  const ScreenVaultDashboard({super.key});

  @override
  State<ScreenVaultDashboard> createState() => _ScreenVaultDashboardState();
}

class _ScreenVaultDashboardState extends State<ScreenVaultDashboard> with SingleTickerProviderStateMixin {
  int? _selectedProfileId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final familyProv = context.read<FamilyProvider>();
      if (familyProv.profiles.isEmpty) await familyProv.fetchProfiles();

      if (familyProv.selectedProfileId != null) {
        setState(() => _selectedProfileId = familyProv.selectedProfileId);
        _fetchData();
      } else if (familyProv.profiles.isNotEmpty) {
        final defaultId = familyProv.profiles.first.id;
        familyProv.setSelectedProfileId(defaultId);
        if (mounted) {
          setState(() => _selectedProfileId = defaultId);
          _fetchData();
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _fetchData() {
    if (_selectedProfileId == null) return;
    final clinicalProv = context.read<ClinicalProvider>();
    clinicalProv.fetchMedicalRecords(_selectedProfileId!);
    clinicalProv.fetchPrescriptions(_selectedProfileId!);
  }

  @override
  Widget build(BuildContext context) {
    final familyProv = context.watch<FamilyProvider>();
    final clinicalProv = context.watch<ClinicalProvider>();

    return WidgetScaffold(
      title: AppContent.get('vault.screen.title'),
      actions: [],

      appBarBottom: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Column(
          children: [
            WidgetVaultProfileSelector(
              provider: familyProv,
              selectedProfileId: _selectedProfileId,
              onSelected: (id) {
                familyProv.setSelectedProfileId(id);
                setState(() => _selectedProfileId = id);
                _fetchData();
              },
            ),
            TabBar(
               controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.mutedForeground,
              tabs: [
                Tab(text: AppContent.get('vault.screen.tabRecords')),
                Tab(text: AppContent.get('vault.screen.tabMeds')),
              ],
            ),
          ],
        ),
      ),
      hasHorizontalPadding: false,
      body: familyProv.isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              child: ShimmerList(itemCount: 4, child: RecordCardShimmer()),
            )
          : _selectedProfileId == null
              ? Center(child: Text(AppContent.get('vault.screen.selectProfile')))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    WidgetVaultRecordsTab(provider: clinicalProv, selectedProfileId: _selectedProfileId),
                    WidgetVaultPrescriptionsTab(provider: clinicalProv),
                  ],
                ),
    );
  }
}

