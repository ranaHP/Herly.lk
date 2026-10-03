import '../../core/strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/repositories.dart';
import '../../core/settings.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});
  @override
  State<LearnScreen> createState() => _LearnState();
}

class _LearnState extends State<LearnScreen> {
  String category = 'For You', query = '';
  @override
  Widget build(BuildContext context) {
    final articles = DemoContent.articles.indexed.where(
      (pair) =>
          (category == 'For You' || pair.$2.category == category) &&
          context.tr(pair.$2.title).toLowerCase().contains(query.toLowerCase()),
    );
    return HerlyPage(
      title: 'A little understanding',
      subtitle: 'Curiosity is a beautiful place to start.',
      children: [
        TextField(
          onChanged: (v) => setState(() => query = v),
          decoration: InputDecoration(
            hintText: 'Find something for you',
            prefixIcon: Icon(Icons.search),
          ).localized(context),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in [
              'For You',
              'Cycle',
              'Mental wellbeing',
              'Lifestyle',
              'Relationships',
              'Nutrition',
            ])
              ChoiceChip(
                label: LText(value),
                selected: category == value,
                onSelected: (_) => setState(() => category = value),
              ),
          ],
        ),
        if (articles.isEmpty)
          const HerlyCard(
            child: Column(
              children: [
                Art('empty'),
                LText('No articles found. Try another search.'),
              ],
            ),
          ),
        for (final pair in articles)
          HerlyCard(
            tint: pair.$1.isEven ? HerlyTokens.peach : HerlyTokens.lavender,
            onTap: () => context.push('/article/${pair.$1}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Art(pair.$2.art, size: 100),
                const SizedBox(height: 20),
                LText(
                  pair.$2.category.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                LText(
                  pair.$2.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const LText('3 min read · Demo content →'),
              ],
            ),
          ),
      ],
    );
  }
}

class ArticleScreen extends ConsumerStatefulWidget {
  final int id;
  const ArticleScreen({super.key, required this.id});
  @override
  ConsumerState<ArticleScreen> createState() => _ArticleState();
}

class _ArticleState extends ConsumerState<ArticleScreen> {
  bool read = false;
  @override
  void initState() {
    super.initState();
    read =
        ref.read(preferencesProvider).getBool('article-${widget.id}') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.id < 0 || widget.id >= DemoContent.articles.length) {
      return const HerlyPage(
        title: 'Article not found',
        children: [LText('Return to the library to choose an article.')],
      );
    }
    final article = DemoContent.articles[widget.id];
    return HerlyPage(
      title: article.category,
      children: [
        Art(article.art, size: 140),
        LText(article.title, style: Theme.of(context).textTheme.displayMedium),
        const LText('HERLY EDITORIAL · DEMO CONTENT · 3 MIN'),
        LinearProgressIndicator(value: read ? 1 : 0),
        LText(article.body, style: Theme.of(context).textTheme.bodyLarge),
        HerlyButton(
          read ? 'Finished reading' : 'Mark as read',
          icon: Icons.check,
          onPressed: () async {
            await ref
                .read(preferencesProvider)
                .setBool('article-${widget.id}', true);
            setState(() => read = true);
          },
        ),
      ],
    );
  }
}
