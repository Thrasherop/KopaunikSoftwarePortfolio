import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio_pair_programmed/widgets/portfolio_card.dart';
import 'package:portfolio_pair_programmed/widgets/portfolio_carousel.dart';
import 'package:portfolio_pair_programmed/widgets/hero_header.dart';
import 'package:portfolio_pair_programmed/widgets/recommendation_section.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF7C8CF8), // lavender-blue accent
        secondary: Color(0xFF7C8CF8), // unify accent with primary for cohesion
        surface: Color(0xFF121212),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F1115),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Joshua Kopaunik',
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Map<String, dynamic>> _rawData;
  late Future<List<PortfolioItem>> _portfolioItems;

  @override
  void initState() {
    super.initState();
    _rawData = _loadRaw();
    _portfolioItems = _loadPortfolioItems();
  }

  Future<Map<String, dynamic>> _loadRaw() async {
    final jsonString = await rootBundle.loadString('assets/portfolio_data.json');
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  Future<List<PortfolioItem>> _loadPortfolioItems() async {
    final String jsonString =
        await rootBundle.loadString('assets/portfolio_data.json');
    final Map<String, dynamic> data = json.decode(jsonString);

    final List<PortfolioItem> allItems = [];

    final List<dynamic> projectsData = data['projects'];
    for (var project in projectsData) {
      allItems.add(
        PortfolioItem(
          title: project['title'],
          imagePath: project['image'],
          type: PortfolioItemType.project,
          imageNormalizationMethod: _parseNormalization(project['image_normalization_method']),
          sections: [
            {'Purpose': project['purpose']},
            {'Details': project['details']},
            {'My Responsibilities': project['responsibilities']},
          ],
        ),
      );
    }

    final List<dynamic> experimentsData = data['experiments'];
    for (var experiment in experimentsData) {
      allItems.add(
        PortfolioItem(
          title: experiment['title'],
          imagePath: experiment['image'],
          type: PortfolioItemType.experiment,
          imageNormalizationMethod: _parseNormalization(experiment['image_normalization_method']),
          sections: [
            {'Hypothesis': experiment['hypothesis']},
            {'Details': experiment['details']},
            {'Results': experiment['results']},
          ],
        ),
      );
    }

    return allItems;
  }

  ImageNormalizationMethod _parseNormalization(dynamic value) {
    final str = (value as String?)?.toLowerCase();
    switch (str) {
      case 'normalize_to_width':
        return ImageNormalizationMethod.normalizeToWidth;
      case 'enforce_aspect_ratio':
      default:
        return ImageNormalizationMethod.enforceAspectRatio;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _rawData,
        builder: (context, rawSnapshot) {
          if (rawSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (rawSnapshot.hasError) {
            return Center(child: Text('Error: ${rawSnapshot.error}'));
          }

          final introText = rawSnapshot.data?['intro'] as String? ?? '';
          final recommendationText =
              rawSnapshot.data?['recommendation'] as String? ?? '';
          final List<dynamic> order =
              (rawSnapshot.data?['order'] as List<dynamic>? ??
                  ['experiments', 'projects', 'recommendation']);

          return FutureBuilder<List<PortfolioItem>>(
            future: _portfolioItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final allItems = snapshot.data!;
                final projects = allItems
                    .where((item) => item.type == PortfolioItemType.project)
                    .toList();
                final experiments = allItems
                    .where((item) => item.type == PortfolioItemType.experiment)
                    .toList();

                final slivers = <Widget>[SliverToBoxAdapter(child: HeroHeader(intro: introText))];

                for (final key in order) {
                  switch (key) {
                    case 'projects':
                      slivers.add(
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: PortfolioCarousel(title: 'Projects', items: projects),
                          ),
                        ),
                      );
                      break;
                    case 'experiments':
                      slivers.add(
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: PortfolioCarousel(title: 'Experiments', items: experiments),
                          ),
                        ),
                      );
                      break;
                    case 'recommendation':
                      slivers.add(
                        SliverToBoxAdapter(
                          child: RecommendationSection(text: recommendationText),
                        ),
                      );
                      break;
                    default:
                      break;
                  }
                }

                slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 48)));

                return CustomScrollView(slivers: slivers);
              } else {
                return const Center(child: Text('No data found.'));
              }
            },
          );
        },
      ),
    );
  }
}
