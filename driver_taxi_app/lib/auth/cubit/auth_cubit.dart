import 'package:driver_taxi_app/auth/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:shared/models/car_model.dart';
import 'package:shared/models/car_type.dart';
import 'package:shared/models/driver_model.dart';
import 'package:shared/repositories/driver/driver_repository.dart';
import 'package:shared/utils/config.dart';

class DriverAuthCubit extends Cubit<DriverAuthState> {
  late ReownAppKit appKit;
  final DriverRepository repository;
  DriverAuthCubit(this.repository) : super(DriverUnauthenticatedState());

  Future<void> init() async {
    emit(DriverAuthLoadingState());
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
          rpcUrl: rpcUrl,
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
              native: 'taxiappdriver://',
              linkMode: true,
            )),
      );
      await appKit.init();
      //emit(DriverUnauthenticatedState());
      appKit.onSessionConnect.subscribe((event) async {
        print('Session connected');
        final address = event.session.namespaces['eip155']?.accounts[0].split(':')[2];
        final driver = await repository.getDriver(
            address ?? "0x1234567890");
        if (driver == null) {
          // emit first login
          print('First login');
          emit(DriverFirstLoginState(
              address: address ??
                  "0x1234567890"));
          return;
        }
        emit(DriverAuthenticatedState(
            driver: driver));
      });
      appKit.onSessionDelete.subscribe((event) {
        print('Session deleted');
        emit(DriverUnauthenticatedState());
      });
      //await appKit.init();
      emit(DriverUnauthenticatedState());
    } catch (e) {
      print(e);
      emit(DriverAuthFailureState(errorMessage: e.toString()));
    }
  }

  // void isConnected(ReownAppKitModal modal) {
  //   emit(DriverAuthLoadingState());
  //   if (modal.isConnected) {
  //     final address = modal.session?.namespaces?['eip155']?.accounts.first.split(':').last;
  //     emit(DriverAuthenticatedState(
        
  //         driver: DriverModel(
  //             id: address ?? "0x1234567890",
  //             firstName: "John",
  //             lastName: "John",
  //             car: CarModel(carName: "Volvo", carType: CarType.basic)
  //             )));
  //   } else {
  //     emit(DriverUnauthenticatedState());
  //   }
  // }

  Future<void> createAccount(String id, String firstName, String lastName, String carName, CarType carType) async {
    emit(DriverAuthLoadingState());
    final driver = DriverModel(
        id: id,
        firstName: firstName,
        lastName: lastName,
        car: CarModel(carName: carName, carType: carType)
        );
    final response = await repository.createDriver(driver);
    if (response == null) {
      emit(DriverAuthFailureState(errorMessage: 'Failed to create account'));
      return;
    }
    print("created driver");
    emit(DriverAuthenticatedState(
        driver: driver));
  }

  Future<void> updateAccount(String id, String firstName, String lastName, String carName, CarType carType) async {
    emit(DriverAuthLoadingState());
    final driver = DriverModel(
        id: id,
        firstName: firstName,
        lastName: lastName,
        car: CarModel(carName: carName, carType: carType)
        );
    final response = await repository.updateDriver(driver);
    if (response == null) {
      emit(DriverAuthFailureState(errorMessage: 'Failed to update account'));
      return;
    }
    emit(DriverAuthenticatedState(
        driver: driver));
  }
}
