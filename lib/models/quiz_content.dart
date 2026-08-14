import 'question.dart';

class QuizCategory {
  final String id;
  final String name;
  final String blurb;
  final List<Question> questions;

  const QuizCategory({
    required this.id,
    required this.name,
    required this.blurb,
    required this.questions,
  });

  static QuizCategory? tryParse(Object? raw) {
    if (raw is! Map) return null;

    final id = raw['id'];
    final name = raw['name'];
    if (id is! String || id.isEmpty) return null;
    if (name is! String || name.isEmpty) return null;

    final rawQuestions = raw['questions'];
    if (rawQuestions is! List) return null;

    final questions = <Question>[];
    for (final q in rawQuestions) {
      final parsed = Question.tryParse(q);
      if (parsed != null) questions.add(parsed);
    }
    if (questions.isEmpty) return null;

    final blurb = raw['blurb'];
    return QuizCategory(
      id: id,
      name: name,
      blurb: blurb is String ? blurb : '',
      questions: questions,
    );
  }
}

class QuizContent {
  final String sport;
  final String tagline;
  final List<QuizCategory> categories;

  const QuizContent({
    required this.sport,
    required this.tagline,
    required this.categories,
  });

  static const QuizContent empty = QuizContent(
    sport: '',
    tagline: '',
    categories: <QuizCategory>[],
  );

  bool get isEmpty => categories.isEmpty;

  List<Question> get allQuestions => [
    for (final c in categories) ...c.questions,
  ];

  int get questionCount => allQuestions.length;

  static QuizContent parse(Object? raw) {
    if (raw is! Map) return empty;

    final rawCategories = raw['categories'];
    if (rawCategories is! List) return empty;

    final categories = <QuizCategory>[];
    for (final c in rawCategories) {
      final parsed = QuizCategory.tryParse(c);
      if (parsed != null) categories.add(parsed);
    }

    final sport = raw['sport'];
    final tagline = raw['tagline'];
    return QuizContent(
      sport: sport is String ? sport : '',
      tagline: tagline is String ? tagline : '',
      categories: categories,
    );
  }
}
