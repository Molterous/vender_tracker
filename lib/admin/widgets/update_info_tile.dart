import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpdateInfoTile extends StatelessWidget {
  final String title;
  final String timestamp;

  const UpdateInfoTile({
    super.key,
    required this.title,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    // Format the datetime
    final DateTime dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
    final String formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
    final String formattedTime = DateFormat('hh:mm a').format(dateTime);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title[0].toUpperCase() + title.substring(1), // Capitalize
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                formattedTime,
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
