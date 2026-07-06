import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_cyber_demo/data/repositories/auth_repository.dart';
import 'package:bank_cyber_demo/domain/models/user.dart';
import 'package:bank_cyber_demo/data/secure_storage.dart';

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
    final token = await SecureStorage.read('token');
    if (token != null) {
      final username = await SecureStorage.read('user_username') ?? '';
      final fullName = await SecureStorage.read('user_fullname') ?? '';
      final email = await SecureStorage.read('user_email') ?? '';
      final role = await SecureStorage.read('user_role') ?? 'USER';
      final accountNumber = await SecureStorage.read('user_account') ?? '';
      
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
    await SecureStorage.delete('token');
    await SecureStorage.delete('user_username');
    await SecureStorage.delete('user_fullname');
    await SecureStorage.delete('user_email');
    await SecureStorage.delete('user_role');
    await SecureStorage.delete('user_account');
    emit(AuthInitial());
  }
}
