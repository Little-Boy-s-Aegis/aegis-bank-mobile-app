import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:bank_cyber_demo/data/repositories/repository_provider.dart';
import 'package:bank_cyber_demo/presentation/bloc/auth_cubit.dart';
import 'package:bank_cyber_demo/presentation/bloc/transaction_cubit.dart';
import 'package:bank_cyber_demo/presentation/screens/login_screen.dart';
import 'package:bank_cyber_demo/presentation/screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RepositoryRegistry>(
      create: (_) => RepositoryRegistry(),
      child: Consumer<RepositoryRegistry>(
        builder: (context, registry, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<AuthCubit>(
                create: (_) => AuthCubit(registry.authRepository),
              ),
              BlocProvider<TransactionCubit>(
                create: (_) => TransactionCubit(registry.transactionRepository),
              ),
            ],
            child: MaterialApp(
              title: 'Aegis Bank',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                brightness: Brightness.light,
                primaryColor: const Color(0xFF1B4332),
                fontFamily: 'sans-serif',
                scaffoldBackgroundColor: const Color(0xFFFAFAF5),
                useMaterial3: true,
              ),
              home: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthSuccess) {
                    return DashboardScreen(user: state.user);
                  }
                  return const LoginScreen();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
