import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class LoveTapSection extends StatefulWidget {
  final String imagePath;
  final String description;
  final String technicalDetails;
  final String analytics;
  final List<String> sectionOrder;

  const LoveTapSection({
    super.key,
    required this.imagePath,
    required this.description,
    required this.technicalDetails,
    required this.analytics,
    this.sectionOrder = const ['description', 'technical_details', 'analytics'],
  });

  @override
  State<LoveTapSection> createState() => _LoveTapSectionState();
}

class _LoveTapSectionState extends State<LoveTapSection> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<Widget> buildTextSections() {
      final List<Widget> children = [];

      Widget section(String title, String body) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              MarkdownBody(
                data: _toMarkdown(body),
                styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                  p: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  strong: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: Colors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w700,
                  ),
                  em: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: Colors.white.withOpacity(0.9),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                softLineBreak: true,
              ),
            ],
          );

      final List<String> order = widget.sectionOrder.isEmpty
          ? const ['description', 'technical_details', 'analytics']
          : widget.sectionOrder;

      for (final key in order) {
        switch (key) {
          case 'description':
            if (widget.description.trim().isNotEmpty) {
              children..add(section('Description', widget.description))..add(const SizedBox(height: 16));
            }
            break;
          case 'technical_details':
            if (widget.technicalDetails.trim().isNotEmpty) {
              children..add(section('Technical details', widget.technicalDetails))..add(const SizedBox(height: 16));
            }
            break;
          case 'analytics':
            if (widget.analytics.trim().isNotEmpty) {
              children..add(section('Analytics', widget.analytics))..add(const SizedBox(height: 16));
            }
            break;
          default:
            // Unknown keys are ignored to keep things resilient to JSON changes
            break;
        }
      }

      if (children.isEmpty) {
        children.add(
          Text(
            'Details coming soon.',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: Colors.white.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      }

      return children;
    }

    Widget buildImage() {
      // The image scales to fit the provided height while preserving aspect ratio (no crop).
      final image = ClipRRect(
        borderRadius: BorderRadius.circular(14.0),
        child: Image.asset(
          widget.imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF222631),
              child: const Center(
                child: Icon(Icons.image_not_supported, size: 50, color: Colors.white70),
              ),
            );
          },
        ),
      );

      final decorated = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: image,
      );
      return decorated;
    }

    Widget buildTextPanel() {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1E27),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...buildTextSections(),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title outside the text block to match other sections
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 12.0),
                child: Text(
                  'LoveTap',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth >= 900;
                  if (isWide) {
                    return IntrinsicHeight(
                      child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image left
                        Flexible(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: SizedBox.expand(
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: 9 / 16,
                                  child: buildImage(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Text right
                        Flexible(
                          flex: 7,
                          child: buildTextPanel(),
                        ),
                      ],
                    ),
                    );
                  }

                  // Narrow layout: stack vertically
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14.0),
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: buildImage(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      buildTextPanel(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _toMarkdown(String input) {
    // Convert simple inline HTML tags to Markdown equivalents
    String out = input;
    out = out.replaceAll(RegExp(r'<\s*b\s*>', caseSensitive: false), '**');
    out = out.replaceAll(RegExp(r'<\s*/\s*b\s*>', caseSensitive: false), '**');
    out = out.replaceAll(RegExp(r'<\s*strong\s*>', caseSensitive: false), '**');
    out = out.replaceAll(RegExp(r'<\s*/\s*strong\s*>', caseSensitive: false), '**');
    out = out.replaceAll(RegExp(r'<\s*i\s*>', caseSensitive: false), '_');
    out = out.replaceAll(RegExp(r'<\s*/\s*i\s*>', caseSensitive: false), '_');
    out = out.replaceAll(RegExp(r'<\s*em\s*>', caseSensitive: false), '_');
    out = out.replaceAll(RegExp(r'<\s*/\s*em\s*>', caseSensitive: false), '_');
    return out;
  }
}


