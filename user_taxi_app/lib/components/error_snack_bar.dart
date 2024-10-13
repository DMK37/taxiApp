import 'package:flutter/material.dart';

class ErrorSnackBar extends StatelessWidget {
  final String errorMessage;
  const ErrorSnackBar({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.red.shade500,
            borderRadius: BorderRadius.circular(20)),
        child: Text(
          errorMessage,
          style: Theme.of(context).textTheme.headlineMedium,
        ));
  }
}