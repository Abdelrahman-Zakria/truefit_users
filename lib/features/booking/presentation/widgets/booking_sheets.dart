import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../domain/entities/pt_session_entity.dart';
import '../../domain/entities/group_class_entity.dart';

class BookingSheetWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final String lang;
  final String? step;
  final VoidCallback? onBack;

  const BookingSheetWrapper({
    super.key,
    required this.title,
    required this.child,
    required this.lang,
    this.step,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = lang == 'ar';
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF111111),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF3A3A3A), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    if (onBack != null)
                      GestureDetector(
                        onTap: onBack,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(right: 12),
                          decoration: const BoxDecoration(color: Color(0xFF2A2A2A), shape: BoxShape.circle),
                          child: Icon(isRtl ? LucideIcons.chevronRight : LucideIcons.chevronLeft, color: Colors.white, size: 16),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (step != null)
                            Text(step!, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10, fontWeight: FontWeight.bold)),
                          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFF2A2A2A), shape: BoxShape.circle),
                        child: const Icon(LucideIcons.x, color: Colors.grey, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF2A2A2A), height: 1),
              child,
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class PTBookingSheet extends StatefulWidget {
  final PTSessionEntity session;
  final String lang;
  final Function(String sessionId) onBook;

  const PTBookingSheet({super.key, required this.session, required this.lang, required this.onBook});

  @override
  State<PTBookingSheet> createState() => _PTBookingSheetState();
}

class _PTBookingSheetState extends State<PTBookingSheet> {
  int _step = 1;
  String? _selectedTime;
  int _selectedDayIndex = 1;

  final List<Map<String, String>> _weekDays = [
    { "label": "Mon", "date": "Jun 30" },
    { "label": "Tue", "date": "Jul 1" },
    { "label": "Wed", "date": "Jul 2" },
    { "label": "Thu", "date": "Jul 3" },
    { "label": "Fri", "date": "Jul 4" },
    { "label": "Sat", "date": "Jul 5" },
    { "label": "Sun", "date": "Jul 6" },
  ];

  final List<String> _timeSlots = ["7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM", "6:00 PM", "7:00 PM"];
  final Set<String> _unavailableSlots = {"8:00 AM", "1:00 PM", "5:00 PM"};

  String tr(String key) => Translations.tr(key, widget.lang);

