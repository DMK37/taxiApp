import 'package:driver_taxi_app/auth/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/models/car_model.dart';
import 'package:shared/models/car_type.dart';

class RegisterPage extends StatefulWidget {
  final String address;
  const RegisterPage({super.key, required this.address});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _carNameController = TextEditingController();
  CarType? selectedCarType;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _carNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && selectedCarType != null) {
      String firstName = _firstNameController.text;
      String lastName = _lastNameController.text;
      String carName = _carNameController.text;
      CarModel driverCar = CarModel(carName: carName, carType: selectedCarType!);
      await context.read<DriverAuthCubit>().createAccount(widget.address, firstName, lastName, driverCar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: "First Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: "Last Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _carNameController,
                decoration: const InputDecoration(labelText: "Car Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your car name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButton<CarType>(
                value: selectedCarType,
                hint: const Text('Select Car Type'),
                items: CarType.values.map((CarType carType) {
                  return DropdownMenuItem<CarType>(
                    value: carType,
                    child: Row(
                      children: [
                        carType.getIcon(),
                        const SizedBox(width: 8),
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
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                ),
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
