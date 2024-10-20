import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxiapp/initial_order/cubit/initial_order_cubit.dart';

class PickLocationColumn extends StatefulWidget {
  final String title;
  final String buttonText;
  final TextEditingController controller;
  final LatLng location;
  final bool isDestination;
  const PickLocationColumn(
      {super.key,
      required this.title,
      required this.controller,
      required this.location,
      required this.isDestination,
      required this.buttonText});

  @override
  State<PickLocationColumn> createState() => _PickLocationColumnState();
}

class _PickLocationColumnState extends State<PickLocationColumn> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          textAlign: TextAlign.center,
          controller: widget.controller,
          readOnly: true,
          decoration: InputDecoration(
            fillColor: Theme.of(context).colorScheme.surface,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (widget.isDestination) {
              context
                  .read<InitialOrderCubit>()
                  .pickDestination(widget.location);
            } else {
              context.read<InitialOrderCubit>().pickSource(widget.location);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: Text(
            widget.buttonText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    );
  }
}
