import 'package:flutter/foundation.dart';
import 'package:bank_cyber_demo/data/api/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_repository.dart';
import 'account_repository.dart';
import 'transaction_repository.dart';

class RepositoryRegistry extends ChangeNotifier {
  bool _useMock = true; // default mock until BE is toggled or configured
  final DioClient _dioClient = DioClient();

  AuthRepository _authRepository = MockAuthRepository();
  AccountRepository _accountRepository = MockAccountRepository();
  TransactionRepository _transactionRepository = MockTransactionRepository();

  RepositoryRegistry() {
    _updateRepositories();
    _initMode();
  }

  Future<void> _initMode() async {
    final prefs = await SharedPreferences.getInstance();
    _useMock = prefs.getBool('use_mock') ?? true;
    DioClient.baseIp = prefs.getString('server_ip') ?? '10.0.2.2';
    DioClient.port = prefs.getString('server_port') ?? '8080';
    _updateRepositories();
  }

  bool get useMock => _useMock;

  AuthRepository get authRepository => _authRepository;
  AccountRepository get accountRepository => _accountRepository;
  TransactionRepository get transactionRepository => _transactionRepository;

  Future<void> toggleMockMode(bool value) async {
    _useMock = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_mock', value);
    _updateRepositories();
    notifyListeners();
  }

  Future<void> updateServerConfig(String ip, String portStr) async {
    DioClient.baseIp = ip;
    DioClient.port = portStr;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', ip);
    await prefs.setString('server_port', portStr);
    _updateRepositories();
    notifyListeners();
  }

  void _updateRepositories() {
    if (_useMock) {
      _authRepository = MockAuthRepository();
      _accountRepository = MockAccountRepository();
      _transactionRepository = MockTransactionRepository();
    } else {
      _authRepository = RealAuthRepository(_dioClient);
      _accountRepository = RealAccountRepository(_dioClient);
      _transactionRepository = RealTransactionRepository(_dioClient);
    }
  }
}
