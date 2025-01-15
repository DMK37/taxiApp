import 'package:driver_taxi_app/auth/cubit/auth_cubit.dart';
import 'package:driver_taxi_app/auth/cubit/auth_state.dart';
import 'package:driver_taxi_app/driver/pages/driver_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:shared/models/car_model.dart';
import 'package:shared/models/car_type.dart';
import 'package:mockito/annotations.dart';
import 'package:shared/models/driver_model.dart';

@GenerateNiceMocks([MockSpec<DriverAuthCubit>()])
@GenerateNiceMocks([MockSpec<ReownAppKit>()])
import 'driver_page_test.mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late MockDriverAuthCubit mockDriverAuthCubit;

  setUp(() {
    mockDriverAuthCubit = MockDriverAuthCubit();
    final mockAppKit = MockReownAppKit();

    when(mockDriverAuthCubit.appKit).thenReturn(mockAppKit);

    when(mockDriverAuthCubit.state).thenReturn(
      DriverAuthenticatedState(
        driver: DriverModel(
          id: '0x123456789',
          firstName: 'John',
          lastName: 'Doe',
          car: CarModel(carName: 'Tesla Model S', carType: CarType.premium),
        ),
      ),
    );
  });

  group('DriverPage Integration Tests', () {
    testWidgets('renders DriverPage with initial values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DriverAuthCubit>.value(
            value: mockDriverAuthCubit,
            child: const DriverPage(showAppKitButton: false),
          ),
        ),
      );

      expect(find.text('John'), findsOneWidget); // First Name
      expect(find.text('Doe'), findsOneWidget); // Last Name
      expect(find.text('Tesla Model S'), findsOneWidget); // Car Name
      expect(find.text(CarType.premium.toString()), findsOneWidget); // Car Type
    });

    testWidgets('shows validation error when fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DriverAuthCubit>.value(
            value: mockDriverAuthCubit,
            child: const DriverPage(
              showAppKitButton: false,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), ''); // First Name
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(1), 'Depp'); // Last Name
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(2), 'BMW'); // Car Name
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton)); // Save Changes button
      await tester.pump();

      expect(find.text('Please enter your first name'), findsOneWidget);
      verifyNever(mockDriverAuthCubit.updateAccount(
        '0x123456789',
        'Joe',
        'Smith',
        'BMW X5',
        CarType.comfort,
      ));
    });

    testWidgets('calls updateAccount on valid form submission', (WidgetTester tester) async {
      when(mockDriverAuthCubit.updateAccount(
        '0x123456789',
        'Joe',
        'Smith',
        'BMW X5',
        CarType.comfort,
      )).thenAnswer((_) async => Future<void>.value());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DriverAuthCubit>.value(
            value: mockDriverAuthCubit,
            child: const DriverPage(
              showAppKitButton: false,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'John'); // First Name
      await tester.enterText(find.byType(TextFormField).at(1), 'Smith'); // Last Name
      await tester.enterText(find.byType(TextFormField).at(2), 'BMW X5'); // Car Name
      await tester.tap(find.byType(DropdownButtonFormField<CarType>)); // Open Dropdown
      await tester.pump();
      await tester.tap(find.text(CarType.comfort.toString())); // Select Car Type
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      verify(mockDriverAuthCubit.updateAccount(
        '0x123456789',
        'John',
        'Smith',
        'BMW X5',
        CarType.comfort,
      )).called(1);
    });
  });
}
