import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/progress_cubit.dart';

class BookScanSheet extends StatefulWidget {
  final String lang;
  const BookScanSheet({super.key, required this.lang});

  @override
  State<BookScanSheet> createState() => _BookScanSheetState();
}

class _BookScanSheetState extends State<BookScanSheet> {
  int _selectedDateIndex = 0;
  String? _selectedTime;
  bool _booked = false;
  bool _loading = false;

  final List<Map<String, dynamic>> _scanSlots = [
    { "date": "Mon, Jul 14", "times": ["09:00 AM", "10:00 AM", "11:00 AM", "02:00 PM"] },
    { "date": "Tue, Jul 15", "times": ["09:00 AM", "11:00 AM", "03:00 PM", "04:00 PM"] },
    { "date": "Wed, Jul 16", "times": ["10:00 AM", "01:00 PM", "02:00 PM", "05:00 PM"] },
    { "date": "Thu, Jul 17", "times": ["09:00 AM", "10:00 AM", "04:00 PM"] },
  ];

  String tr(String key) => Translations.tr(key, widget.lang);

  void _handleConfirm() async {
    if (_selectedTime == null) return;
    setState(() => _loading = true);

    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      final user = authState.user;
      final memberName = (widget.lang == 'en' ? (user.nameEn ?? user.nameAr) : (user.nameAr ?? user.nameEn)) ?? 'Member';

      await context.read<ProgressCubit>().bookScan(
            persId: user.persId!,
            memberName: memberName,
            date: _scanSlots[_selectedDateIndex]['date'],
            time: _selectedTime!,
          );
    } else {
      // Handle non-authenticated state if necessary
      await Future.delayed(const Duration(milliseconds: 1100));
    }

    if (mounted) {
      setState(() {
        _loading = false;
        _booked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = widget.lang == 'ar';
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF3A3A3A), borderRadius: BorderRadius.circular(2))),
              _buildHeader(),
              const Divider(color: Color(0xFF2A2A2A), height: 1),
              if (_booked) _buildSuccessState() else _buildBookingState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.lang == 'ar' ? "حجز فحص InBody" : "Book InBody Scan", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(widget.lang == 'ar' ? "تحليل تكوين الجسم" : "Body composition analysis", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
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
    );
  }

  Widget _buildBookingState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoPill(),
          const SizedBox(height: 24),
          _buildDatePicker(),
          const SizedBox(height: 24),
          _buildTimePicker(),
          const SizedBox(height: 24),
          if (_selectedTime != null) _buildSummary(),
          const SizedBox(height: 24),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildInfoPill() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.25))),
      child: Row(
        children: [
          const Icon(LucideIcons.activity, color: AppTheme.primaryRed, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.lang == 'ar' ? "فحص InBody 970" : "InBody 970 Scan", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              Text(widget.lang == 'ar' ? "15 دقيقة · مجاني للأعضاء" : "15 min · Free for members", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [const Icon(LucideIcons.calendar, color: Colors.grey, size: 16), const SizedBox(width: 8), Text(widget.lang == 'ar' ? "اختر التاريخ" : "Select Date", style: const TextStyle(color: Colors.grey, fontSize: 13))]),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _scanSlots.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final slot = _scanSlots[index];
              final parts = slot['date'].split(', ');
              final selected = _selectedDateIndex == index;
              return GestureDetector(
                onTap: () => setState(() { _selectedDateIndex = index; _selectedTime = null; }),
                child: Container(
                  width: 70,
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primaryRed : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: selected ? AppTheme.primaryRed : const Color(0xFF2A2A2A)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(parts[0], style: TextStyle(color: selected ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(parts[1], style: TextStyle(color: selected ? Colors.white : Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    final times = _scanSlots[_selectedDateIndex]['times'] as List<String>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [const Icon(LucideIcons.clock, color: Colors.grey, size: 16), const SizedBox(width: 8), Text(widget.lang == 'ar' ? "اختر الوقت" : "Select Time", style: const TextStyle(color: Colors.grey, fontSize: 13))]),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.5),
          itemCount: times.length,
          itemBuilder: (context, index) {
            final t = times[index];
            final selected = _selectedTime == t;
            return GestureDetector(
              onTap: () => setState(() => _selectedTime = t),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primaryRed : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? AppTheme.primaryRed : const Color(0xFF2A2A2A)),
                ),
                child: Center(child: Text(t, style: TextStyle(color: selected ? Colors.white : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(widget.lang == 'ar' ? "التاريخ" : "Date", style: const TextStyle(color: Colors.grey, fontSize: 13)), Text(_scanSlots[_selectedDateIndex]['date'], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(widget.lang == 'ar' ? "الوقت" : "Time", style: const TextStyle(color: Colors.grey, fontSize: 13)), Text(_selectedTime!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))]),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedTime != null && !_loading ? _handleConfirm : null,
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: _loading 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(widget.lang == 'ar' ? "تأكيد الحجز" : "Confirm Booking", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(LucideIcons.check, color: AppTheme.primaryRed, size: 32)),
          const SizedBox(height: 24),
          Text(widget.lang == 'ar' ? "تم الحجز!" : "Scan Booked!", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("${_scanSlots[_selectedDateIndex]['date']} · $_selectedTime", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),
          Text(widget.lang == 'ar' ? "سنرسل لك تذكيراً قبل الموعد" : "We'll send you a reminder before your appointment", textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(widget.lang == 'ar' ? "تم" : "Done", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
