import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../domain/entities/coach_entity.dart';
import '../cubit/booking_cubit.dart';

class PTSchedulingSheet extends StatefulWidget {
  final String lang;
  final CoachEntity coach;
  final int persId;
  final Function(String date, String time) onSchedule;

  const PTSchedulingSheet({
    super.key,
    required this.lang,
    required this.coach,
    required this.persId,
    required this.onSchedule,
  });

  @override
  State<PTSchedulingSheet> createState() => _PTSchedulingSheetState();
}

class _PTSchedulingSheetState extends State<PTSchedulingSheet> {
  int _step = 1;
  String? _selectedTime;
  late final List<Map<String, String>> _dates;
  late String _selectedDate;

  @override
  void initState() {
    super.initState();
    _dates = List.generate(7, (index) {
      final date = DateTime.now().add(Duration(days: index));
      return {
        "label": DateFormat('E').format(date),
        "date": DateFormat('yyyy-MM-dd').format(date),
      };
    });
    _selectedDate = _dates.first['date']!;
  }

  String tr(String key) => Translations.tr(key, widget.lang);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF3A3A3A), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            if (_step == 1) _buildSlotPicker() else _buildSuccess(),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('scheduleSession'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text("${tr('trainer')}: ${widget.coach.name}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 24),
        
        // Date Picker
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final d = _dates[index];
              final isSelected = _selectedDate == d['date'];
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = d['date']!),
                child: Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryRed : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppTheme.primaryRed : const Color(0xFF2A2A2A)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(d['label']!, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(d['date']!.split('-').last, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Availability Stream
        StreamBuilder<List<String>>(
          stream: context.read<BookingCubit>().getCoachAvailability(widget.coach.id, _selectedDate),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
            }
            final slots = snapshot.data ?? [];
            if (slots.isEmpty) {
              return Center(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(tr('noSlotsAvailable') ?? "No available slots", style: const TextStyle(color: Colors.grey)),
              ));
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.2),
              itemCount: slots.length,
              itemBuilder: (context, index) {
                final t = slots[index];
                final isSelected = _selectedTime == t;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = t),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryRed : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? AppTheme.primaryRed : const Color(0xFF2A2A2A)),
                    ),
                    child: Center(child: Text(t, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedTime != null ? () {
              widget.onSchedule(_selectedDate, _selectedTime!);
              setState(() => _step = 2);
            } : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(tr('confirmBooking'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(width: 80, height: 80, decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(LucideIcons.check, color: AppTheme.primaryRed, size: 40)),
        const SizedBox(height: 24),
        Text(tr('bookedSuccess'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Your session with ${widget.coach.name} is confirmed for $_selectedDate at $_selectedTime.", style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(tr('done'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
