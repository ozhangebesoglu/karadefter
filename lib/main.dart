import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kara_defter/core/di/injection_container.dart' as di;
import 'package:kara_defter/core/theme/app_theme.dart';
import 'package:kara_defter/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:kara_defter/features/customer/presentation/pages/customer_transactions_page.dart';
import 'package:kara_defter/features/settings/presentation/pages/settings_page.dart';
import 'package:kara_defter/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:kara_defter/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:kara_defter/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:kara_defter/features/customer/domain/entities/customer_entity.dart';
import 'package:kara_defter/features/transaction/domain/entities/transaction_entity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const KaraDefterApp());
}

class KaraDefterApp extends StatelessWidget {
  const KaraDefterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CustomerBloc>(
          create: (context) => di.sl<CustomerBloc>(),
        ),
        BlocProvider<TransactionBloc>(
          create: (context) => di.sl<TransactionBloc>(),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => di.sl<DashboardBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Kara Defter',
        theme: AppTheme.darkTheme,
        home: const MainNavigationPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false;
  late AnimationController _animationController;
  late AnimationController _sidebarAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _sidebarAnimation;
  late Animation<double> _blurAnimation;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard,
      label: 'Ana Sayfa',
      page: const DashboardPage(),
    ),
    NavigationItem(
      icon: Icons.people,
      label: 'Müşteriler & İşlemler',
      page: const CustomerTransactionsPage(),
    ),
    NavigationItem(
      icon: Icons.settings,
      label: 'Ayarlar',
      page: const SettingsPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sidebarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _sidebarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sidebarAnimationController,
      curve: Curves.easeInOut,
    ));

    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sidebarAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    _sidebarAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _sidebarAnimationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
    
    if (_isSidebarOpen) {
      _sidebarAnimationController.forward();
    } else {
      _sidebarAnimationController.reverse();
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          // Ana İçerik
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _navigationItems[_selectedIndex].page,
              ),
            ),
          ),
          
          // Blur Overlay (Sidebar açıkken)
          AnimatedBuilder(
            animation: _blurAnimation,
            builder: (context, child) {
              return AnimatedOpacity(
                opacity: _isSidebarOpen ? _blurAnimation.value : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !_isSidebarOpen,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _isSidebarOpen ? 5.0 * _blurAnimation.value : 0.0,
                        sigmaY: _isSidebarOpen ? 5.0 * _blurAnimation.value : 0.0,
                      ),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Sidebar
          AnimatedBuilder(
            animation: _sidebarAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  _isSidebarOpen ? 0 : -280,
                  0,
                ),
                child: Container(
                  width: 280,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Logo ve Başlık
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.book,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'KARA DEFTER',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            const Text(
                              'Alacak Borç Takip',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: AppTheme.dividerColor, height: 1),
                      // Navigation Items
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: _navigationItems.length,
                          itemBuilder: (context, index) {
                            final item = _navigationItems[index];
                            final isSelected = _selectedIndex == index;
                            
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.accentColor.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: AppTheme.accentColor,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: ListTile(
                                leading: Icon(
                                  item.icon,
                                  size: 28,
                                  color: isSelected
                                      ? AppTheme.accentColor
                                      : AppTheme.textSecondaryColor,
                                ),
                                title: Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppTheme.accentColor
                                        : Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = index;
                                    _isSidebarOpen = false;
                                  });
                                  _sidebarAnimationController.reverse();
                                  _animationController.reset();
                                  _animationController.forward();
                                },
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Alt Bilgi
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Divider(color: AppTheme.dividerColor),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hoş Geldiniz',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Kara Defter v1.0',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Sidebar Toggle Button
          Positioned(
            top: 20,
            left: _isSidebarOpen ? 300 : 20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _toggleSidebar,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        _isSidebarOpen ? Icons.menu_open : Icons.menu,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1 || _selectedIndex == 2
          ? FloatingActionButton.extended(
              onPressed: () {
                _showQuickAddDialog(context);
              },
              backgroundColor: AppTheme.accentColor,
              icon: const Icon(Icons.add, size: 28),
              label: const Text(
                'Hızlı Ekle',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  void _showQuickAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const QuickAddDialog(),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Widget page;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.page,
  });
}

class QuickAddDialog extends StatefulWidget {
  const QuickAddDialog({super.key});

  @override
  State<QuickAddDialog> createState() => _QuickAddDialogState();
}

class _QuickAddDialogState extends State<QuickAddDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'credit';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.add_circle,
              color: AppTheme.accentColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              'Hızlı İşlem Ekle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Müşteri Adı',
                  labelStyle: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.person,
                    color: AppTheme.textSecondaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.accentColor,
                      width: 2,
                    ),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Müşteri adı gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Tutar (₺)',
                  labelStyle: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.attach_money,
                    color: AppTheme.textSecondaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.accentColor,
                      width: 2,
                    ),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tutar gerekli';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Geçerli bir tutar girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text(
                          'Alacak',
                          style: TextStyle(
                            color: AppTheme.creditColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: 'credit',
                        groupValue: _selectedType,
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                        activeColor: AppTheme.creditColor,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text(
                          'Borç',
                          style: TextStyle(
                            color: AppTheme.debitColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: 'debit',
                        groupValue: _selectedType,
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                        activeColor: AppTheme.debitColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'İptal',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                
                try {
                  // Önce müşteriyi ekle
                  final customerBloc = context.read<CustomerBloc>();
                  final customer = CustomerEntity(
                    id: null,
                    name: _nameController.text,
                    phone: '',
                    address: '',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  
                  customerBloc.add(AddCustomer(customer));
                  
                  // Kısa bir bekleme
                  await Future.delayed(const Duration(milliseconds: 500));
                  
                  // Müşteri ID'sini al
                  final customerState = customerBloc.state;
                  int? customerId;
                  
                  if (customerState is CustomerAdded) {
                    customerId = customerState.customer.id;
                  } else if (customerState is CustomerLoaded) {
                    customerId = customerState.customers.last.id;
                  }
                  
                  if (customerId != null) {
                    // İşlemi ekle
                    final transactionBloc = context.read<TransactionBloc>();
                    final transaction = TransactionEntity(
                      id: null,
                      amount: double.parse(_amountController.text),
                      description: 'Hızlı işlem: ${_nameController.text}',
                      customerId: customerId,
                      type: _selectedType == 'credit' ? TransactionType.credit : TransactionType.debit,
                      date: DateTime.now(),
                      createdAt: DateTime.now(),
                    );
                    
                    transactionBloc.add(AddTransaction(transaction));
                    
                    // Dashboard'u yenile
                    final dashboardBloc = context.read<DashboardBloc>();
                    dashboardBloc.add(LoadDashboard());
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${_nameController.text} için ${_amountController.text}₺ ${_selectedType == 'credit' ? 'alacak' : 'borç'} kaydedildi',
                        style: const TextStyle(fontSize: 16),
                      ),
                      backgroundColor: _selectedType == 'credit'
                          ? AppTheme.creditColor
                          : AppTheme.debitColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Hata: $e',
                        style: const TextStyle(fontSize: 16),
                      ),
                      backgroundColor: AppTheme.debitColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedType == 'credit'
                  ? AppTheme.creditColor
                  : AppTheme.debitColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Kaydet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
