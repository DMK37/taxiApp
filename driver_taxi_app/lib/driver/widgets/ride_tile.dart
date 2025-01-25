import 'package:flutter/material.dart';
import 'package:shared/models/ride_history_model.dart';

class RideTile extends StatelessWidget {
  const RideTile({
    Key? key,
    required this.ride,
  }) : super(key: key);

  final HistoryRide ride;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLocationInfo("Source", ride.source),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                _buildLocationInfo("Destination", ride.destination),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Cost: ${(double.parse(ride.cost)/100000000000000000).toStringAsFixed(5)} ETH",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeInfo("Start Time", convertTime(ride.startTime)),
                _buildTimeInfo("End Time", convertTime(ride.endTime)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfo(String label, DateTime time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        Text(
          "${time.hour}:${time.minute.toString().padLeft(2, '0')} on ${time.day}/${time.month}/${time.year}",
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  DateTime convertTime(String time) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(time) * 1000,
    );
    return dateTime;
  }
}