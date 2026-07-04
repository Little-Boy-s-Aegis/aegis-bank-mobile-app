import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_cyber_demo/data/api/dio_client.dart';
import 'package:bank_cyber_demo/domain/models/security_status.dart';
import 'package:dio/dio.dart';

abstract class SecurityState {}

class SecurityInitial extends SecurityState {}

class SecurityLoading extends SecurityState {}

class SecurityLoaded extends SecurityState {
  final SecurityStatus status;
  SecurityLoaded(this.status);
}

class SecurityError extends SecurityState {
  final String message;
  SecurityError(this.message);
}

class SecurityCubit extends Cubit<SecurityState> {
  final DioClient _dioClient = DioClient();

  SecurityCubit() : super(SecurityInitial());

  Future<void> fetchStatus() async {
    emit(SecurityLoading());
    try {
      final response = await _dioClient.dio.get('/api/admin/security/status');
      final status = SecurityStatus.fromJson(response.data as Map<String, dynamic>);
      emit(SecurityLoaded(status));
    } catch (e) {
      emit(SecurityError("Failed to fetch security configurations: ${e.toString()}"));
    }
  }

  Future<void> toggleSetting(String vulnerability, bool enabled) async {
    try {
      await _dioClient.dio.post('/api/admin/security/toggle', data: {
        'vulnerability': vulnerability.toUpperCase(),
        'enabled': enabled,
      });
      fetchStatus(); // refresh status
    } catch (e) {
      emit(SecurityError("Failed to update security rules: ${e.toString()}"));
    }
  }
}
