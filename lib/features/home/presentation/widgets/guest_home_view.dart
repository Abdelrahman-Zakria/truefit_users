import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../domain/entities/outdoor_session_entity.dart';
import '../../domain/entities/home_offer_entity.dart';
import '../../domain/entities/home_package_entity.dart';
import 'banner_carousel.dart';
import 'home_modals.dart';

class GuestHomeView extends StatelessWidget {
  final String lang;
  final List<PromotionEntity> promotions;
  final List<OutdoorSessionEntity> outdoorSessions;
  final List<HomeOfferEntity> offers;
  final List<HomePackageEntity> packages;
  final VoidCallback onJoinNow;

  const GuestHomeView({
    super.key,
    required this.lang,
    required this.promotions,
    required this.outdoorSessions,
    required this.offers,
    required this.packages,
    required this.onJoinNow,
  });

  String tr(String key) => Translations.tr(key, lang);

  void _showModal(BuildContext context, Widget modal) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => modal);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHero(),
        const SizedBox(height: 24),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(lang == 'ar' ? "العروض والإعلانات" : "Promotions & Ads", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
        const SizedBox(height: 16),
        BannerCarousel(promotions: promotions, lang: lang),
        _buildGuestNotice(),
        _buildOffers(context),
        _buildPackages(context),
        _buildOutdoorSessions(context),
        _buildWhyJoin(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFDC143C), Color(0xFF7A0A1E)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)), child: const Icon(LucideIcons.dumbbell, color: Colors.white, size: 28)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('welcomeTo'), style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                  const Text('TRUE FIT GYM & SPA', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(tr('premiumFitness'), style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onJoinNow,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Text(tr('viewMemberships'), style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 8), const Icon(LucideIcons.arrowRight, size: 16)]),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestNotice() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.3))),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(LucideIcons.lock, color: AppTheme.primaryRed, size: 18)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('guestBannerTitle'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(tr('guestBannerSub'), style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffers(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 16), child: Text(tr('offers'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: offers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final o = offers[index];
            return GestureDetector(
              onTap: () => _showModal(context, OfferDetailModal(offer: o, lang: lang)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Color(int.parse(o.accentColor.replaceFirst('#', '0xFF'))), borderRadius: BorderRadius.circular(8)), child: Text(o.tag[lang] ?? o.tag['en']!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 12),
                    Text(o.title[lang] ?? o.title['en']!, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(o.description[lang] ?? o.description['en']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    Row(children: [Text(tr('learnMore'), style: const TextStyle(color: AppTheme.primaryRed, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(width: 4), const Icon(LucideIcons.chevronRight, color: AppTheme.primaryRed, size: 12)]),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPackages(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 32, 20, 16), child: Text(tr('packages'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: packages.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final p = packages[index];
            return GestureDetector(
              onTap: () => _showModal(context, PackageDetailModal(package: p, lang: lang, onSubscribe: onJoinNow)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: p.popular ? AppTheme.primaryRed.withValues(alpha: 0.3) : const Color(0xFF2A2A2A))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [Text(p.name[lang] ?? p.name['en']!, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)), if (p.popular) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(6)), child: Text(tr('mostPopular'), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)))]]),
                        const SizedBox(height: 4),
                        ... (p.features[lang] ?? p.features['en']!).take(2).map((f) => Row(children: [const Icon(LucideIcons.check, color: AppTheme.primaryRed, size: 12), const SizedBox(width: 4), Text(f, style: const TextStyle(color: Colors.grey, fontSize: 11))])),
                      ],
                    ),
                    Text('${p.price.toInt()} LE', style: const TextStyle(color: AppTheme.primaryRed, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOutdoorSessions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 32, 20, 4), child: Text(tr('outdoorSessions'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(tr('availableForAll'), style: const TextStyle(color: Colors.grey, fontSize: 12))),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: outdoorSessions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final s = outdoorSessions[index];
            final isFull = s.spots == 0;
            return GestureDetector(
              onTap: () => _showModal(context, OutdoorSessionDetailModal(session: s, lang: lang, onBook: onJoinNow)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.title[lang] ?? s.title['en']!, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: (isFull ? Colors.grey : Colors.green).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(isFull ? tr('full') : '${s.spots} ${tr('spotsLeft')}', style: TextStyle(color: isFull ? Colors.grey : Colors.green, fontSize: 10, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, color: Colors.grey, size: 12),
                        const SizedBox(width: 4),
                        Text(s.location[lang] ?? s.location['en']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(width: 16),
                        const Icon(LucideIcons.clock, color: Colors.grey, size: 12),
                        const SizedBox(width: 4),
                        Text(s.time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const Spacer(),
                        Text(s.price == 0 ? tr('free') : '${s.price.toInt()} LE', style: const TextStyle(color: AppTheme.primaryRed, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWhyJoin() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('whyJoin'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ... [tr('reason1'), tr('reason2'), tr('reason3'), tr('reason4')].map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const Icon(LucideIcons.star, color: AppTheme.primaryRed, size: 20),
                const SizedBox(width: 16),
                Text(r, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
