import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';

class ProfileSheetWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final String lang;

  const ProfileSheetWrapper({
    super.key,
    required this.title,
    required this.child,
    required this.lang,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
              Flexible(child: SingleChildScrollView(child: child)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class EditProfileSheet extends StatefulWidget {
  final String lang;
  final Map<String, dynamic>? initialData;

  const EditProfileSheet({super.key, required this.lang, this.initialData});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?['displayName'] ?? '');
    _emailController = TextEditingController(text: widget.initialData?['email'] ?? '');
    _phoneController = TextEditingController(text: widget.initialData?['phone'] ?? '');
    _addressController = TextEditingController(text: widget.initialData?['address'] ?? '');
  }

  String tr(String key) => Translations.tr(key, widget.lang);

  void _save() {
    setState(() => _saved = true);
    Future.delayed(const Duration(milliseconds: 900), () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSheetWrapper(
      title: tr('editProfile'),
      lang: widget.lang,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_saved)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha:0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withValues(alpha:0.3))),
                child: Row(children: [const Icon(LucideIcons.check, color: Colors.green, size: 16), const SizedBox(width: 8), Text(tr('profileUpdated'), style: const TextStyle(color: Colors.green, fontSize: 13))]),
              ),
            _buildField(tr('fullName'), _nameController, LucideIcons.user),
            const SizedBox(height: 16),
            _buildField(tr('email'), _emailController, LucideIcons.mail, type: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildField(tr('phone'), _phoneController, LucideIcons.phone, type: TextInputType.phone),
            const SizedBox(height: 16),
            _buildField(tr('address'), _addressController, LucideIcons.mapPin),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nameController.text.isNotEmpty ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: Platform.isAndroid ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)) : null,
                ),
                child: Text(tr('saveChanges'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType? type}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 18),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryRed)),
          ),
        ),
      ],
    );
  }
}

class HelpSheet extends StatefulWidget {
  final String lang;
  const HelpSheet({super.key, required this.lang});

  @override
  State<HelpSheet> createState() => _HelpSheetState();
}

class _HelpSheetState extends State<HelpSheet> {
  final _msgController = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  String tr(String key) => Translations.tr(key, widget.lang);

