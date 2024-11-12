import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:taxiapp/auth/cubit/auth_state.dart';
import 'package:taxiapp/models/user_model.dart';

class AuthCubit extends Cubit<AuthState> {
  late ReownAppKit appKit;
  AuthCubit() : super(UnauthenticatedState());

  Future<void> init() async {
    emit(AuthLoadingState());
    try {
      appKit = await ReownAppKit.createInstance(
        projectId: '121c0fdfdd60ce21ad8ce7bd40ab8d5b',
        metadata: const PairingMetadata(
          name: 'Taxi App',
          description: 'Best blockchain taxi app',
          url: 'https://taxiApp.com/',
          icons: ['https://reown.com/logo.png'],
          redirect: Redirect(
            native: 'taxiapp://',
            linkMode: true,
          )
        ),
      );
      appKit.onSessionConnect.subscribe((event) {
        print('Session connected');
        print(event?.session.namespaces['eip155']?.accounts[0]);
        emit(AuthenticatedState(
            user: UserModel(
                walletId: event?.session.namespaces['eip155']?.accounts[0] ??
                    "0x1234567890")));
      });
      emit(UnauthenticatedState());
    } catch (e) {
      print(e);
      emit(AuthFailureState(errorMessage: e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoadingState());
    try {
      // Sign out logic
      //await _authRepository.logout();
      emit(UnauthenticatedState());
    } catch (e) {
      emit(AuthFailureState(errorMessage: e.toString()));
    }
  }
}
