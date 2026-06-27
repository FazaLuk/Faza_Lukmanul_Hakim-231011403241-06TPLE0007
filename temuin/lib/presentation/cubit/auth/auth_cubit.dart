import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  static const String _dummyEmail = 'admin@temuin.com';
  static const String _dummyPassword = '123456';
  static const String _dummyName = 'Admin';

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());

    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (email.isEmpty || password.isEmpty) {
      emit(const AuthError(message: 'Email dan password tidak boleh kosong'));
      return;
    }

    final bool isValidUser = email == _dummyEmail && password == _dummyPassword;

    if (!isValidUser) {
      emit(const AuthError(message: 'Email atau password salah'));
      return;
    }

    emit(const AuthAuthenticated(email: _dummyEmail, name: _dummyName));
  }

  void logout() {
    emit(const AuthUnauthenticated());
  }
}
