import 'package:driver_taxi_app/auth/pages/login_page.dart';
import 'package:driver_taxi_app/router_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:driver_taxi_app/main.dart' as app;
import 'package:mockito/mockito.dart';
import 'package:driver_taxi_app/auth/cubit/auth_cubit.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:shared/repositories/driver/driver_repository.dart';

class MockDriverAuthCubit extends Mock implements DriverAuthCubit {
  Future<void> initCubit() async {
    DriverRepository repository = DriverRepository();

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
              native: 'taxiappdriver://',
              linkMode: true,
            )),
      );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test Connect MetaMask button redirects to MetaMask', (tester) async {
    // Mock the DriverAuthCubit
    final mockAuthCubit = MockDriverAuthCubit();
    //final mockAppKitModal = MockReownAppKitModal();

    // Set up the mock for appKit
    when(mockAuthCubit.appKit).thenReturn(ReownAppKitModal(
      context: tester.element(find.byType(DriverLoginPage)),
      appKit: mockAuthCubit.appKit, // Assuming mockAppKit is some mock or stub of the real appKit
    ) as ReownAppKit);

    // Start the app with a mock AuthCubit
    await tester.pumpWidget(
      BlocProvider<DriverAuthCubit>.value(
        value: mockAuthCubit,
        child: app.MyApp(router: AppRouter().router),
      ),
    );

    // Verify if the widget is displayed
    expect(find.byType(DriverLoginPage), findsOneWidget);

    // Simulate a tap on the "Connect MetaMask" button
    await tester.tap(find.byType(AppKitModalConnectButton));
    await tester.pumpAndSettle(); // Wait for the animation or transition

    // Ensure that the method to connect was called (this should trigger MetaMask interaction)
    verify(mockAuthCubit.appKit.connect()).called(1);

    // Optionally, check that the app navigates to the correct page
    //expect(find.byType(DriverInitialPage), findsOneWidget); // Replace with the expected page after redirect
  });
}

class MockReownAppKitModal extends Mock implements ReownAppKitModal {
  // Mock methods as needed
  Future<void> connect() async {
    return super.noSuchMethod(
      Invocation.method(#connect, []),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }
}
