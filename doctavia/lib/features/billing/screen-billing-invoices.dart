import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/theme.dart';
import '../../../core/providers/provider-billing.dart';
import '../../../core/widgets/widget-doctavia-button.dart';
import '../../../core/providers/provider-content.dart';

class ScreenBillingInvoices extends StatefulWidget {
  const ScreenBillingInvoices({super.key});

  @override
  State<ScreenBillingInvoices> createState() => _ScreenBillingInvoicesState();
}

class _ScreenBillingInvoicesState extends State<ScreenBillingInvoices> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillingProvider>().fetchInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppContent.get('billing.screen.title')),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
      ),
      body: billing.isLoading && billing.invoices.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: billing.fetchInvoices,
              child: CustomScrollView(
                slivers: [
                  // --- Summary Card ---
                  SliverToBoxAdapter(
                    child: Container(
                      margin: EdgeInsets.all(AppSpacing.xl),
                      padding: EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, Color(0xFF6366F1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppContent.get('billing.screen.totalOutstanding'),
                            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            '${billing.totalPendingAmount.toStringAsFixed(2)} DZD',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale().fadeIn(),
                  ),

                  // --- Invoices List ---
                  if (billing.invoices.isEmpty)
                    SliverFillRemaining(
                      child: Center(child: Text(AppContent.get('billing.screen.noInvoices'))),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final invoice = billing.invoices[index];
                            return _InvoiceCard(invoice: invoice)
                                .animate()
                                .fadeIn(delay: Duration(milliseconds: 100 * index))
                                .slideX(begin: 0.1);
                          },
                          childCount: billing.invoices.length,
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
                ],
              ),
            ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final dynamic invoice;
  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = invoice.isPending;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.lg),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: (isPending ? AppColors.warning : AppColors.success).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPending ? Icons.account_balance_wallet_outlined : Icons.check_circle_outline,
                  color: isPending ? AppColors.warning : AppColors.success,
                  size: 24,
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppContent.get('billing.screen.consultation'),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      invoice.issuedAt != null
                          ? DateFormat('MMM dd, yyyy').format(invoice.issuedAt!)
                          : 'Recent',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              ),
              Text(
                '${invoice.amount.toStringAsFixed(2)} DZD',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
          if (isPending) ...[
            SizedBox(height: AppSpacing.lg),
            WidgetDoctaviaButton(
              text: AppContent.get('billing.screen.payNow'),
              onPressed: () => _showPaymentDialog(context),
            ),
          ],
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.payment_rounded, size: 48, color: AppColors.primary),
            SizedBox(height: AppSpacing.lg),
            Text(
              AppContent.get('billing.screen.confirmPayment'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              AppContent.get('billing.screen.confirmPrompt').replaceAll('{amount}', invoice.amount.toStringAsFixed(2)),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mutedForeground),
            ),
            SizedBox(height: AppSpacing.xl),
            WidgetDoctaviaButton(
              text: AppContent.get('billing.screen.confirmButton'),
              onPressed: () async {
                final success = await context.read<BillingProvider>().payInvoice(invoice.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppContent.get('billing.screen.paymentSuccess')), backgroundColor: AppColors.success),
                    );
                  }
                }
              },
            ),
            SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppContent.get('billing.screen.cancel'), style: const TextStyle(color: AppColors.mutedForeground)),
            ),
          ],
        ),
      ),
    );
  }
}
