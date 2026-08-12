import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../domain/entities/outdoor_session_entity.dart';
import '../../domain/entities/home_offer_entity.dart';
import '../../domain/entities/home_package_entity.dart';

class HomeModalWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final String lang;

  const HomeModalWrapper({super.key, required this.title, required this.child, required this.lang});

  @override
  Widget build(BuildContext context) {
    final isRtl = lang == 'ar';
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
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
          ],
        ),
      ),
    );
  }
}

class OutdoorSessionDetailModal extends StatelessWidget {
  final OutdoorSessionEntity session;
  final String lang;
  final VoidCallback onBook;

  const OutdoorSessionDetailModal({super.key, required this.session, required this.lang, required this.onBook});

  String tr(String key) => Translations.tr(key, lang);

  @override
  Widget build(BuildContext context) {
    final title = session.title[lang] ?? session.title['en']!;
    final instructor = session.instructor[lang] ?? session.instructor['en']!;
    final isFull = session.spots == 0;

    return HomeModalWrapper(
      title: tr('sessionDetails'),
      lang: lang,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text(tr('noMembershipRequired'), style: const TextStyle(color: AppTheme.primaryRed, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                if (isFull) ...[
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Text(tr('sessionFull'), style: const TextStyle(color: Colors.grey, fontSize: 10))),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text('${tr('instructor')}: $instructor', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _buildInfoCard(LucideIcons.mapPin, tr('location'), session.location[lang] ?? session.location['en']!),
                _buildInfoCard(LucideIcons.calendar, tr('date'), session.date),
                _buildInfoCard(LucideIcons.clock, tr('time'), session.time),
                _buildInfoCard(LucideIcons.clock, tr('duration'), session.duration),
                _buildInfoCard(LucideIcons.users, tr('capacity'), '${session.spots} ${tr('spotsLeft')}'),
                _buildInfoCard(LucideIcons.tag, tr('price'), session.price == 0 ? tr('free') : '${session.price.toInt()} LE'),
              ],
            ),
            const SizedBox(height: 24),
            Text(tr('aboutSession'), style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(session.about[lang] ?? session.about['en']!, style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14, height: 1.5)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFull ? null : onBook,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, foregroundColor: Colors.white, disabledBackgroundColor: const Color(0xFF2A2A2A), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text(isFull ? tr('sessionFull') : tr('joinSession'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String val) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: AppTheme.primaryRed, size: 14), const SizedBox(width: 6), Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10))]),
          const SizedBox(height: 4),
          Expanded(child: Text(val, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class OfferDetailModal extends StatelessWidget {
  final HomeOfferEntity offer;
  final String lang;

  const OfferDetailModal({super.key, required this.offer, required this.lang});

  String tr(String key) => Translations.tr(key, lang);

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(offer.accentColor.replaceFirst('#', '0xFF')));
    return HomeModalWrapper(
      title: tr('offerDetails'),
      lang: lang,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24), border: Border.all(color: color.withValues(alpha: 0.3))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)), child: Text(offer.tag[lang] ?? offer.tag['en']!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 12),
                  Text(offer.title[lang] ?? offer.title['en']!, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(offer.description[lang] ?? offer.description['en']!, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(offer.detail[lang] ?? offer.detail['en']!, style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14, height: 1.6)),
            const SizedBox(height: 24),
            Row(children: [const Icon(LucideIcons.calendar, color: Colors.grey, size: 16), const SizedBox(width: 8), Text('${tr('validUntil')}: ', style: const TextStyle(color: Colors.grey, fontSize: 14)), Text(offer.validUntil, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text(tr('claimOffer'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PackageDetailModal extends StatelessWidget {
  final HomePackageEntity package;
  final String lang;
  final VoidCallback onSubscribe;

  const PackageDetailModal({super.key, required this.package, required this.lang, required this.onSubscribe});

  String tr(String key) => Translations.tr(key, lang);

  @override
  Widget build(BuildContext context) {
    return HomeModalWrapper(
      title: tr('packageDetails'),
      lang: lang,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFDC143C), Color(0xFFA00F2C)]), borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (package.popular) Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Text(tr('mostPopular'), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                  Text(package.name[lang] ?? package.name['en']!, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  RichText(text: TextSpan(children: [TextSpan(text: '${package.price.toInt()} ', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)), TextSpan(text: 'LE${tr('perMonth')}', style: const TextStyle(color: Colors.white70, fontSize: 16))])),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(tr('whatsIncluded'), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 16),
            ... (package.features[lang] ?? package.features['en']!).map((f) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [const Icon(LucideIcons.check, color: AppTheme.primaryRed, size: 18), const SizedBox(width: 12), Text(f, style: const TextStyle(color: Colors.white, fontSize: 14))]))),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubscribe,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text(tr('subscribeNow'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
