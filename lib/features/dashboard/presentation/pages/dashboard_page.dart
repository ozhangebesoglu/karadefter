import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kara_defter/core/di/injection_container.dart' as di;
import 'package:kara_defter/core/theme/app_theme.dart';
import 'package:kara_defter/core/utils/currency_utils.dart';
import 'package:kara_defter/features/dashboard/presentation/bloc/dashboard_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<DashboardBloc>()..add(LoadDashboard()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppTheme.accentColor,
                          strokeWidth: 4,
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Veriler Yükleniyor...',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is DashboardError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.error_outline,
                            size: 80,
                            color: AppTheme.errorColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Hata: ${state.message}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<DashboardBloc>().add(LoadDashboard());
                          },
                          icon: const Icon(Icons.refresh, size: 24),
                          label: const Text(
                            'Tekrar Dene',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is DashboardLoaded) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hoş Geldin Mesajı
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.accentColor.withOpacity(0.2),
                                AppTheme.accentColor.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.accentColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.waving_hand,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 20),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hoş Geldiniz!',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Kara Defter\'e hoş geldiniz. Alacak ve borçlarınızı kolayca takip edin.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Özet Kartları
                        _buildSummaryCards(state),
                        const SizedBox(height: 32),

                        // İstatistikler
                        _buildStatistics(state),
                        const SizedBox(height: 32),

                        // Hızlı İşlemler
                        _buildQuickActions(context),
                      ],
                    ),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accentColor,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics,
              color: AppTheme.accentColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              'Finansal Özet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Toplam Alacak',
                amount: CurrencyUtils.formatCurrency(state.totalCredit),
                color: AppTheme.creditColor,
                icon: Icons.trending_up,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.creditColor.withOpacity(0.2),
                    AppTheme.creditColor.withOpacity(0.1),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildSummaryCard(
                title: 'Toplam Borç',
                amount: CurrencyUtils.formatCurrency(state.totalDebit),
                color: AppTheme.debitColor,
                icon: Icons.trending_down,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.debitColor.withOpacity(0.2),
                    AppTheme.debitColor.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSummaryCard(
          title: 'Net Durum',
          amount: CurrencyUtils.formatCurrency(state.netBalance),
          color: state.netBalance >= 0
              ? AppTheme.creditColor
              : AppTheme.debitColor,
          icon: Icons.account_balance_wallet,
          gradient: LinearGradient(
            colors: [
              (state.netBalance >= 0
                      ? AppTheme.creditColor
                      : AppTheme.debitColor)
                  .withOpacity(0.2),
              (state.netBalance >= 0
                      ? AppTheme.creditColor
                      : AppTheme.debitColor)
                  .withOpacity(0.1),
            ],
          ),
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStatistics(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.insights,
              color: AppTheme.accentColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              'Genel İstatistikler',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Müşteri Sayısı',
                value: '${state.customerCount}',
                icon: Icons.people,
                color: AppTheme.infoColor,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.infoColor.withOpacity(0.2),
                    AppTheme.infoColor.withOpacity(0.1),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildStatCard(
                title: 'İşlem Sayısı',
                value: '${state.transactionCount}',
                icon: Icons.receipt_long,
                color: AppTheme.warningColor,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.warningColor.withOpacity(0.2),
                    AppTheme.warningColor.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 40,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required Color color,
    required IconData icon,
    required Gradient gradient,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppTheme.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            amount,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flash_on,
              color: AppTheme.accentColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              'Hızlı İşlemler',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                title: 'Alacak Ekle',
                subtitle: 'Yeni alacak kaydı',
                icon: Icons.add_circle,
                color: AppTheme.creditColor,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.creditColor.withOpacity(0.2),
                    AppTheme.creditColor.withOpacity(0.1),
                  ],
                ),
                onTap: () {
                  // Alacak ekleme sayfasına git
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildQuickActionCard(
                title: 'Borç Ekle',
                subtitle: 'Yeni borç kaydı',
                icon: Icons.remove_circle,
                color: AppTheme.debitColor,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.debitColor.withOpacity(0.2),
                    AppTheme.debitColor.withOpacity(0.1),
                  ],
                ),
                onTap: () {
                  // Borç ekleme sayfasına git
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                title: 'Müşteri Ekle',
                subtitle: 'Yeni müşteri kaydı',
                icon: Icons.person_add,
                color: AppTheme.infoColor,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.infoColor.withOpacity(0.2),
                    AppTheme.infoColor.withOpacity(0.1),
                  ],
                ),
                onTap: () {
                  // Müşteri ekleme sayfasına git
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildQuickActionCard(
                title: 'Rapor Görüntüle',
                subtitle: 'Detaylı raporlar',
                icon: Icons.assessment,
                color: AppTheme.warningColor,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.warningColor.withOpacity(0.2),
                    AppTheme.warningColor.withOpacity(0.1),
                  ],
                ),
                onTap: () {
                  // Rapor sayfasına git
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
