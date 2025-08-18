import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kara_defter/core/theme/app_theme.dart';
import 'package:kara_defter/core/utils/currency_utils.dart';
import 'package:kara_defter/core/utils/date_utils.dart' as app_date_utils;
import 'package:kara_defter/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:kara_defter/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:kara_defter/features/customer/domain/entities/customer_entity.dart';
import 'package:kara_defter/features/transaction/domain/entities/transaction_entity.dart';

class CustomerTransactionsPage extends StatefulWidget {
  const CustomerTransactionsPage({super.key});

  @override
  State<CustomerTransactionsPage> createState() => _CustomerTransactionsPageState();
}

class _CustomerTransactionsPageState extends State<CustomerTransactionsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  String? _selectedCustomer;
  bool _showTransactions = false;

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

    // Müşterileri ve işlemleri yükle
    context.read<CustomerBloc>().add(LoadCustomers());
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
                      child: Icon(
                        _showTransactions ? Icons.receipt_long : Icons.people,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _showTransactions ? 'İşlemler' : 'Müşteriler',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _showTransactions 
                                ? 'Müşteri işlemleri ve takibi'
                                : 'Müşteri listesi ve yönetimi',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Toggle butonu
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showTransactions = !_showTransactions;
                          _selectedCustomer = null;
                        });
                      },
                      icon: Icon(
                        _showTransactions ? Icons.people : Icons.receipt_long,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Arama ve filtreleme
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: _showTransactions 
                                ? 'İşlem ara...'
                                : 'Müşteri ara...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          onChanged: (value) {
                            if (_showTransactions) {
                              context.read<TransactionBloc>().add(SearchTransactions(value));
                            } else {
                              context.read<CustomerBloc>().add(SearchCustomers(value));
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_showTransactions)
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFilter,
                            dropdownColor: AppTheme.surfaceColor,
                            style: const TextStyle(color: Colors.white),
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('Tümü')),
                              DropdownMenuItem(value: 'credit', child: Text('Alacak')),
                              DropdownMenuItem(value: 'debit', child: Text('Borç')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedFilter = value!;
                              });
                            },
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // İçerik
                Expanded(
                  child: _showTransactions 
                      ? _buildTransactionsContent()
                      : _buildCustomersContent(),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showQuickTransactionDialog(context);
        },
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCustomersContent() {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CustomerLoaded) {
          return ListView.builder(
            itemCount: state.customers.length,
            itemBuilder: (context, index) {
              final customer = state.customers[index];
              return _buildCustomerCard(customer);
            },
          );
        } else if (state is CustomerError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('Müşteri bulunamadı'));
      },
    );
  }

  Widget _buildTransactionsContent() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TransactionLoaded) {
          List<TransactionEntity> filteredTransactions = state.transactions;
          
          // Müşteri filtresi
          if (_selectedCustomer != null) {
            filteredTransactions = filteredTransactions
                .where((t) => t.customerName == _selectedCustomer)
                .toList();
          }
          
          // Tip filtresi
          if (_selectedFilter != 'all') {
            filteredTransactions = filteredTransactions
                .where((t) => t.type.toString().split('.').last == _selectedFilter)
                .toList();
          }

          return ListView.builder(
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              final transaction = filteredTransactions[index];
              return _buildTransactionCard(transaction);
            },
          );
        } else if (state is TransactionError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('İşlem bulunamadı'));
      },
    );
  }

  Widget _buildCustomerCard(CustomerEntity customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentColor,
          child: Text(
            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.phone != null && customer.phone!.isNotEmpty)
              Text(
                customer.phone!,
                style: const TextStyle(color: Colors.grey),
              ),
            if (customer.address != null && customer.address!.isNotEmpty)
              Text(
                customer.address!,
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedCustomer = customer.name;
                  _showTransactions = true;
                });
              },
              icon: const Icon(Icons.receipt_long, color: Colors.blue),
            ),
            IconButton(
              onPressed: () {
                _showQuickTransactionDialog(context, customerName: customer.name);
              },
              icon: const Icon(Icons.add, color: AppTheme.accentColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionEntity transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: CircleAvatar(
          backgroundColor: transaction.type == TransactionType.credit 
              ? Colors.green 
              : Colors.red,
          child: Icon(
            transaction.type == TransactionType.credit 
                ? Icons.arrow_upward 
                : Icons.arrow_downward,
            color: Colors.white,
          ),
        ),
        title: Text(
          transaction.customerName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.description != null && transaction.description!.isNotEmpty)
              Text(
                transaction.description!,
                style: const TextStyle(color: Colors.grey),
              ),
            Text(
              app_date_utils.DateUtils.formatDate(transaction.date),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyUtils.formatCurrency(transaction.amount),
              style: TextStyle(
                color: transaction.type == TransactionType.credit 
                    ? Colors.green 
                    : Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              transaction.type == TransactionType.credit ? 'Alacak' : 'Borç',
              style: TextStyle(
                color: transaction.type == TransactionType.credit 
                    ? Colors.green 
                    : Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickTransactionDialog(BuildContext context, {String? customerName}) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    TransactionType selectedType = TransactionType.credit;
    String selectedCustomer = customerName ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Hızlı İşlem Ekle',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Müşteri seçimi
            if (customerName == null)
              BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, state) {
                  if (state is CustomerLoaded) {
                    return DropdownButtonFormField<String>(
                      value: selectedCustomer.isNotEmpty ? selectedCustomer : null,
                      decoration: const InputDecoration(
                        labelText: 'Müşteri',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                      dropdownColor: AppTheme.surfaceColor,
                      style: const TextStyle(color: Colors.white),
                      items: state.customers.map((customer) {
                        return DropdownMenuItem(
                          value: customer.name,
                          child: Text(customer.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedCustomer = value!;
                      },
                    );
                  }
                  return const Text('Müşteri yükleniyor...', style: TextStyle(color: Colors.grey));
                },
              ),
            const SizedBox(height: 16),
            
            // İşlem tipi
            Row(
              children: [
                Expanded(
                  child: RadioListTile<TransactionType>(
                    title: const Text('Alacak', style: TextStyle(color: Colors.white)),
                    value: TransactionType.credit,
                    groupValue: selectedType,
                    onChanged: (value) {
                      selectedType = value!;
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<TransactionType>(
                    title: const Text('Borç', style: TextStyle(color: Colors.white)),
                    value: TransactionType.debit,
                    groupValue: selectedType,
                    onChanged: (value) {
                      selectedType = value!;
                    },
                  ),
                ),
              ],
            ),
            
            // Tutar
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Tutar',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            
            // Açıklama
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Açıklama (Opsiyonel)',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedCustomer.isNotEmpty && amountController.text.isNotEmpty) {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  final transaction = TransactionEntity(
                    customerName: selectedCustomer,
                    type: selectedType,
                    amount: amount,
                    description: descriptionController.text.isNotEmpty 
                        ? descriptionController.text 
                        : null,
                    date: DateTime.now(),
                    createdAt: DateTime.now(),
                  );
                  
                  context.read<TransactionBloc>().add(AddTransaction(transaction));
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            child: const Text('Ekle', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}