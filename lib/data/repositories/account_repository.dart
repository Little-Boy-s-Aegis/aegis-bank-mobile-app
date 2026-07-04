import 'package:bank_cyber_demo/data/api/dio_client.dart';
import 'package:bank_cyber_demo/domain/models/account.dart';
import 'package:dio/dio.dart';

abstract class AccountRepository {
  Future<Account> getAccountDetails(String accountNumber);
}

class RealAccountRepository implements AccountRepository {
  final DioClient _dioClient;

  RealAccountRepository(this._dioClient);

  @override
  Future<Account> getAccountDetails(String accountNumber) async {
    try {
      final response = await _dioClient.dio.get('/api/accounts/$accountNumber/details');
      return Account.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['error'] ?? "Failed to fetch account balance");
      }
      throw Exception("Connection error. Banking server offline.");
    }
  }
}

class MockAccountRepository implements AccountRepository {
  @override
  Future<Account> getAccountDetails(String accountNumber) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (accountNumber == 'ACC-123456') {
      return Account(
        accountNumber: 'ACC-123456',
        fullName: 'Alice Smith (MOCK)',
        balance: 14680000.0,
        currency: 'VND',
        email: 'alice@demo-bank.com',
      );
    } else if (accountNumber == 'ACC-987654') {
      return Account(
        accountNumber: 'ACC-987654',
        fullName: 'Bob Jones (MOCK)',
        balance: 26000000.0,
        currency: 'VND',
        email: 'bob@demo-bank.com',
      );
    } else {
      return Account(
        accountNumber: accountNumber,
        fullName: 'Foreign Owner (MOCK)',
        balance: 500000.0,
        currency: 'VND',
        email: 'foreign@domain.com',
      );
    }
  }
}
