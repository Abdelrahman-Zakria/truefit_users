import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../../../core/cubit/lang_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../widgets/profile_sheets.dart';
import '../../../../features/notifications/presentation/screens/notifications_screen.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileScreen extends StatefulWidget {
  final String lang;
  const ProfileScreen({super.key, required this.lang});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pushNotifications = true;

  String tr(String key) => Translations.tr(key, widget.lang);

  void _showSheet(Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => sheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileInitial) {
          context.read<ProfileCubit>().loadProfile();
          return const Scaffold(
            backgroundColor: AppTheme.backgroundBlack,
            body: Center(child: CircularProgressIndicator(color: AppTheme.primaryRed)),
          );
        }

        if (state is ProfileLoading) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundBlack,
            body: Center(child: CircularProgressIndicator(color: AppTheme.primaryRed)),
          );
        }

        if (state is ProfileLoaded) {
          final profile = state.profile;
          return Scaffold(
            backgroundColor: AppTheme.backgroundBlack,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(profile),
                    _buildSectionHeader(tr('personalDetails')),
                    _buildPersonalDetails(profile),
                    _buildSectionHeader(tr('accountSettings')),
                    _buildAccountSettings(),
                    const SizedBox(height: 12),
                    _buildNotificationsShortcut(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is ProfileError) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundBlack,
            body: Center(child: Text(state.message, style: const TextStyle(color: Colors.red))),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildHeader(ProfileEntity profile) {
    String displayName = "User";
    if (widget.lang == 'en') {
      displayName = (profile.nameEn != null && profile.nameEn!.isNotEmpty) ? profile.nameEn! : (profile.nameAr ?? "User");
    } else {
      displayName = (profile.nameAr != null && profile.nameAr!.isNotEmpty) ? profile.nameAr! : (profile.nameEn ?? "User");
    }

    final initials = displayName.split(' ').map((e) => e.isNotEmpty ? e[0] : "").join('').toUpperCase();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primaryRed.withValues(alpha: 0.15), Colors.transparent],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))),
                  child: Icon(widget.lang == 'ar' ? LucideIcons.chevronRight : LucideIcons.chevronLeft, color: Colors.white, size: 18),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showSheet(EditProfileSheet(
                  lang: widget.lang,
                  initialData: {
                    'displayName': displayName,
                    'email': profile.email,
                    'phone': profile.phone,
                    'address': profile.address,
                  },
                )),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))),
                  child: const Icon(LucideIcons.edit3, color: Colors.grey, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFDC143C), Color(0xFFA00F2C)]),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(profile.email ?? "", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.3))),
                      child: Text(tr('premiumElite'), style: const TextStyle(color: AppTheme.primaryRed, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPersonalDetails(ProfileEntity profile) {
    String displayName = "User";
    if (widget.lang == 'en') {
      displayName = (profile.nameEn != null && profile.nameEn!.isNotEmpty) ? profile.nameEn! : (profile.nameAr ?? "User");
    } else {
      displayName = (profile.nameAr != null && profile.nameAr!.isNotEmpty) ? profile.nameAr! : (profile.nameEn ?? "User");
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        children: [
          _buildDetailItem(LucideIcons.user, tr('fullName'), displayName, showEdit: true),
          _buildDetailItem(LucideIcons.mail, tr('email'), profile.email ?? "—"),
          _buildDetailItem(LucideIcons.phone, tr('phone'), profile.phone ?? "—"),
          _buildDetailItem(LucideIcons.mapPin, tr('address'), profile.address ?? "—"),
          _buildDetailItem(LucideIcons.calendar, tr('birthday'), profile.birthday ?? "—", isLast: true),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, {bool isLast = false, bool showEdit = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFF2A2A2A)))),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryRed, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
          if (showEdit)
            GestureDetector(
              onTap: () => _showSheet(EditProfileSheet(lang: widget.lang)),
              child: Text(tr('editProfile'), style: const TextStyle(color: AppTheme.primaryRed, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        children: [
          _buildSettingToggle(LucideIcons.bell, tr('pushNotifications'), _pushNotifications, Colors.blue, (val) => setState(() => _pushNotifications = val)),
          _buildLanguageSetting(),
          _buildSettingItem(LucideIcons.lock, widget.lang == 'ar' ? 'تغيير كلمة المرور' : 'Change Password', Colors.orange, () => _showSheet(ChangePasswordSheet(lang: widget.lang))),
          _buildSettingItem(LucideIcons.shield, tr('privacyPolicy'), Colors.green, () => _showSheet(PrivacySheet(lang: widget.lang))),
          _buildSettingItem(LucideIcons.helpCircle, tr('helpCenter'), Colors.yellow, () => _showSheet(HelpSheet(lang: widget.lang)), isLast: true),
        ],
      ),
    );
  }

  Widget _buildSettingToggle(IconData icon, String title, bool value, Color iconColor, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A)))),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryRed,
            activeTrackColor: AppTheme.primaryRed.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFF3A3A3A),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSetting() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A)))),
      child: Row(
        children: [
          const Icon(LucideIcons.globe, color: Colors.purple, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(tr('language'), style: const TextStyle(color: Colors.white, fontSize: 14))),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: const Color(0xFF0A0A0A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: Row(
              children: ['en', 'ar'].map((l) {
                final active = widget.lang == l;
                return GestureDetector(
                  onTap: () => context.read<LangCubit>().toggle(l),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: active ? AppTheme.primaryRed : Colors.transparent, borderRadius: BorderRadius.circular(20)),
                    child: Text(l.toUpperCase(), style: TextStyle(color: active ? Colors.white : const Color(0xFF6B7280), fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, Color iconColor, VoidCallback onTap, {bool isLast = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFF2A2A2A)))),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14))),
            const Icon(LucideIcons.chevronRight, color: Color(0xFF4B5563), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsShortcut() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsScreen(lang: widget.lang))),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
          child: Row(
            children: [
              const Icon(LucideIcons.bell, color: AppTheme.primaryRed, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(tr('notifications'), style: const TextStyle(color: Colors.white, fontSize: 14))),
              const Icon(LucideIcons.chevronRight, color: Color(0xFF4B5563), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showSheet(LogoutConfirmSheet(
                lang: widget.lang,
                onConfirm: () {
                  Navigator.pop(context); // Close the sheet
                  context.read<AuthCubit>().logout();
                },
              )),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2A2A2A)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: const Color(0xFF1A1A1A),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(LucideIcons.logOut, color: AppTheme.primaryRed, size: 18), const SizedBox(width: 8), Text(tr('logOut'), style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold))]),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _showSheet(DeleteConfirmSheet(
                lang: widget.lang,
                onConfirm: () {
                  Navigator.pop(context); // Close the sheet
                  context.read<AuthCubit>().logout();
                },
              )),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(LucideIcons.trash2, color: Colors.red, size: 16), const SizedBox(width: 8), Text(tr('deleteAccount'), style: const TextStyle(color: Colors.red, fontSize: 13))]),
            ),
          ),
        ],
      ),
    );
  }
}