  void _send() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSheetWrapper(
      title: tr('helpCenter'),
      lang: widget.lang,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))),
              child: Column(
                children: [
                  _buildContactItem(LucideIcons.mail, widget.lang == 'ar' ? 'البريد الإلكتروني' : 'Email', tr('supportEmail')),
                  const Divider(color: Color(0xFF2A2A2A), height: 1),
                  _buildContactItem(LucideIcons.phone, widget.lang == 'ar' ? 'الهاتف' : 'Phone', tr('supportPhone')),
                  const Divider(color: Color(0xFF2A2A2A), height: 1),
                  _buildContactItem(LucideIcons.calendar, widget.lang == 'ar' ? 'ساعات العمل' : 'Hours', tr('supportHours')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_sent)
              Column(children: [
                const SizedBox(height: 12),
                Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.green.withValues(alpha:0.1), shape: BoxShape.circle), child: const Icon(LucideIcons.check, color: Colors.green)),
                const SizedBox(height: 12),
                Text(tr('messageSent'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ])
            else ...[
              Align(alignment: AlignmentDirectional.centerStart, child: Text(widget.lang == 'ar' ? 'أرسل لنا رسالة' : 'Send us a message', style: const TextStyle(color: Colors.grey, fontSize: 12))),
              const SizedBox(height: 8),
              TextField(
                controller: _msgController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: tr('yourMessage'),
                  hintStyle: const TextStyle(color: Color(0xFF4B5563)),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryRed)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _msgController.text.isNotEmpty && !_loading ? _send : null,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(LucideIcons.messageCircle, size: 16, color: Colors.white), const SizedBox(width: 8), Text(tr('sendMessage'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryRed, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class PrivacySheet extends StatelessWidget {
  final String lang;
  const PrivacySheet({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    final title = lang == 'ar' ? 'سياسة الخصوصية' : 'Privacy Policy';
    return ProfileSheetWrapper(
      title: title,
      lang: lang,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lang == 'ar') ...[
              const Text('آخر تحديث: يوليو 2026', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('تلتزم True Fit Gym & Spa بحماية خصوصيتك. تشرح هذه السياسة كيفية جمع بياناتك واستخدامها وحمايتها.', style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13, height: 1.5)),
              const SizedBox(height: 16),
              const Text('البيانات التي نجمعها', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const Text('نجمع الاسم ورقم الهاتف والعنوان وتاريخ الميلاد وبيانات الحضور والنشاط الرياضي داخل الصالة.', style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13, height: 1.5)),
            ] else ...[
              const Text('Last updated: July 2026', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('True Fit Gym & Spa is committed to protecting your privacy. This policy explains how we collect, use, and safeguard your information.', style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13, height: 1.5)),
              const SizedBox(height: 16),
              const Text('Data We Collect', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const Text('We collect your name, phone number, address, date of birth, attendance records, and in-gym activity data.', style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13, height: 1.5)),
            ],
          ],
        ),
      ),
    );
  }
}

class ChangePasswordSheet extends StatefulWidget {
  final String lang;
  const ChangePasswordSheet({super.key, required this.lang});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _loading = false;
  bool _done = false;
  String _error = '';

  String get title => widget.lang == 'ar' ? 'تغيير كلمة المرور' : 'Change Password';

  void _submit() async {
    setState(() => _error = '');
    if (_newController.text.length < 8) {
      setState(() => _error = widget.lang == 'ar' ? 'يجب أن تكون 8 أحرف على الأقل' : 'Must be at least 8 characters');
      return;
    }
    if (_newController.text != _confirmController.text) {
      setState(() => _error = widget.lang == 'ar' ? 'كلمتا المرور غير متطابقتين' : 'Passwords do not match');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _loading = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSheetWrapper(
      title: title,
      lang: widget.lang,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _done
            ? Column(children: [
                const SizedBox(height: 20),
                Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.green.withValues(alpha:0.1), shape: BoxShape.circle), child: const Icon(LucideIcons.check, color: Colors.green, size: 32)),
                const SizedBox(height: 16),
                Text(widget.lang == 'ar' ? 'تم تحديث كلمة المرور بنجاح' : 'Password updated successfully', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(widget.lang == 'ar' ? 'تم' : 'Done', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              ])
            : Column(
                children: [
                  _buildPwField(widget.lang == 'ar' ? 'كلمة المرور الحالية' : 'Current Password', _currentController, _showCurrent, () => setState(() => _showCurrent = !_showCurrent)),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Color(0xFF2A2A2A))),
                  _buildPwField(widget.lang == 'ar' ? 'كلمة المرور الجديدة' : 'New Password', _newController, _showNew, () => setState(() => _showNew = !_showNew)),
                  const SizedBox(height: 16),
                  _buildPwField(widget.lang == 'ar' ? 'تأكيد كلمة المرور' : 'Confirm New Password', _confirmController, _showConfirm, () => setState(() => _showConfirm = !_showConfirm)),
                  if (_error.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 16), child: Text(_error, style: const TextStyle(color: Colors.red, fontSize: 12))),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _currentController.text.isNotEmpty && _newController.text.isNotEmpty && _confirmController.text.isNotEmpty && !_loading ? _submit : null,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(widget.lang == 'ar' ? 'تحديث كلمة المرور' : 'Update Password', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPwField(String label, TextEditingController controller, bool show, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !show,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: const Icon(LucideIcons.lock, color: Color(0xFF6B7280), size: 18),
            suffixIcon: IconButton(icon: Icon(show ? LucideIcons.eyeOff : LucideIcons.eye, color: const Color(0xFF6B7280), size: 18), onPressed: onToggle),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryRed)),
          ),
        ),
      ],
    );
  }
}

class DeleteConfirmSheet extends StatelessWidget {
  final String lang;
  final VoidCallback onConfirm;

  const DeleteConfirmSheet({super.key, required this.lang, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final isAr = lang == 'ar';
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Color(0xFF111111), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.red.withValues(alpha:0.1), shape: BoxShape.circle), child: const Icon(LucideIcons.trash2, color: Colors.red)),
            const SizedBox(height: 16),
            Text(isAr ? 'حذف الحساب؟' : 'Delete Account?', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(isAr ? 'هذا الإجراء لا يمكن التراجع عنه.' : 'This action cannot be undone. All your data will be permanently deleted.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: Text(isAr ? 'إلغاء' : 'Cancel', style: const TextStyle(color: Colors.grey)))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: onConfirm, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(isAr ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class LogoutConfirmSheet extends StatelessWidget {
  final String lang;
  final VoidCallback onConfirm;

  const LogoutConfirmSheet({super.key, required this.lang, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final isAr = lang == 'ar';
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Color(0xFF111111), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha:0.1), shape: BoxShape.circle), child: const Icon(LucideIcons.logOut, color: AppTheme.primaryRed)),
            const SizedBox(height: 16),
            Text(isAr ? 'تسجيل الخروج؟' : 'Log Out?', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(isAr ? 'هل أنت متأكد أنك تريد تسجيل الخروج؟' : 'Are you sure you want to log out of your account?', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: Text(isAr ? 'إلغاء' : 'Cancel', style: const TextStyle(color: Colors.grey)))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: onConfirm, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(isAr ? 'خروج' : 'Log Out', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
