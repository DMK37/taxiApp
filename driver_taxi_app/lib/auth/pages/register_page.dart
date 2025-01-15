import 'package:driver_taxi_app/auth/cubit/auth_cubit.dart';
import 'package:driver_taxi_app/initial_state/cubit/initial_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/models/car_type.dart';

class RegisterPage extends StatefulWidget {
  final String address;
  const RegisterPage({super.key, required this.address});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  List<CarType> carTypes = [];
  CarType? selectedCarType;

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _carNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCarTypes();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _carNameController.dispose();
    super.dispose();
  }

  void _initializeCarTypes() async {
    carTypes = await context.read<DriverInitCubit>().getCarTypeList();
    setState(() {});
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      String firstName = _firstNameController.text;
      String lastName = _lastNameController.text;
      String carName = _carNameController.text;

      if (selectedCarType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car Type field cannot be empty.')),
        );
        return;
      }

      await context
          .read<DriverAuthCubit>()
          .createAccount(widget.address, firstName, lastName, carName, selectedCarType!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register account"),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                      return 'Please enter car name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<CarType>(
                  value: selectedCarType,
                  decoration: const InputDecoration(
                    labelText: 'Select Car Type',
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
                          const SizedBox(width: 10,),
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
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                  ),
                  child: const Text("Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
