import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_cyber_demo/data/repositories/auth_repository.dart';
import 'package:bank_cyber_demo/domain/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    checkSession();
  }

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      final username = prefs.getString('user_username') ?? '';
      final fullName = prefs.getString('user_fullname') ?? '';
      final email = prefs.getString('user_email') ?? '';
      final role = prefs.getString('user_role') ?? 'USER';
      final accountNumber = prefs.getString('user_account') ?? '';
      
      emit(AuthSuccess(User(
        id: 0,
        username: username,
        fullName: fullName,
        email: email,
        role: role,
        accountNumber: accountNumber,
      )));
    }
  }

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(username, password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> register(String username, String password, String fullName, String email) async {
    emit(AuthLoading());
    try {
      await _authRepository.register(username, password, fullName, email);
      emit(AuthInitial()); 
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_username');
    await prefs.remove('user_fullname');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.remove('user_account');
    emit(AuthInitial());
  }
}
