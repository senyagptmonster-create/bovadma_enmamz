import '../models/question.dart';

/// Everything needed to (re)build a round. Carried from the home screen through
/// the quiz into the result screen so "Play again" can deal a fresh shuffle
/// without reaching back up the navigation stack.
class RoundSpec {
  final String categoryId;
  final String categoryName;
  final List<Question> pool;
  final int limit;

  const RoundSpec({
    required this.categoryId,
    required this.categoryName,
    required this.pool,
    this.limit = 8,
  });
}
