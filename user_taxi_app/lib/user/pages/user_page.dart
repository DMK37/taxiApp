import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:shared/models/client_model.dart';
import 'package:taxiapp/auth/cubit/auth_cubit.dart';
import 'package:taxiapp/auth/cubit/auth_state.dart';
import 'package:taxiapp/theme/theme_notifier.dart';
import 'package:taxiapp/user/widgets/ride_history_widget.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late ReownAppKitModal _appKitModal;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = (context.read<AuthCubit>().state as AuthenticatedState).user.firstName;
    _lastNameController.text = (context.read<AuthCubit>().state as AuthenticatedState).user.lastName;
    final appKit = context.read<AuthCubit>().appKit;
    _appKitModal = ReownAppKitModal(
      context: context,
      appKit: appKit,
    );
    _appKitModal.init();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: AppKitModalAccountButton(
                appKitModal: _appKitModal,
                size: BaseButtonSize.big,
              )),
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
                      // Handle save changes logic here
                      String firstName = _firstNameController.text.trim();
                      String lastName = _lastNameController.text.trim();
                      print('First Name: $firstName, Last Name: $lastName');
                      // Add your save changes logic here
                      final id = (context.read<AuthCubit>().state as AuthenticatedState).user.id;
                      print('ID: $id');
                      await context.read<AuthCubit>().updateAccount(id, firstName, lastName);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
              _buildRideHistoryWidget(context),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildRideHistoryWidget(BuildContext context) {
  ClientModel client = (context.read<AuthCubit>().state as AuthenticatedState).user;
  return RideHistoryWidget(context: context, client: client);
}