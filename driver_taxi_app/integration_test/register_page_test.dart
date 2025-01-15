import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:driver_taxi_app/auth/cubit/auth_cubit.dart';
import 'package:driver_taxi_app/initial_state/cubit/initial_cubit.dart';
import 'package:driver_taxi_app/auth/pages/register_page.dart';
import 'package:shared/models/car_type.dart';
import 'package:integration_test/integration_test.dart';

class MockDriverInitCubit extends Mock implements DriverInitCubit {}
class MockDriverAuthCubit extends Mock implements DriverAuthCubit {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('RegisterPage Widget Tests', () {
    late MockDriverInitCubit mockDriverInitCubit;
    late MockDriverAuthCubit mockDriverAuthCubit;

    setUp(() {
      mockDriverInitCubit = MockDriverInitCubit();
      mockDriverAuthCubit = MockDriverAuthCubit();
    });

    testWidgets('should display the form fields', (WidgetTester tester) async {
      // when(mockDriverInitCubit.getCarTypeList()).thenAnswer((_) async => [
      //     CarType.basic,  
      //     CarType.comfort,
      //     CarType.premium,
      //   ],
      // );
      // when(mockDriverInitCubit.getCarTypeList()).thenAnswer((_) async => 
      //    ([ CarType.basic])
      // );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DriverInitCubit>.value(
            value: mockDriverInitCubit,
            child: BlocProvider<DriverAuthCubit>.value(
              value: mockDriverAuthCubit,
              child: const RegisterPage(address: '0x123456789'),
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsNWidgets(3));  // Name, Car Name, Car Type
      expect(find.byType(DropdownButtonFormField<CarType>), findsOneWidget);
    });

    testWidgets('should show validation error when form is incomplete', (WidgetTester tester) async {
      // when(mockDriverInitCubit.getCarTypeList()).thenAnswer(
      //   (_) async => [
      //     CarType.basic, 
      //     CarType.comfort,
      //     CarType.premium,
      //   ],
      // );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DriverInitCubit>.value(
            value: mockDriverInitCubit,
            child: BlocProvider<DriverAuthCubit>.value(
              value: mockDriverAuthCubit,
              child: const RegisterPage(address: '0x123456789'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your first name'), findsOneWidget);
      expect(find.text('Please enter your last name'), findsOneWidget);
      expect(find.text('Please enter car name'), findsOneWidget);
      expect(find.text('Please select a car type'), findsOneWidget);
    });

    testWidgets('should call createAccount method when form is valid', (WidgetTester tester) async {
      // final future = Future.value([
      //     CarType.basic, 
      //     CarType.comfort,
      //     CarType.premium,
      //   ],);
      // when(mockDriverInitCubit.getCarTypeList()).thenAnswer((_) => Future.value([
      //     CarType.basic,  
      //     CarType.comfort,
      //     CarType.premium,
      //   ],));
      // when(mockDriverInitCubit.getCarTypeList()).thenAnswer(
      //   (_) async => [
      //     CarType.basic, 
      //     CarType.comfort,
      //     CarType.premium,
      //   ],
      // );
      //final future = Future.value();
      when(mockDriverAuthCubit.createAccount(
        '0x123456789', 'John', 'Doe', 'Car Name', CarType.basic,
      )).thenAnswer((_) async => Future<void>.value());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DriverInitCubit>.value(
            value: mockDriverInitCubit,
            child: BlocProvider<DriverAuthCubit>.value(
              value: mockDriverAuthCubit,
              child: const RegisterPage(address: '0x123456789'),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'Car Name');
      await tester.tap(find.byType(DropdownButtonFormField<CarType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Basic').last);
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      verify(mockDriverAuthCubit.createAccount(
        '0x123456789', 'John', 'Doe', 'Car Name', CarType.basic,
      )).called(1);
    });
  });
}

