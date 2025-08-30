import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:portfolio_pair_programmed/widgets/portfolio_card.dart';

class PortfolioCarousel extends StatefulWidget {
  final String title;
  final List<PortfolioItem> items;
  final bool edgeFade;

  const PortfolioCarousel({
    super.key,
    required this.title,
    required this.items,
    this.edgeFade = true,
  });

  @override
  State<PortfolioCarousel> createState() => _PortfolioCarouselState();
}

class _PortfolioCarouselState extends State<PortfolioCarousel> {
  final CarouselSliderController _controller = CarouselSliderController();
  final Map<String, bool> _expandedByTitle = {};

  void _toggleExpanded(String title) {
    setState(() {
      _expandedByTitle[title] = !(_expandedByTitle[title] ?? false);
    });
  }

  double _imageHeightUpperBoundForItemWidth(PortfolioItem item, double itemWidth) {
    switch (item.imageNormalizationMethod) {
      case ImageNormalizationMethod.enforceAspectRatio:
        return itemWidth / (16 / 9);
      case ImageNormalizationMethod.normalizeToWidth:
        // Upper bound for width-normalized images (actual may be smaller, capped at this)
        return 420.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    const double viewportFraction = 0.68;
    const double horizontalPad = 56.0; // matches padding used around CarouselSlider

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
          child: Center(
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double viewportWidth = constraints.maxWidth - (horizontalPad * 2);
                final double itemWidth = viewportWidth * viewportFraction;

                // Compute a fixed content height across items: H_fixed = max(imageH) + H_minBand
                const double minBandHeight = 160; // larger base band for readability
                double maxImageHeight = 0;
                for (final item in widget.items) {
                  final imageH = _imageHeightUpperBoundForItemWidth(item, itemWidth);
                  if (imageH > maxImageHeight) maxImageHeight = imageH;
                }

                final double fixedContentHeight = maxImageHeight + minBandHeight;
                // Provide some allowance for card padding/margins in the outer SizedBox
                final double outerCarouselHeight = fixedContentHeight + 40;

                return SizedBox(
                  height: outerCarouselHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: horizontalPad),
                          child: CarouselSlider(
                            carouselController: _controller,
                            options: CarouselOptions(
                              height: outerCarouselHeight,
                              enlargeCenterPage: true,
                              viewportFraction: viewportFraction,
                              autoPlay: false,
                            ),
                            items: widget.items.map((item) {
                              final expanded = _expandedByTitle[item.title] ?? false;
                              return PortfolioCard(
                                item: item,
                                isExpanded: expanded,
                                fixedContentHeight: fixedContentHeight,
                                onToggleExpand: () => _toggleExpanded(item.title),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      // Gentle fade at the left/right edges of the carousel viewport
                      if (widget.edgeFade)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: horizontalPad),
                              child: Row(
                                children: [
                                  Container(
                                    width: 72,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Theme.of(context).scaffoldBackgroundColor,
                                          Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Expanded(child: SizedBox.shrink()),
                                  Container(
                                    width: 72,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerRight,
                                        end: Alignment.centerLeft,
                                        colors: [
                                          Theme.of(context).scaffoldBackgroundColor,
                                          Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _SideNavButton(
                          icon: Icons.arrow_back_ios_new,
                          onTap: () => _controller.previousPage(),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _SideNavButton(
                          icon: Icons.arrow_forward_ios,
                          onTap: () => _controller.nextPage(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SideNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SideNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
