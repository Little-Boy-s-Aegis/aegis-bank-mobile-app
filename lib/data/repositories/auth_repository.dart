import 'package:bank_cyber_demo/data/api/dio_client.dart';
import 'package:bank_cyber_demo/domain/models/user.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthRepository {
  Future<User> login(String username, String password);
  Future<void> register(String username, String password, String fullName, String email);
}

class RealAuthRepository implements AuthRepository {
  final DioClient _dioClient;

  RealAuthRepository(this._dioClient);

  @override
  Future<User> login(String username, String password) async {
    try {
      final response = await _dioClient.dio.post('/api/auth/login', data: {
        'username': username,
        'password': password,
      });

      final String token = response.data['token'] as String;
      final Map<String, dynamic> userJson = response.data['user'] as Map<String, dynamic>;

      // Save token in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('user_username', userJson['username'] as String);
      await prefs.setString('user_fullname', userJson['fullName'] as String);
      await prefs.setString('user_email', userJson['email'] as String);
      await prefs.setString('user_role', userJson['role'] as String);
      await prefs.setString('user_account', userJson['accountNumber'] as String);

      return User.fromJson(userJson);
    } catch (e) {
      if (e is DioException && e.response != null) {
        if (e.response?.statusCode == 429) {
          throw Exception("Brute Force Blocked: Too many login failures.");
        }
        throw Exception(e.response?.data['error'] ?? "Authentication failed");
      }
      throw Exception("Connection error. Banking server offline.");
    }
  }

  @override
  Future<void> register(String username, String password, String fullName, String email) async {
    try {
      await _dioClient.dio.post('/api/auth/register', data: {
        'username': username,
        'password': password,
        'fullName': fullName,
        'email': email,
      });
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['error'] ?? "Registration failed");
      }
      throw Exception("Connection error. Banking server offline.");
    }
  }
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<User> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate delay
    
    if (username == 'alice' && password == 'password123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', 'mock_jwt_token_alice');
      await prefs.setString('user_username', 'alice');
      await prefs.setString('user_fullname', 'Alice Smith (MOCK)');
      await prefs.setString('user_email', 'alice@demo-bank.com');
      await prefs.setString('user_role', 'USER');
      await prefs.setString('user_account', 'ACC-123456');
      return User(
        id: 2,
        username: 'alice',
        fullName: 'Alice Smith (MOCK)',
        email: 'alice@demo-bank.com',
        role: 'USER',
        accountNumber: 'ACC-123456',
      );
    } else if (username == 'bob' && password == 'password123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', 'mock_jwt_token_bob');
      await prefs.setString('user_username', 'bob');
      await prefs.setString('user_fullname', 'Bob Jones (MOCK)');
      await prefs.setString('user_email', 'bob@demo-bank.com');
      await prefs.setString('user_role', 'USER');
      await prefs.setString('user_account', 'ACC-987654');
      return User(
        id: 3,
        username: 'bob',
        fullName: 'Bob Jones (MOCK)',
        email: 'bob@demo-bank.com',
        role: 'USER',
        accountNumber: 'ACC-987654',
      );
    } else if (username == 'admin' && password == 'admin123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', 'mock_jwt_token_admin');
      await prefs.setString('user_username', 'admin');
      await prefs.setString('user_fullname', 'System Admin (MOCK)');
      await prefs.setString('user_email', 'admin@demo-bank.com');
      await prefs.setString('user_role', 'ADMIN');
      await prefs.setString('user_account', 'NONE');
      return User(
        id: 1,
        username: 'admin',
        fullName: 'System Admin (MOCK)',
        email: 'admin@demo-bank.com',
        role: 'ADMIN',
        accountNumber: 'NONE',
      );
    } else {
      throw Exception("Invalid credentials");
    }
  }

  @override
  Future<void> register(String username, String password, String fullName, String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return;
  }
}
