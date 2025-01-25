import 'package:driver_taxi_app/auth/cubit/auth_cubit.dart';
import 'package:driver_taxi_app/auth/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:shared/models/car_type.dart';
import 'package:driver_taxi_app/driver/widgets/ride_history_widget.dart';
import 'package:driver_taxi_app/theme/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/driver_model.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key, this.showAppKitButton = true});
  final bool showAppKitButton;

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _carNameController = TextEditingController();
  CarType? selectedCarType;

  final _formKey = GlobalKey<FormState>();

  late ReownAppKitModal? _appKitModal;

  @override
  void initState() {
    final driver = (context.read<DriverAuthCubit>().state as DriverAuthenticatedState).driver;
    super.initState();
    _firstNameController.text = driver.firstName;
    _lastNameController.text = driver.lastName;
    _carNameController.text = driver.car.carName;
    selectedCarType = driver.car.carType;
    if (widget.showAppKitButton) {
      final appKit = context.read<DriverAuthCubit>().appKit;
      _appKitModal = ReownAppKitModal(
        context: context,
        appKit: appKit,
      );
      _appKitModal!.init().then((value) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showAppKitButton && _appKitModal != null)
                  Center(
                    child: AppKitModalAccountButton(
                      appKitModal: _appKitModal!,
                      size: BaseButtonSize.big,
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'First Name',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Last Name',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Car Name',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _carNameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter car name';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Car Type',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<CarType>(
                            value: selectedCarType,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: CarType.values.map((CarType carType) {
                              return DropdownMenuItem<CarType>(
                                value: carType,
                                child: Row(
                                  children: [
                                    Icon(
                                      carType.getIcon().icon,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(carType.toString()),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (CarType? newValue) {
                              setState(() {
                                selectedCarType = newValue;
                              });
                            },
                            validator: (value) => value == null ? 'Please select a car type' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    const Text(
                      'Change theme:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Switch(
                        value: themeNotifier.isDarkMode,
                        onChanged: (value) {
                          themeNotifier.toggleTheme();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String firstName = _firstNameController.text.trim();
                        String lastName = _lastNameController.text.trim();
                        String carName = _carNameController.text.trim();
                        print('First Name: $firstName, Last Name: $lastName');
                        final id = (context.read<DriverAuthCubit>().state as DriverAuthenticatedState).driver.id;
                        print('ID: $id');
                        await context
                            .read<DriverAuthCubit>()
                            .updateAccount(id, firstName, lastName, carName, selectedCarType!);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.surface,
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
                const SizedBox(
                  height: 40.0,
                ),
                const Center(
                  child: Text(
                    'Ride History',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildRideHistoryWidget(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRideHistoryWidget(BuildContext context) {
    DriverModel driver = (context.read<DriverAuthCubit>().state as DriverAuthenticatedState).driver;
    return RideHistoryWidget(context: context, driver: driver);
  }
}
