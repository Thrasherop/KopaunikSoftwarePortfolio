import 'dart:math' as math;
import 'package:flutter/material.dart';

enum PortfolioItemType { project, experiment }

enum ImageNormalizationMethod {
  enforceAspectRatio, // 16:9 with BoxFit.cover (crop)
  normalizeToWidth,   // width fills, height follows (no crop)
}

/// A unified data model to represent any item in a portfolio carousel.
class PortfolioItem {
  final String title;
  final String imagePath;
  final List<Map<String, String>> sections;
  final PortfolioItemType type;
  final ImageNormalizationMethod imageNormalizationMethod;

  PortfolioItem({
    required this.title,
    required this.imagePath,
    required this.sections,
    required this.type,
    this.imageNormalizationMethod = ImageNormalizationMethod.enforceAspectRatio,
  });
}

/// A reusable widget that displays a single portfolio item (project or experiment).
class PortfolioCard extends StatefulWidget {
  final PortfolioItem item;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final double fixedContentHeight; // H_fixed provided by carousel

  const PortfolioCard({
    super.key,
    required this.item,
    this.isExpanded = false,
    required this.fixedContentHeight,
    required this.onToggleExpand,
  });

  // Visual constants for panel chrome
  static const double _panelPadding = 16;
  static const double _buttonHeight = 36;
  static const double _buttonSpacing = 8;

  @override
  State<PortfolioCard> createState() => _PortfolioCardState();
}

