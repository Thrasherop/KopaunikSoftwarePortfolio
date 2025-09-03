import 'package:flutter/material.dart';

class HeroHeader extends StatelessWidget {
  final String intro;
  final bool fullHeight; // when true, hero fills viewport height (mobile)
  const HeroHeader({super.key, required this.intro, this.fullHeight = false});

  @override
  Widget build(BuildContext context) {
    final double containerHeight = fullHeight
        ? MediaQuery.of(context).size.height
        : 320;

    return Container(
      height: containerHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F1115), // deep slate
            Color(0xFF1A1E27), // slightly lighter slate
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome to my Portfolio',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 40,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  intro,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.95),
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
