import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_cyber_demo/data/repositories/transaction_repository.dart';
import 'package:bank_cyber_demo/domain/models/transaction.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionHistoryLoading extends TransactionState {}

class TransactionHistorySuccess extends TransactionState {
  final List<Transaction> transactions;
  TransactionHistorySuccess(this.transactions);
}

class TransactionHistoryFailure extends TransactionState {
  final String message;
  TransactionHistoryFailure(this.message);
}

class TransactionTransferSubmitting extends TransactionState {}

class TransactionTransferSuccess extends TransactionState {
  final String message;
  TransactionTransferSuccess(this.message);
}

class TransactionTransferFailure extends TransactionState {
  final String message;
  TransactionTransferFailure(this.message);
}

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _transactionRepository;

  TransactionCubit(this._transactionRepository) : super(TransactionInitial());

  Future<void> fetchHistory(String accountNumber, {String? search}) async {
    emit(TransactionHistoryLoading());
    try {
      final list = await _transactionRepository.getTransactionHistory(accountNumber, search: search);
      emit(TransactionHistorySuccess(list));
    } catch (e) {
      emit(TransactionHistoryFailure(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> sendTransfer(String source, String target, double amount, String description) async {
    emit(TransactionTransferSubmitting());
    try {
      await _transactionRepository.transferMoney(source, target, amount, description);
      emit(TransactionTransferSuccess("Transfer completed successfully!"));
    } catch (e) {
      emit(TransactionTransferFailure(e.toString().replaceAll("Exception: ", "")));
    }
  }
}
