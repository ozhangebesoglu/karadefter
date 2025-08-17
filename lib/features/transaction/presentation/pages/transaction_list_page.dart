import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kara_defter/core/di/injection_container.dart' as di;
import 'package:kara_defter/core/theme/app_theme.dart';
import 'package:kara_defter/core/utils/currency_utils.dart';
import 'package:kara_defter/core/utils/date_utils.dart' as app_date_utils;
import 'package:kara_defter/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:kara_defter/features/transaction/domain/entities/transaction_entity.dart';
import 'package:kara_defter/features/customer/domain/entities/customer_entity.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

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
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // İşlemleri yükle
    context.read<TransactionBloc>().add(LoadTransactions());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'İşlemler',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Alacak ve borç işlemleri',
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
                const SizedBox(height: 32),

                // Filtreler ve Arama
                Row(
                  children: [
                    // Filtre Butonları
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildFilterButton('all', 'Tümü', Icons.list),
                            _buildFilterButton(
                                'credit', 'Alacak', Icons.trending_up),
                            _buildFilterButton(
                                'debit', 'Borç', Icons.trending_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Arama Çubuğu
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          decoration: InputDecoration(
                            hintText: 'İşlem ara...',
                            hintStyle: const TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 18,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppTheme.textSecondaryColor,
                              size: 28,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          onChanged: (value) {
                            if (value.isEmpty) {
                              _loadTransactions();
                            } else {
                              context
                                  .read<TransactionBloc>()
                                  .add(SearchTransactions(value));
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // İşlem Listesi
                Expanded(
                  child: BlocBuilder<TransactionBloc, TransactionState>(
                    builder: (context, state) {
                      if (state is TransactionLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.accentColor,
                            strokeWidth: 3,
                          ),
                        );
                      } else if (state is TransactionError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: AppTheme.debitColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Hata: ${state.message}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  _loadTransactions();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Tekrar Dene',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (state is TransactionLoaded) {
                        final filteredTransactions =
                            _filterTransactions(state.transactions);

                        if (filteredTransactions.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_outlined,
                                  size: 64,
                                  color: AppTheme.textSecondaryColor,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Henüz işlem yok',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'İlk işleminizi ekleyerek başlayın',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _showAddTransactionDialog(context);
                                  },
                                  icon: const Icon(Icons.add, size: 24),
                                  label: const Text(
                                    'İşlem Ekle',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
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
                        }

                        return ListView.builder(
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = filteredTransactions[index];
                            return AnimatedContainer(
                              duration:
                                  Duration(milliseconds: 300 + (index * 100)),
                              margin: const EdgeInsets.only(bottom: 16),
                              child: _buildTransactionCard(transaction, index),
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedFilter = value;
            });
            _loadTransactions();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accentColor.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? AppTheme.accentColor
                      : AppTheme.textSecondaryColor,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? AppTheme.accentColor
                        : AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<TransactionEntity> _filterTransactions(
      List<TransactionEntity> transactions) {
    switch (_selectedFilter) {
      case 'credit':
        return transactions
            .where((t) => t.type == TransactionType.credit)
            .toList();
      case 'debit':
        return transactions
            .where((t) => t.type == TransactionType.debit)
            .toList();
      default:
        return transactions;
    }
  }

  void _loadTransactions() {
    context.read<TransactionBloc>().add(LoadTransactions());
  }

  Widget _buildTransactionCard(TransactionEntity transaction, int index) {
    final isCredit = transaction.type == TransactionType.credit;
    final amountColor = isCredit ? AppTheme.creditColor : AppTheme.debitColor;
    final typeText = isCredit ? 'Alacak' : 'Borç';
    final typeIcon = isCredit ? Icons.trending_up : Icons.trending_down;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showTransactionDetailsDialog(context, transaction);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // İşlem Tipi İkonu
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: amountColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: amountColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    typeIcon,
                    color: amountColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // İşlem Bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description ?? 'Açıklama yok',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Müşteri: ${transaction.customerId}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app_date_utils.DateUtils.formatDate(transaction.date),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tutar ve İşlem Butonları
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyUtils.formatCurrencyCompact(transaction.amount),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      typeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: amountColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            _showEditTransactionDialog(context, transaction);
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: AppTheme.accentColor,
                            size: 20,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _showDeleteConfirmation(context, transaction);
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: AppTheme.debitColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TransactionDialog(),
    );
  }

  void _showEditTransactionDialog(
      BuildContext context, TransactionEntity transaction) {
    showDialog(
      context: context,
      builder: (context) => TransactionDialog(transaction: transaction),
    );
  }

  void _showTransactionDetailsDialog(
      BuildContext context, TransactionEntity transaction) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailsDialog(transaction: transaction),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, TransactionEntity transaction) {
    final isCredit = transaction.type == TransactionType.credit;
    final typeText = isCredit ? 'alacak' : 'borç';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppTheme.debitColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              'İşlemi Sil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          '${transaction.description} işlemini (${CurrencyUtils.formatCurrencyCompact(transaction.amount)} $typeText) silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
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
            onPressed: () {
              context
                  .read<TransactionBloc>()
                  .add(DeleteTransaction(transaction.id ?? 0));
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.debitColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Sil',
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

class TransactionDialog extends StatefulWidget {
  final TransactionEntity? transaction;

  const TransactionDialog({super.key, this.transaction});

  @override
  State<TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _customerIdController = TextEditingController();
  TransactionType _selectedType = TransactionType.credit;
  DateTime _selectedDate = DateTime.now();
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

    if (widget.transaction != null) {
      _descriptionController.text = widget.transaction!.description ?? '';
      _amountController.text = widget.transaction!.amount.toString();
      _customerIdController.text = widget.transaction!.customerId.toString();
      _selectedType = widget.transaction!.type;
      _selectedDate = widget.transaction!.date;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _customerIdController.dispose();
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
              widget.transaction != null ? Icons.edit : Icons.add_circle,
              color: AppTheme.accentColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              widget.transaction != null ? 'İşlemi Düzenle' : 'Yeni İşlem',
              style: const TextStyle(
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
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  labelStyle: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.description,
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
                    return 'Açıklama gerekli';
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
              TextFormField(
                controller: _customerIdController,
                decoration: InputDecoration(
                  labelText: 'Müşteri ID',
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
                    return 'Müşteri ID gerekli';
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
                      child: RadioListTile<TransactionType>(
                        title: const Text(
                          'Alacak',
                          style: TextStyle(
                            color: AppTheme.creditColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: TransactionType.credit,
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
                      child: RadioListTile<TransactionType>(
                        title: const Text(
                          'Borç',
                          style: TextStyle(
                            color: AppTheme.debitColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: TransactionType.debit,
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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (widget.transaction != null) {
                  context.read<TransactionBloc>().add(
                        UpdateTransaction(
                          TransactionEntity(
                            id: widget.transaction!.id,
                            customerId: int.parse(_customerIdController.text),
                            amount: double.parse(_amountController.text),
                            type: _selectedType,
                            description: _descriptionController.text,
                            date: _selectedDate,
                            createdAt: widget.transaction!.createdAt,
                          ),
                        ),
                      );
                } else {
                  context.read<TransactionBloc>().add(
                        AddTransaction(
                          TransactionEntity(
                            id: null,
                            customerId: int.parse(_customerIdController.text),
                            amount: double.parse(_amountController.text),
                            type: _selectedType,
                            description: _descriptionController.text,
                            date: _selectedDate,
                            createdAt: DateTime.now(),
                          ),
                        ),
                      );
                }
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.transaction != null ? 'Güncelle' : 'Ekle',
              style: const TextStyle(
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

class TransactionDetailsDialog extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionDetailsDialog({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == TransactionType.credit;
    final amountColor = isCredit ? AppTheme.creditColor : AppTheme.debitColor;
    final typeText = isCredit ? 'Alacak' : 'Borç';
    final typeIcon = isCredit ? Icons.trending_up : Icons.trending_down;

    return AlertDialog(
      backgroundColor: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: amountColor,
                width: 2,
              ),
            ),
            child: Icon(
              typeIcon,
              color: amountColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              transaction.description ?? 'Açıklama yok',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
              Icons.attach_money,
              'Tutar',
              CurrencyUtils.formatCurrencyCompact(transaction.amount),
              amountColor),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.category, 'Tip', typeText, amountColor),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person, 'Müşteri ID',
              transaction.customerId.toString(), null),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today, 'Tarih',
              app_date_utils.DateUtils.formatDate(transaction.date), null),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.dividerColor),
          const SizedBox(height: 16),
          const Text(
            'Bu işlem ile ilgili detaylar burada görüntülenecek',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Kapat',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, Color? valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.textSecondaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
