import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth/bloc/auth_bloc.dart';
import 'auth/bloc/auth_state.dart';
import 'auth/view/pages/login_page.dart';
import 'dashboard/view/pages/dashboard_page.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is AuthAuthenticated) {
          return BlocProvider.value(
            value: context.read<AuthBloc>(),
            child: const DashboardPage(),
          );
        } else {
          return BlocProvider.value(
            value: context.read<AuthBloc>(),
            child: const LoginPage(),
          );
        }
      },
    );
  }
} 