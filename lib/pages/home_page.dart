import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_basket_2/components/prayer_card.dart';
import 'package:prayer_basket_2/modals/create_prayer_modal.dart';
import 'package:prayer_basket_2/models/prayer.dart';
import 'package:prayer_basket_2/services/prayer_provider_service.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isCalendarExpanded = false;
  DateTime _selectedDay = DateTime.now();


  Widget _buildStatCard(String label, String value, String unit, IconData icon, Color color) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      height: 100, // Fixed height to match the square-ish look in Figma
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final prayerProvider = context.watch<PrayerProvider>();
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Today", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(DateFormat('EEEE, MMMM d').format(DateTime.now()), style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              
              // Stats Row
              Row(
                children: [
                  _buildStatCard("Streak", "7", "days", Icons.local_fire_department, Colors.orange),
                  _buildStatCard("Today", "1", "prayers", Icons.trending_up, Colors.blue),
                  _buildStatCard("Resolved", "${prayerProvider.prayers.where((p) => p.wasResolvedToday).length}", "answered", Icons.check_circle, Colors.green),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Expandable Calendar
              _buildCalendarDropdown(),
              
              const SizedBox(height: 20),
              const Text("Today's Prayers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              
              // Prayer List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: prayerProvider.prayers.length,
                itemBuilder: (context, index) {
                  final prayer = prayerProvider.prayers[index];
                  return PrayerCard(prayer: prayer);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A0A14),
        onPressed: () => CreatePrayerModal(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarDropdown() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text("Calendar View"),
            trailing: Icon(_isCalendarExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
            onTap: () => setState(() => _isCalendarExpanded = !_isCalendarExpanded),
          ),
          if (_isCalendarExpanded)
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _selectedDay,
              calendarFormat: CalendarFormat.month,
              // Styling to match Figma dots and black selection box
            ),
        ],
      ),
    );
  }
}
