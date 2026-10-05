import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prayer_basket_2/models/prayer_schedule.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:prayer_basket_2/models/prayer.dart';
import 'package:prayer_basket_2/services/prayer_provider_service.dart';

class CreatePrayerModal extends StatefulWidget {
  const CreatePrayerModal({super.key});

  /// Helper to display the modal cleanly from any FAB or action
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreatePrayerModal(),
    );
  }

  @override
  State<CreatePrayerModal> createState() => _CreatePrayerModalState();
}

class _CreatePrayerModalState extends State<CreatePrayerModal> {
  PrayerType _selectedType = PrayerType.request;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String _selectedCategory = "Select category...";
  bool _isPrivate = true;
  bool _isSubmitting = false;

  // Schedule State
  bool _enableSchedule = false;
  ScheduleFrequency _selectedFrequency = ScheduleFrequency.daily;
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7]; // 1 = Mon, 7 = Sun
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  final List<String> _categories = [
    "Gratitude",
    "Healing",
    "Guidance",
    "Family",
    "Work",
    "General",
  ];

  final List<Map<String, dynamic>> _weekDays = [
    {'label': 'M', 'value': 1},
    {'label': 'T', 'value': 2},
    {'label': 'W', 'value': 3},
    {'label': 'T', 'value': 4},
    {'label': 'F', 'value': 5},
    {'label': 'S', 'value': 6},
    {'label': 'S', 'value': 7},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showCategoryPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text("Done"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                scrollController: FixedExtentScrollController(
                  initialItem: _selectedCategory == "Select category..."
                      ? 0
                      : _categories.indexOf(_selectedCategory).clamp(0, _categories.length - 1),
                ),
                onSelectedItemChanged: (index) {
                  setState(() => _selectedCategory = _categories[index]);
                },
                children: _categories.map((c) => Center(child: Text(c))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitPrayer() async {
    final titleText = _titleController.text.trim();
    if (titleText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for your prayer.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final categoryToSave =
        _selectedCategory == "Select category..." ? "General" : _selectedCategory;

    final newPrayer = Prayer(
      id: const Uuid().v4(),
      title: titleText,
      description: _descriptionController.text.trim(),
      type: _selectedType,
      status: PrayerStatus.active,
      createdAt: DateTime.now(),
      category: categoryToSave,
      isConfidential: _isPrivate,
      resolvedAt: null,
      // isPublic: !_isPrivate, 
    );

    final formattedTime =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    final PrayerSchedule? newSchedule = _enableSchedule
        ? PrayerSchedule(
            id: const Uuid().v4(),
            prayerId: newPrayer.id,
            frequency: _selectedFrequency,
            daysOfWeek: _selectedFrequency == ScheduleFrequency.weekly
                ? (_selectedDays.isEmpty ? [1, 2, 3, 4, 5, 6, 7] : _selectedDays)
                : const [1, 2, 3, 4, 5, 6, 7],
            timeOfDay: formattedTime,
            isActive: true,
            createdAt: DateTime.now(),
          )
        : null;

    await context.read<PrayerProvider>().addPrayer(newPrayer, schedule: newSchedule);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Create Prayer",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Type Toggle
            const Text("Type", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildTypeToggle(),

            const SizedBox(height: 20),
            _buildTextField("Title *", "Enter title...", _titleController),
            const SizedBox(height: 20),
            _buildTextField("Description", "Enter description...", _descriptionController, maxLines: 3),

            const SizedBox(height: 20),
            const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: _showCategoryPicker,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategory,
                      style: TextStyle(
                        color: _selectedCategory == "Select category..."
                            ? Colors.grey.shade600
                            : Colors.black,
                      ),
                    ),
                    const Icon(Icons.unfold_more, color: Colors.grey),
                  ],
                ),
              ),
            ),

            // Privacy Section
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _isPrivate,
                  onChanged: (v) => setState(() => _isPrivate = v!),
                ),
                const Text("Private (Confidential)"),
                const SizedBox(width: 20),
                Radio<bool>(
                  value: false,
                  groupValue: _isPrivate,
                  onChanged: (v) => setState(() => _isPrivate = v!),
                ),
                const Text("Public"),
              ],
            ),

            const Divider(height: 32),

            // Schedule Toggle & Options Section
            _buildScheduleSection(),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A0A14),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isSubmitting ? null : _submitPrayer,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Create Prayer",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.alarm, size: 20),
                SizedBox(width: 8),
                Text(
                  "Schedule Reminder",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            Switch.adaptive(
              value: _enableSchedule,
              activeColor: const Color(0xFF0A0A14),
              onChanged: (value) => setState(() => _enableSchedule = value),
            ),
          ],
        ),

        if (_enableSchedule) ...[
          const SizedBox(height: 12),

          // Frequency Picker
          Row(
            children: ScheduleFrequency.values.map((freq) {
              final isSelected = _selectedFrequency == freq;
              final label =
                  freq.name[0].toUpperCase() + freq.name.substring(1);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Center(child: Text(label)),
                    selected: isSelected,
                    selectedColor: const Color(0xFF0A0A14),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedFrequency = freq);
                      }
                    },
                  ),
                ),
              );
            }).toList(),
          ),

          // Day of Week Selector (Shown if Weekly)
          if (_selectedFrequency == ScheduleFrequency.weekly) ...[
            const SizedBox(height: 12),
            const Text(
              "Repeat On",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _weekDays.map((day) {
                final dayVal = day['value'] as int;
                final isSelected = _selectedDays.contains(dayVal);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDays.remove(dayVal);
                      } else {
                        _selectedDays.add(dayVal);
                      }
                    });
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: isSelected
                        ? const Color(0xFF0A0A14)
                        : Colors.grey.shade200,
                    child: Text(
                      day['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 12),

          // Time Picker Tile
          InkWell(
            onTap: _pickTime,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Reminder Time"),
                  Text(
                    _selectedTime.format(context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _toggleButton("Request", PrayerType.request),
          _toggleButton("Prayer", PrayerType.prayer),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, PrayerType type) {
    bool isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0A0A14) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}