class _PortfolioCardState extends State<PortfolioCard> {
  static final Map<String, Size> _imageSizeCache = {};
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  Size? _intrinsicSize; // original pixel size of the image asset

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImageSizeIfNeeded();
  }

  @override
  void dispose() {
    if (_imageStream != null && _imageStreamListener != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
    super.dispose();
  }

  void _resolveImageSizeIfNeeded() {
    if (widget.item.imageNormalizationMethod != ImageNormalizationMethod.normalizeToWidth) return;
    if (_imageSizeCache.containsKey(widget.item.imagePath)) {
      _intrinsicSize = _imageSizeCache[widget.item.imagePath];
      return;
    }
    final asset = AssetImage(widget.item.imagePath);
    final stream = asset.resolve(createLocalImageConfiguration(context));
    _imageStream = stream;
    _imageStreamListener = ImageStreamListener((ImageInfo info, bool syncCall) {
      final size = Size(info.image.width.toDouble(), info.image.height.toDouble());
      _imageSizeCache[widget.item.imagePath] = size;
      if (mounted) {
        setState(() => _intrinsicSize = size);
      }
    });
    stream.addListener(_imageStreamListener!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  
    return LayoutBuilder(
      builder: (context, constraints) {
        // Compute base measurements using the actual card width
        final double cardWidth = constraints.maxWidth;
        final double imageBaseHeight = _imageBaseHeightForWidth(widget.item.imageNormalizationMethod, cardWidth);
        final double bandHeight = math.max(0, widget.fixedContentHeight - imageBaseHeight);

        // Helper to measure text heights for content sizing
        double measureText(String text, TextStyle? style, double maxWidth) {
          final tp = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: TextDirection.ltr,
            maxLines: null,
          );
          tp.layout(maxWidth: maxWidth);
          return tp.size.height;
        }


        final TextStyle? titleStyle = theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700);
        final TextStyle? sectionTitleStyle = theme.textTheme.labelLarge?.copyWith(
          color: Colors.blue[200],
          fontWeight: FontWeight.w600,
        );
        final TextStyle? bodyStyle = theme.textTheme.bodyMedium?.copyWith(
          height: 1.5,
          color: Colors.white.withOpacity(0.9),
        );

        final double innerWidth = cardWidth - (10 * 2) - (PortfolioCard._panelPadding * 2); // outer padding + panel padding
        final double headerHeight = measureText(widget.item.title, titleStyle, innerWidth) + 10; // +spacing

        double contentHeight = headerHeight;
        for (final section in widget.item.sections) {
          contentHeight += measureText(section.keys.first, sectionTitleStyle, innerWidth);
          contentHeight += 4; // spacing
          contentHeight += measureText(section.values.first, bodyStyle, innerWidth);
          contentHeight += 10; // spacing after paragraph
        }

        // Decide if truncation is needed in collapsed state
        final bool needsTruncate = contentHeight + (PortfolioCard._panelPadding * 2) > bandHeight;

        // Compute expanded panel height: only as much as needed, capped to fixedContentHeight
        final double desiredPanelHeight = contentHeight + (PortfolioCard._panelPadding * 2) + (needsTruncate ? (PortfolioCard._buttonHeight + PortfolioCard._buttonSpacing) : 0);
        final double maxPanelHeight = widget.fixedContentHeight; // band + image
        final double expandedPanelHeight = math.min(desiredPanelHeight, maxPanelHeight);

        // Build the image with explicit base height (for deterministic overlay behavior)
        Widget image;
        switch (widget.item.imageNormalizationMethod) {
          case ImageNormalizationMethod.enforceAspectRatio:
            image = SizedBox(
              height: imageBaseHeight,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(14.0)),
                child: Image.asset(
                  widget.item.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF222631),
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 50, color: Colors.white70),
                      ),
                    );
                  },
                ),
              ),
            );
            break;
          case ImageNormalizationMethod.normalizeToWidth:
            image = SizedBox(
              height: imageBaseHeight,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(14.0)),
                child: Image.asset(
                  widget.item.imagePath,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF222631),
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 50, color: Colors.white70),
                      ),
                    );
                  },
                ),
              ),
            );
            break;
        }

        // Build the content widgets (styled)
        final List<Widget> sectionWidgets = [];
        for (final section in widget.item.sections) {
          sectionWidgets.addAll([
            Text(
              section.keys.first,
              style: sectionTitleStyle,
            ),
            const SizedBox(height: 4),
            Text(
              section.values.first,
              style: bodyStyle,
            ),
            const SizedBox(height: 10),
          ]);
        }

        final headerRow = Row(
          children: [
            Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.item.title,
                style: titleStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        );

        // Panel current height based on expansion state
        final double panelHeight = widget.isExpanded ? expandedPanelHeight : bandHeight;

        // Content viewport height (space for scrollable sections only),
        // subtract header and spacing so the Column never overflows.
        double contentViewportHeight = panelHeight
            - (PortfolioCard._panelPadding * 2)
            - headerHeight
            - 10; // let text use full width/height; button overlays and does not reserve space
        if (contentViewportHeight < 0) contentViewportHeight = 0;

        // Calculate right padding so text never sits under the bottom-right button
        final Widget panel = AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          height: panelHeight,
          padding: const EdgeInsets.all(PortfolioCard._panelPadding),
          decoration: BoxDecoration(
            // Fully opaque to clearly separate text from the image
            color: Colors.black,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Stack(
            children: [
              // Scrollable content area; scroll only when expanded beyond available height
              Positioned.fill(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerRow,
                    const SizedBox(height: 10),
                    SizedBox(
                      height: contentViewportHeight,
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            physics: widget.isExpanded ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: sectionWidgets,
                            ),
                          ),
                          if (!widget.isExpanded && needsTruncate)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 40,
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.0),
                                        Colors.black.withOpacity(0.35),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (needsTruncate)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: TextButton(
                    onPressed: widget.onToggleExpand,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: theme.colorScheme.primary, // fully opaque
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: Text(widget.isExpanded ? 'See less' : 'See more…'),
                  ),
                ),
            ],
          ),
        );

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: const Color(0xFF1A1E27),
            borderRadius: BorderRadius.circular(14.0),
            clipBehavior: Clip.antiAlias, // hard clip to avoid cross-slide bleed
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Stack(
                children: [
                  // Image forms the top region
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [image],
                  ),
                  // Bottom-anchored panel that expands into the image as needed
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: panel,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _imageBaseHeightForWidth(ImageNormalizationMethod method, double width) {
    switch (method) {
      case ImageNormalizationMethod.enforceAspectRatio:
        return width / (16 / 9);
      case ImageNormalizationMethod.normalizeToWidth:
        // If we know intrinsic size, compute scaled height, clamped to an upper bound
        if (_intrinsicSize != null && _intrinsicSize!.width > 0) {
          final ratio = _intrinsicSize!.height / _intrinsicSize!.width;
          final computed = width * ratio;
          return math.min(420.0, computed);
        }
        return 420.0;
    }
  }
}

