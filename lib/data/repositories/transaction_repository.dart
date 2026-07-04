import 'package:bank_cyber_demo/data/api/dio_client.dart';
import 'package:bank_cyber_demo/domain/models/transaction.dart';
import 'package:dio/dio.dart';

abstract class TransactionRepository {
  Future<void> transferMoney(String source, String target, double amount, String description);
  Future<List<Transaction>> getTransactionHistory(String accountNumber, {String? search});
}

class RealTransactionRepository implements TransactionRepository {
  final DioClient _dioClient;

  RealTransactionRepository(this._dioClient);

  @override
  Future<void> transferMoney(String source, String target, double amount, String description) async {
    try {
      await _dioClient.dio.post('/api/transactions/transfer', data: {
        'sourceAccountNumber': source,
        'targetAccountNumber': target,
        'amount': amount,
        'description': description,
      });
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['error'] ?? "Money transfer failed");
      }
      throw Exception("Connection error. Banking server offline.");
    }
  }

  @override
  Future<List<Transaction>> getTransactionHistory(String accountNumber, {String? search}) async {
    try {
      final queryParams = {'accountNumber': accountNumber};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      final response = await _dioClient.dio.get(
        '/api/transactions/history',
        queryParameters: queryParams,
      );

      final List<dynamic> list = response.data as List<dynamic>;
      return list.map((tx) => Transaction.fromJson(tx as Map<String, dynamic>)).toList();
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['error'] ?? "Failed to query transactions");
      }
      throw Exception("Connection error. Banking server offline.");
    }
  }
}

class MockTransactionRepository implements TransactionRepository {
  final List<Transaction> _mockTxs = [
    Transaction(
      id: 101,
      sourceAccountNumber: 'ACC-123456',
      targetAccountNumber: 'ACC-987654',
      amount: 500000.0,
      description: 'Tra tien an toi qua (MOCK)',
      timestamp: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      status: 'SUCCESS',
    ),
    Transaction(
      id: 102,
      sourceAccountNumber: 'ACC-987654',
      targetAccountNumber: 'ACC-123456',
      amount: 1000000.0,
      description: 'Chuyen tien qua sinh nhat Alice (MOCK)',
      timestamp: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      status: 'SUCCESS',
    ),
    Transaction(
      id: 103,
      sourceAccountNumber: 'ACC-123456',
      targetAccountNumber: 'ACC-000999',
      amount: 320000.0,
      description: 'Thanh toan tien dien (MOCK)',
      timestamp: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      status: 'SUCCESS',
    ),
  ];

  @override
  Future<void> transferMoney(String source, String target, double amount, String description) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockTxs.insert(
      0,
      Transaction(
        id: 100 + _mockTxs.length,
        sourceAccountNumber: source,
        targetAccountNumber: target,
        amount: amount,
        description: description,
        timestamp: DateTime.now().toIso8601String(),
        status: 'SUCCESS',
      ),
    );
  }

  @override
  Future<List<Transaction>> getTransactionHistory(String accountNumber, {String? search}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (search == null || search.isEmpty) {
      return _mockTxs.where((tx) => tx.sourceAccountNumber == accountNumber || tx.targetAccountNumber == accountNumber).toList();
    }
    
    // Simple filter simulation
    return _mockTxs
        .where((tx) => 
            (tx.sourceAccountNumber == accountNumber || tx.targetAccountNumber == accountNumber) &&
            tx.description.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }
}
