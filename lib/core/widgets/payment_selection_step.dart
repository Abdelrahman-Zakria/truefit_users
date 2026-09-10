import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../intl/translations.dart';
import '../services/payment_service.dart';

class PaymentSelectionStep extends StatefulWidget {
  final String lang;
  final double amount;
  final String itemName;
  final Function(String method, String? screenshotUrl) onCompleted;

  const PaymentSelectionStep({
    super.key,
    required this.lang,
    required this.amount,
    required this.itemName,
    required this.onCompleted,
  });

  @override
  State<PaymentSelectionStep> createState() => _PaymentSelectionStepState();
}

class _PaymentSelectionStepState extends State<PaymentSelectionStep> {
  String _selectedMethod = 'instapay'; // 'instapay' or 'cash'
  File? _screenshot;
  bool _isUploading = false;
  final PaymentService _paymentService = PaymentService();

  String tr(String key) => Translations.tr(key, widget.lang);

  Future<void> _handleInstaPay() async {
    try {
      await _paymentService.openInstaPay();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickScreenshot() async {
    final file = await _paymentService.pickPaymentScreenshot();
    if (file != null) {
      setState(() => _screenshot = file);
    }
  }

  Future<void> _submit() async {
    if (_selectedMethod == 'instapay') {
      if (_screenshot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('pleaseUploadScreenshot')), backgroundColor: Colors.orange),
        );
        return;
      }

      setState(() => _isUploading = true);
      try {
        final url = await _paymentService.uploadScreenshot(_screenshot!);
        widget.onCompleted('instapay', url);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isUploading = false);
      }
    } else {
      widget.onCompleted('cash', null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(LucideIcons.shoppingBag, size: 16, color: AppTheme.primaryRed),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.itemName,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text("${widget.amount.toInt()} LE", style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(tr('selectPaymentMethod'), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildMethodCard(
          id: 'instapay',
          title: "InstaPay",
          subtitle: tr('payViaInstaPay'),
          icon: Image.asset('assets/images/instapay.png', width: 24, height: 24),
        ),
        const SizedBox(height: 12),
        _buildMethodCard(
          id: 'cash',
          title: tr('cashAtReception'),
          subtitle: tr('payAtGym'),
          icon: const Icon(LucideIcons.banknote, color: Colors.green, size: 24),
        ),
        if (_selectedMethod == 'instapay') ...[
          const SizedBox(height: 24),
          const Divider(color: Color(0xFF2A2A2A)),
          const SizedBox(height: 24),
          _buildInstaPayFlow(),
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isUploading ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isUploading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(
                    _selectedMethod == 'instapay' ? tr('confirmAndUpload') : tr('confirmCashPayment'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodCard({required String id, required String title, required String subtitle, required Widget icon}) {
    final isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRed.withValues(alpha: 0.05) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppTheme.primaryRed : const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12)),
              child: icon,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected) const Icon(LucideIcons.checkCircle2, color: AppTheme.primaryRed, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInstaPayFlow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('followSteps'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildStep(1, tr('clickToOpenInstaPay'), action: TextButton.icon(
          onPressed: _handleInstaPay,
          icon: const Icon(LucideIcons.externalLink, size: 14),
          label: Text(tr('openInstaPay')),
          style: TextButton.styleFrom(foregroundColor: AppTheme.primaryRed, padding: EdgeInsets.zero),
        )),
        _buildStep(2, "${tr('enterAmountManually')}: ${widget.amount.toInt()} LE"),
        _buildStep(3, tr('uploadTransferScreenshot'), action: GestureDetector(
          onTap: _pickScreenshot,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A), style: BorderStyle.solid),
            ),
            child: _screenshot != null
                ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(_screenshot!, fit: BoxFit.cover))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.image, color: Colors.grey, size: 32),
                      const SizedBox(height: 8),
                      Text(tr('tapToUpload'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
          ),
        )),
      ],
    );
  }

  Widget _buildStep(int n, String text, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24, height: 24,
            decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle),
            child: Center(child: Text("$n", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                if (action != null) action,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
