import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:taxiapp/auth/cubit/auth_state.dart';
import 'package:shared/models/client_model.dart';
import 'package:shared/repositories/client/client_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  late ReownAppKit appKit;
  ClientRepository clientRepository;
  AuthCubit(this.clientRepository) : super(UnauthenticatedState());

  Future<void> init() async {
    emit(AuthLoadingState());
    try {
      ReownAppKitModalNetworks.addSupportedNetworks('eip155', [
        ReownAppKitModalNetworkInfo(
            name: "Sepolia",
            chainId: '11155111',
            currency: "ETH",
            rpcUrl: "https://rpc.sepolia.dev",
            explorerUrl: "https://sepolia.etherscan.io",
            isTestNetwork: true),
        ReownAppKitModalNetworkInfo(
          name: "Ride Hardhat",
          chainId: '1337',
          currency: "ETH",
          rpcUrl: "http://192.168.18.81:8545",
          explorerUrl: "https://sepolia.etherscan.io",
          isTestNetwork: false,
        ),
      ]);

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
            )),
      );
      
      appKit.onSessionConnect.subscribe((event) async {
        print('Session connected');
        final address =
            event.session.namespaces['eip155']?.accounts[0].split(':')[2];
        final client =
            await clientRepository.getClient(address ?? "0x1234567890");
        if (client == null) {
          // emit first login
          print('First login');
          emit(FirstLoginState(address: address ?? "0x1234567890"));
          return;
        }
        emit(AuthenticatedState(user: client));
      });
      appKit.onSessionDelete.subscribe((event) {
        print('Session deleted');
        emit(UnauthenticatedState());
      });
      await appKit.init();
      emit(UnauthenticatedState());

    } catch (e) {
      print(e);
      emit(AuthFailureState(errorMessage: e.toString()));
    }
  }

  Future<void> createAccount(
      String id, String firstName, String lastName) async {
    emit(AuthLoadingState());
    final client =
        ClientModel(id: id, firstName: firstName, lastName: lastName);
    final response = await clientRepository.createClient(client);
    if (response == null) {
      emit(AuthFailureState(errorMessage: 'Failed to create account'));
      return;
    }
    print("emit auth");
    emit(AuthenticatedState(user: client));
  }

  Future<void> updateAccount(
      String id, String firstName, String lastName) async {
    emit(AuthLoadingState());
    final client =
        ClientModel(id: id, firstName: firstName, lastName: lastName);
    final response = await clientRepository.updateClient(client);
    if (response == null) {
      emit(AuthFailureState(errorMessage: 'Failed to update account'));
      return;
    }
    emit(AuthenticatedState(user: client));
  }
}
