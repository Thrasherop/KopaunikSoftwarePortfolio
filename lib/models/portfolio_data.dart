import 'package:portfolio_pair_programmed/widgets/portfolio_card.dart';

class PortfolioData {
  final String intro;
  final String recommendation;
  final List<PortfolioItem> items;

  PortfolioData({
    required this.intro,
    required this.recommendation,
    required this.items,
  });
}
