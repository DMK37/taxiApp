// Mocks generated by Mockito 5.4.4 from annotations
// in driver_taxi_app/test/register_page_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i8;

import 'package:driver_taxi_app/auth/cubit/auth_cubit.dart' as _i7;
import 'package:driver_taxi_app/auth/cubit/auth_state.dart' as _i4;
import 'package:driver_taxi_app/initial_state/cubit/initial_cubit.dart' as _i11;
import 'package:driver_taxi_app/initial_state/cubit/initial_state.dart' as _i6;
import 'package:driver_taxi_app/models/order_message.dart' as _i13;
import 'package:flutter_bloc/flutter_bloc.dart' as _i10;
import 'package:google_maps_flutter/google_maps_flutter.dart' as _i12;
import 'package:mockito/mockito.dart' as _i1;
import 'package:reown_appkit/reown_appkit.dart' as _i2;
import 'package:shared/models/car_type.dart' as _i9;
import 'package:shared/repositories/driver/driver_repository.dart' as _i3;
import 'package:shared/repositories/ride_contract/ride_contract.dart' as _i5;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeReownAppKit_0 extends _i1.SmartFake implements _i2.ReownAppKit {
  _FakeReownAppKit_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDriverRepository_1 extends _i1.SmartFake
    implements _i3.DriverRepository {
  _FakeDriverRepository_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDriverAuthState_2 extends _i1.SmartFake
    implements _i4.DriverAuthState {
  _FakeDriverAuthState_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeRideContract_3 extends _i1.SmartFake implements _i5.RideContract {
  _FakeRideContract_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDriverState_4 extends _i1.SmartFake implements _i6.DriverState {
  _FakeDriverState_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [DriverAuthCubit].
///
/// See the documentation for Mockito's code generation for more information.
class MockDriverAuthCubit extends _i1.Mock implements _i7.DriverAuthCubit {
  @override
  _i2.ReownAppKit get appKit => (super.noSuchMethod(
        Invocation.getter(#appKit),
        returnValue: _FakeReownAppKit_0(
          this,
          Invocation.getter(#appKit),
        ),
        returnValueForMissingStub: _FakeReownAppKit_0(
          this,
          Invocation.getter(#appKit),
        ),
      ) as _i2.ReownAppKit);

  @override
  set appKit(_i2.ReownAppKit? _appKit) => super.noSuchMethod(
        Invocation.setter(
          #appKit,
          _appKit,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i3.DriverRepository get repository => (super.noSuchMethod(
        Invocation.getter(#repository),
        returnValue: _FakeDriverRepository_1(
          this,
          Invocation.getter(#repository),
        ),
        returnValueForMissingStub: _FakeDriverRepository_1(
          this,
          Invocation.getter(#repository),
        ),
      ) as _i3.DriverRepository);

  @override
  _i4.DriverAuthState get state => (super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: _FakeDriverAuthState_2(
          this,
          Invocation.getter(#state),
        ),
        returnValueForMissingStub: _FakeDriverAuthState_2(
          this,
          Invocation.getter(#state),
        ),
      ) as _i4.DriverAuthState);

  @override
  _i8.Stream<_i4.DriverAuthState> get stream => (super.noSuchMethod(
        Invocation.getter(#stream),
        returnValue: _i8.Stream<_i4.DriverAuthState>.empty(),
        returnValueForMissingStub: _i8.Stream<_i4.DriverAuthState>.empty(),
      ) as _i8.Stream<_i4.DriverAuthState>);

  @override
  bool get isClosed => (super.noSuchMethod(
        Invocation.getter(#isClosed),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  _i8.Future<void> init() => (super.noSuchMethod(
        Invocation.method(
          #init,
          [],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  void isConnected(_i2.ReownAppKitModal? modal) => super.noSuchMethod(
        Invocation.method(
          #isConnected,
          [modal],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i8.Future<void> createAccount(
    String? id,
    String? firstName,
    String? lastName,
    String? carName,
    _i9.CarType? carType,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #createAccount,
          [
            id,
            firstName,
            lastName,
            carName,
            carType,
          ],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> updateAccount(
    String? id,
    String? firstName,
    String? lastName,
    String? carName,
    _i9.CarType? carType,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateAccount,
          [
            id,
            firstName,
            lastName,
            carName,
            carType,
          ],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  void emit(_i4.DriverAuthState? state) => super.noSuchMethod(
        Invocation.method(
          #emit,
          [state],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onChange(_i10.Change<_i4.DriverAuthState>? change) => super.noSuchMethod(
        Invocation.method(
          #onChange,
          [change],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void addError(
    Object? error, [
    StackTrace? stackTrace,
  ]) =>
      super.noSuchMethod(
        Invocation.method(
          #addError,
          [
            error,
            stackTrace,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onError(
    Object? error,
    StackTrace? stackTrace,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #onError,
          [
            error,
            stackTrace,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i8.Future<void> close() => (super.noSuchMethod(
        Invocation.method(
          #close,
          [],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);
}

/// A class which mocks [DriverInitCubit].
///
/// See the documentation for Mockito's code generation for more information.
class MockDriverInitCubit extends _i1.Mock implements _i11.DriverInitCubit {
  @override
  _i3.DriverRepository get repository => (super.noSuchMethod(
        Invocation.getter(#repository),
        returnValue: _FakeDriverRepository_1(
          this,
          Invocation.getter(#repository),
        ),
        returnValueForMissingStub: _FakeDriverRepository_1(
          this,
          Invocation.getter(#repository),
        ),
      ) as _i3.DriverRepository);

  @override
  set repository(_i3.DriverRepository? _repository) => super.noSuchMethod(
        Invocation.setter(
          #repository,
          _repository,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.RideContract get rideContract => (super.noSuchMethod(
        Invocation.getter(#rideContract),
        returnValue: _FakeRideContract_3(
          this,
          Invocation.getter(#rideContract),
        ),
        returnValueForMissingStub: _FakeRideContract_3(
          this,
          Invocation.getter(#rideContract),
        ),
      ) as _i5.RideContract);

  @override
  set rideContract(_i5.RideContract? _rideContract) => super.noSuchMethod(
        Invocation.setter(
          #rideContract,
          _rideContract,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i6.DriverState get state => (super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: _FakeDriverState_4(
          this,
          Invocation.getter(#state),
        ),
        returnValueForMissingStub: _FakeDriverState_4(
          this,
          Invocation.getter(#state),
        ),
      ) as _i6.DriverState);

  @override
  _i8.Stream<_i6.DriverState> get stream => (super.noSuchMethod(
        Invocation.getter(#stream),
        returnValue: _i8.Stream<_i6.DriverState>.empty(),
        returnValueForMissingStub: _i8.Stream<_i6.DriverState>.empty(),
      ) as _i8.Stream<_i6.DriverState>);

  @override
  bool get isClosed => (super.noSuchMethod(
        Invocation.getter(#isClosed),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  dynamic startLocationUpdate(
    _i12.LatLng? driverLocation,
    String? driverId,
    String? ref,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #startLocationUpdate,
          [
            driverLocation,
            driverId,
            ref,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  dynamic stopLocationUpdate(
    String? driverId,
    String? ref,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #stopLocationUpdate,
          [
            driverId,
            ref,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i8.Future<List<_i9.CarType>> getCarTypeList() => (super.noSuchMethod(
        Invocation.method(
          #getCarTypeList,
          [],
        ),
        returnValue: _i8.Future<List<_i9.CarType>>.value(<_i9.CarType>[]),
        returnValueForMissingStub:
            _i8.Future<List<_i9.CarType>>.value(<_i9.CarType>[]),
      ) as _i8.Future<List<_i9.CarType>>);

  @override
  void messageReceived(
    String? driverId,
    _i13.OrderMessageModel? message,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #messageReceived,
          [
            driverId,
            message,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i8.Future<bool> confirmRide(
    _i2.ReownAppKitModal? modal,
    int? rideId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #confirmRide,
          [
            modal,
            rideId,
          ],
        ),
        returnValue: _i8.Future<bool>.value(false),
        returnValueForMissingStub: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);

  @override
  void cancelRide() => super.noSuchMethod(
        Invocation.method(
          #cancelRide,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void emit(_i6.DriverState? state) => super.noSuchMethod(
        Invocation.method(
          #emit,
          [state],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onChange(_i10.Change<_i6.DriverState>? change) => super.noSuchMethod(
        Invocation.method(
          #onChange,
          [change],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void addError(
    Object? error, [
    StackTrace? stackTrace,
  ]) =>
      super.noSuchMethod(
        Invocation.method(
          #addError,
          [
            error,
            stackTrace,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onError(
    Object? error,
    StackTrace? stackTrace,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #onError,
          [
            error,
            stackTrace,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i8.Future<void> close() => (super.noSuchMethod(
        Invocation.method(
          #close,
          [],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);
}