  @override
  Widget build(BuildContext context) {
    if (_step == 3) {
      return BookingSheetWrapper(
        title: tr('bookedSuccess'),
        lang: widget.lang,
        child: _buildSuccess(),
      );
    }

    return BookingSheetWrapper(
      title: _step == 1 ? tr('pickDateTime') : tr('confirmBooking'),
      step: _step == 1 ? "Step 1 of 2" : "Step 2 of 2",
      lang: widget.lang,
      onBack: _step == 2 ? () => setState(() => _step = 1) : null,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTrainerInfo(),
              const SizedBox(height: 20),
              if (_step == 1) _buildDateTimePickers(),
              if (_step == 2) _buildConfirmation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainerInfo() {
    final initials = widget.session.trainerName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('').toUpperCase();
    final specialty = widget.session.specialty[widget.lang] ?? widget.session.specialty['en'] ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Center(child: Text(initials, style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 14))),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.session.trainerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text('$specialty · 60 min', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('selectDay').toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _weekDays.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final d = _weekDays[index];
              final selected = _selectedDayIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = index),
                child: Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primaryRed : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(d['label']!, style: TextStyle(color: selected ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(d['date']!.split(' ')[1], style: TextStyle(color: selected ? Colors.white.withValues(alpha: 0.7) : Colors.grey.withValues(alpha: 0.5), fontSize: 10)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(tr('selectTime').toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.5),
          itemCount: _timeSlots.length,
          itemBuilder: (context, index) {
            final t = _timeSlots[index];
            final unavailable = _unavailableSlots.contains(t);
            final selected = _selectedTime == t;
            return GestureDetector(
              onTap: unavailable ? null : () => setState(() => _selectedTime = t),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primaryRed : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? AppTheme.primaryRed : const Color(0xFF2A2A2A)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t, style: TextStyle(color: unavailable ? Colors.grey.withValues(alpha: 0.3) : (selected ? Colors.white : Colors.grey), fontSize: 12, fontWeight: FontWeight.bold)),
                    if (unavailable) Text(tr('booked'), style: const TextStyle(color: Colors.red, fontSize: 8)),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedTime != null ? () => setState(() => _step = 2) : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(tr('reviewBooking'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(LucideIcons.chevronRight, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmation() {
    final specialty = widget.session.specialty[widget.lang] ?? widget.session.specialty['en'] ?? '';
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
          child: Column(
            children: [
              _buildConfirmRow(tr('trainer'), widget.session.trainerName),
              const Divider(color: Color(0xFF2A2A2A), height: 1),
              _buildConfirmRow(tr('specialty'), specialty),
              const Divider(color: Color(0xFF2A2A2A), height: 1),
              _buildConfirmRow(tr('date'), "${_weekDays[_selectedDayIndex]['label']}, ${_weekDays[_selectedDayIndex]['date']}"),
              const Divider(color: Color(0xFF2A2A2A), height: 1),
              _buildConfirmRow(tr('time'), _selectedTime!),
              const Divider(color: Color(0xFF2A2A2A), height: 1),
              _buildConfirmRow(tr('duration'), "60 min"),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.3))),
          child: Text(tr('cancelNoticePT'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _step = 3),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(tr('confirmBooking'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Center(
              child: Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle),
                child: const Icon(LucideIcons.check, color: Colors.white, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(tr('bookedSuccess'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              children: [
                const TextSpan(text: "Your session with "),
                TextSpan(text: widget.session.trainerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const TextSpan(text: " is confirmed for "),
                TextSpan(text: "${_weekDays[_selectedDayIndex]['label']}, ${_weekDays[_selectedDayIndex]['date']} at $_selectedTime", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: Column(
              children: [
                _buildSuccessRow(tr('trainer'), widget.session.trainerName),
                const SizedBox(height: 12),
                _buildSuccessRow(tr('date') + " & " + tr('time'), "${_weekDays[_selectedDayIndex]['date']} · $_selectedTime"),
                const SizedBox(height: 12),
                _buildSuccessRow(tr('duration'), "60 min"),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onBook(widget.session.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(tr('done'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class ClassBookingSheet extends StatefulWidget {
  final GroupClassEntity classItem;
  final String lang;
  final Function(String classId) onBook;

  const ClassBookingSheet({super.key, required this.classItem, required this.lang, required this.onBook});

  @override
  State<ClassBookingSheet> createState() => _ClassBookingSheetState();
}

class _ClassBookingSheetState extends State<ClassBookingSheet> {
  int _step = 1;

  String tr(String key) => Translations.tr(key, widget.lang);

  @override
  Widget build(BuildContext context) {
    if (_step == 2) {
      return BookingSheetWrapper(
        title: tr('youAreIn'),
        lang: widget.lang,
        child: _buildSuccess(),
      );
    }

    final className = widget.classItem.name[widget.lang] ?? widget.classItem.name['en'] ?? '';

    return BookingSheetWrapper(
      title: tr('confirmBooking'),
      lang: widget.lang,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.primaryRed.withValues(alpha: 0.2), AppTheme.primaryRed.withValues(alpha: 0.05)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(className, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("with ${widget.classItem.instructor}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
                child: Column(
                  children: [
                    _buildConfirmRow(tr('date'), widget.classItem.date, LucideIcons.calendar),
                    const Divider(color: Color(0xFF2A2A2A), height: 1),
                    _buildConfirmRow(tr('time'), widget.classItem.time, LucideIcons.clock),
                    const Divider(color: Color(0xFF2A2A2A), height: 1),
                    _buildConfirmRow(tr('duration'), widget.classItem.duration, null),
                    const Divider(color: Color(0xFF2A2A2A), height: 1),
                    _buildConfirmRow(tr('location'), widget.classItem.studio, LucideIcons.mapPin),
                    const Divider(color: Color(0xFF2A2A2A), height: 1),
                    _buildConfirmRow(tr('spotsLeft'), "${widget.classItem.spotsLeft} ${tr('spotsLeftText')}", LucideIcons.users),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.3))),
                child: Text(tr('cancelNoticeClass'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _step = 2),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(tr('confirmBooking'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmRow(String label, String value, IconData? icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) Icon(icon, color: AppTheme.primaryRed, size: 16),
              if (icon != null) const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    final className = widget.classItem.name[widget.lang] ?? widget.classItem.name['en'] ?? '';
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Center(
              child: Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle),
                child: const Icon(LucideIcons.check, color: Colors.white, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(tr('youAreIn'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              children: [
                TextSpan(text: className, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const TextSpan(text: " on "),
                TextSpan(text: "${widget.classItem.date} at ${widget.classItem.time}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const TextSpan(text: " is confirmed."),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: Column(
              children: [
                _buildSuccessRow(tr('class'), className),
                const SizedBox(height: 12),
                _buildSuccessRow(tr('instructor'), widget.classItem.instructor[widget.lang] ?? widget.classItem.instructor['en'] ?? ''),
                const SizedBox(height: 12),
                _buildSuccessRow(tr('location'), widget.classItem.studio),
                const SizedBox(height: 12),
                _buildSuccessRow(tr('date') + " & " + tr('time'), "${widget.classItem.date} · ${widget.classItem.time}"),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onBook(widget.classItem.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(tr('done'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
