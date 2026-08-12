import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../domain/entities/coach_entity.dart';
import '../../domain/entities/pt_offer_entity.dart';

class PTPackageModal extends StatefulWidget {
  final String lang;
  final CoachEntity coach;
  final List<PTOfferEntity> offers;
  final Function(int sessions) onBuy;

  const PTPackageModal({
    super.key,
    required this.lang,
    required this.coach,
    required this.offers,
    required this.onBuy,
  });

  @override
  State<PTPackageModal> createState() => _PTPackageModalState();
}

class _PTPackageModalState extends State<PTPackageModal> {
  int _currentStep = 0; // 0: package, 1: payment, 2: success
  late PTOfferEntity _selectedOffer;

  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedOffer = widget.offers.first;
  }

  String tr(String key) => Translations.tr(key, widget.lang);

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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF3A3A3A), borderRadius: BorderRadius.circular(2))),
              
              if (_currentStep < 2) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (_currentStep > 0)
                            IconButton(
                              onPressed: () => setState(() => _currentStep--),
                              icon: Icon(isRtl ? LucideIcons.chevronRight : LucideIcons.chevronLeft, color: Colors.white, size: 20),
                            ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${tr('step')} ${_currentStep + 1} ${tr('of')} 2", style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                              Text(
                                _currentStep == 0 ? tr('choosePTPackage') ?? "Choose Package" : tr('paymentDetails'),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF1A1A1A)),
              ],

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildStepContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    if (_currentStep == 0) return _buildPackageStep();
    if (_currentStep == 1) return _buildPaymentStep();
    return _buildSuccessStep();
  }

  Widget _buildPackageStep() {
    return Column(
      children: [
        ...widget.offers.map((offer) {
          final isSelected = _selectedOffer.id == offer.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedOffer = offer),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryRed.withValues(alpha:0.1) : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppTheme.primaryRed : const Color(0xFF2A2A2A)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppTheme.primaryRed : Colors.transparent,
                          border: Border.all(color: isSelected ? AppTheme.primaryRed : const Color(0xFF3A3A3A), width: 2),
                        ),
                        child: isSelected ? const Icon(LucideIcons.check, size: 12, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 12),
                      Text("${offer.sessions} ${tr('sessions')}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Text("${offer.price.toInt()} LE", style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        _buildActionButton(tr('continue'), () => setState(() => _currentStep++)),
      ],
    );
  }

  Widget _buildPaymentStep() {
    final total = _selectedOffer.price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha:0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.primaryRed.withValues(alpha:0.3))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [const Icon(LucideIcons.user, size: 16, color: AppTheme.primaryRed), const SizedBox(width: 8), Text("${widget.coach.name} · ${_selectedOffer.sessions} ${tr('sessions')}", style: const TextStyle(color: Colors.white, fontSize: 13))]),
              Text("${total.toInt()} LE", style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(tr('nameOnCard'), "John Doe", _cardNameController, LucideIcons.user),
        const SizedBox(height: 16),
        _buildTextField(tr('cardNumber'), "0000 0000 0000 0000", _cardNumberController, LucideIcons.creditCard),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField(tr('expiry'), "MM/YY", _expiryController, LucideIcons.calendar)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField("CVV", "123", _cvvController, LucideIcons.lock)),
          ],
        ),
        const SizedBox(height: 24),
        _buildActionButton("${tr('pay')} ${total.toInt()} LE", () {
          widget.onBuy(_selectedOffer.sessions);
          setState(() => _currentStep++);
        }),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      children: [
        const SizedBox(height: 32),
        Container(width: 80, height: 80, decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha:0.1), shape: BoxShape.circle), child: const Icon(LucideIcons.check, color: AppTheme.primaryRed, size: 40)),
        const SizedBox(height: 24),
        Text(tr('allSet'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("${_selectedOffer.sessions} ${tr('sessions')} with ${widget.coach.name} added to your wallet.", style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        _buildActionButton(tr('done'), () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF4B5563)),
            prefixIcon: Icon(icon, size: 16, color: const Color(0xFF6B7280)),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
