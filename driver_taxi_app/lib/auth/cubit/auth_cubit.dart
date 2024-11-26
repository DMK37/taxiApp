import 'package:driver_taxi_app/auth/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:shared/models/car_model.dart';
import 'package:shared/models/car_type.dart';
import 'package:shared/models/driver_model.dart';
import 'package:shared/repositories/driver/driver_repository.dart';

class DriverAuthCubit extends Cubit<DriverAuthState> {
  final DriverRepository repository;
  late ReownAppKit appKit;
  DriverAuthCubit(this.repository) : super(DriverUnauthenticatedState());

  Future<void> init() async {
    emit(DriverAuthLoadingState());
    try {
      appKit = await ReownAppKit.createInstance(
        projectId: '121c0fdfdd60ce21ad8ce7bd40ab8d5b',
        metadata: const PairingMetadata(
            name: 'Driver taxi app',
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
        final address = event?.session.namespaces['eip155']?.accounts[0].split(':')[2];
        final driver = await repository.getDriver(address ?? "0x1234567890");
        if (driver == null) {
          // emit first login
          print('First login');
          emit(DriverRegisterState(address: address ?? "0x1234567890"));
          return;
        }
        emit(DriverAuthenticatedState(driver: driver));
      });
      appKit.onSessionExpire.subscribe((event) {
        print('Session expired');
        emit(DriverUnauthenticatedState());
      });
      appKit.onSessionDelete.subscribe((event) {
        print('Session deleted');
        emit(DriverUnauthenticatedState());
      });
      emit(DriverUnauthenticatedState());
    } catch (e) {
      print(e);
      emit(DriverAuthFailureState(errorMessage: e.toString()));
    }
  }

  void isConnected(ReownAppKitModal modal) {
    emit(DriverAuthLoadingState());
    if (modal.isConnected) {
      emit(DriverAuthenticatedState(
          driver: DriverModel(
        id: modal.session?.address ?? "0x1234567890",
        firstName: "alina",
        lastName: "malina",
        car: CarModel(carName: "car1", carType: CarType.basic),
      )));
    } else {
      emit(DriverUnauthenticatedState());
    }
  }

  Future<void> createAccount(String id, String name, String surname, CarModel car) async {
    emit(DriverAuthLoadingState());
    final driver = DriverModel(
      id: id,
      firstName: name,
      lastName: surname,
      car: car,
    );
    final response = await repository.createDriver(driver);
    if (response == null) {
      emit(DriverAuthFailureState(errorMessage: 'Failed to create account'));
      return;
    }
    print("emit auth");
    emit(DriverAuthenticatedState(driver: driver));
  }
}
