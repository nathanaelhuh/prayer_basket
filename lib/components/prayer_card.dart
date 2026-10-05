import 'package:flutter/material.dart';
import 'package:prayer_basket_2/models/prayer.dart';
import 'package:prayer_basket_2/services/prayer_provider_service.dart';
import 'package:provider/provider.dart';

class PrayerCard extends StatelessWidget {
  final Prayer prayer;
  const PrayerCard({super.key, required this.prayer});

  @override
  Widget build(BuildContext context) {
    if (prayer.status == PrayerStatus.resolved) {
      return Card(
        color: Colors.grey.shade100,
        child: ListTile(
          title: const Text("Prayer Resolved", style: TextStyle(color: Colors.grey)),
          trailing: TextButton(
            onPressed: () => context.read<PrayerProvider>().undoResolve(prayer.id),
            child: const Text("Undo"),
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(prayer.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 IconButton(
                   icon: const Icon(Icons.check_circle_outline),
                   onPressed: () => context.read<PrayerProvider>().toggleResolve(prayer.id),
                 )
               ],
             ),
             Text(prayer.description, style: TextStyle(color: Colors.grey.shade600)),
             // Chips for tags/recurrence...
          ],
        ),
      ),
    );
  }
}