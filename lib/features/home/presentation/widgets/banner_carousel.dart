import 'package:flutter/material.dart';
import '../../domain/entities/promotion_entity.dart';

class BannerCarousel extends StatelessWidget {
  final List<PromotionEntity> promotions;
  final String lang;

  const BannerCarousel({super.key, required this.promotions, required this.lang});

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) return const SizedBox();

    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: promotions.length,
        controller: PageController(viewportFraction: 0.9, initialPage: 0),
        itemBuilder: (context, index) {
          final promo = promotions[index];
          return _buildBanner(promo);
        },
      ),
    );
  }

  Widget _buildBanner(PromotionEntity promo) {
    final title = promo.title[lang] ?? promo.title['en'] ?? "";
    final desc = promo.description[lang] ?? promo.description['en'] ?? "";
    final cta = promo.cta[lang] ?? promo.cta['en'] ?? "";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: promo.bgColors.map((c) => Color(c)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: promo.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(promo.imageUrl!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.3),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16), // Reduced padding to 16
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag - Smaller and less space
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    promo.tag,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Middle Section - Flexible
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1, // Reduced to 1 line to save space
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // CTA Button - Smaller and explicitly sized
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    cta,
                    style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: lang == 'en' ? 16 : null,
            left: lang == 'ar' ? 16 : null,
            top: 16,
            child: Text(
              promo.badge,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ],
      ),
    );
  }
}
