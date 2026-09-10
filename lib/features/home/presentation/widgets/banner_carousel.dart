import 'package:flutter/material.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../../../core/theme/app_theme.dart';

class BannerCarousel extends StatefulWidget {
  final List<PromotionEntity> promotions;
  final String lang;

  const BannerCarousel({super.key, required this.promotions, required this.lang});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentPage = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.promotions.isEmpty) return const SizedBox();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            itemCount: widget.promotions.length,
            controller: _pageController,
            padEnds: false,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final promo = widget.promotions[index];
              return _buildBanner(promo);
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildIndicator(),
      ],
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.promotions.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 4,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? AppTheme.primaryRed : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(PromotionEntity promo) {
    final title = promo.title[widget.lang] ?? promo.title['en'] ?? "";
    final desc = promo.description[widget.lang] ?? promo.description['en'] ?? "";
    final cta = promo.cta[widget.lang] ?? promo.cta['en'] ?? "";

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 0, top: 8, bottom: 8),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
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
            right: widget.lang == 'en' ? 16 : null,
            left: widget.lang == 'ar' ? 16 : null,
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
