import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxiapp/auth/cubit/auth_state.dart';
import 'package:taxiapp/auth/repository/auth_repository.dart';
import 'package:taxiapp/models/user_model.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  AuthCubit(this._authRepository) : super(UnauthenticatedState());

  Future<void> signIn() async {
    emit(AuthLoadingState());
    try {
      // Sign in logic
      final user = await _authRepository.signIn();
      print(user.walletId);
      emit(AuthenticatedState(user: user));
    } catch (e) {
      print(e);
      emit(AuthFailureState(errorMessage: e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoadingState());
    try {
      // Sign out logic
      await _authRepository.logout();
      emit(UnauthenticatedState());
    } catch (e) {
      emit(AuthFailureState(errorMessage: e.toString()));
    }
  }

  Future<void> isAuthenticated() async {
    final isAuth = await _authRepository.isAuthenticated();
    if (isAuth) {
      emit(AuthenticatedState(user: UserModel(walletId: "0x1234567890")));
    } else {
      emit(UnauthenticatedState());
    }
  }
}
