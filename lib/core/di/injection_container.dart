import 'package:get_it/get_it.dart';
import 'package:kara_defter/data/database/app_database.dart';
import 'package:kara_defter/data/database/dao/customer_dao.dart';
import 'package:kara_defter/data/database/dao/transaction_dao.dart';
import 'package:kara_defter/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:kara_defter/features/customer/domain/repositories/customer_repository.dart';
import 'package:kara_defter/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:kara_defter/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:kara_defter/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:kara_defter/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:kara_defter/features/dashboard/presentation/bloc/dashboard_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);

  // DAOs
  sl.registerLazySingleton<CustomerDao>(
    () => CustomerDao(sl<AppDatabase>().database as dynamic),
  );
  sl.registerLazySingleton<TransactionDao>(
    () => TransactionDao(sl<AppDatabase>().database as dynamic),
  );

  // Repositories
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(sl<AppDatabase>()),
  );

  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(sl<AppDatabase>()),
  );

  // BLoCs
  sl.registerFactory<CustomerBloc>(
      () => CustomerBloc(sl<CustomerRepository>()));
  sl.registerFactory<TransactionBloc>(
      () => TransactionBloc(sl<TransactionRepository>()));
  sl.registerFactory<DashboardBloc>(() =>
      DashboardBloc(sl<CustomerRepository>(), sl<TransactionRepository>()));
}
