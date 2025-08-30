import 'package:flutter/material.dart';

class RecommendationSection extends StatelessWidget {
  final String text;
  const RecommendationSection({super.key, required this.text});


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, top: 12.0),
            child: Text(
              'Letter of Recommendation',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1E27),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.92),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
