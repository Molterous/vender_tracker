import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocationEntryCard extends StatelessWidget {
  final double latitude;
  final double longitude;
  final int timestamp;
  final String taskId;
  final String event;

  const LocationEntryCard({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.taskId,
    required this.event,
  });

  String get formattedTime {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('HH:mm:ss').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // timeStamp
            Text(
              "🕒 $formattedTime",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // loc info
            Text(
              "📍 Lat: ${latitude.toStringAsFixed(5)}  |  Lng: ${longitude.toStringAsFixed(5)}",
              style: TextStyle(color: Colors.white),
            ),

            // task info
            if (taskId.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                "📌 ${l10n.taskId}: $taskId",
                style: TextStyle(color: Colors.white),
              ),
            ],

            // event info
            if (event.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                "📢 ${l10n.event}: $event",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
