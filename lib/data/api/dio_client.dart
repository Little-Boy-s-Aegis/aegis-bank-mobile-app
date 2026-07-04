import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static String baseIp = '10.0.2.2'; // Default Android emulator host loopback
  static String port = '8080';

  static String get baseUrl => 'http://$baseIp:$port';

  final Dio _dio = Dio();

  DioClient() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Request Interceptor: Inject JWT token if available
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.baseUrl = baseUrl;
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // If JWT token expired or 401 returned, trigger logouts if necessary
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
