/// A single-choice question.
///
/// Parsing never throws: a malformed entry yields null and the caller drops it.
/// Bad content must not be able to take the app down.
class Question {
  final String id;
  final String prompt;
  final List<String> options;
  final int answerIndex;
  final String explanation;

  const Question({
    required this.id,
    required this.prompt,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });

  String get correctAnswer => options[answerIndex];

  bool isCorrect(int? selected) => selected != null && selected == answerIndex;

  static Question? tryParse(Object? raw) {
    if (raw is! Map) return null;

    final id = raw['id'];
    final prompt = raw['q'];
    final rawOptions = raw['o'];
    final answer = raw['a'];
    final explanation = raw['e'];

    if (id is! String || id.isEmpty) return null;
    if (prompt is! String || prompt.isEmpty) return null;
    if (rawOptions is! List || rawOptions.length < 2) return null;
    if (answer is! int) return null;

    final options = <String>[];
    for (final o in rawOptions) {
      if (o is! String || o.isEmpty) return null;
      options.add(o);
    }
    if (answer < 0 || answer >= options.length) return null;

    return Question(
      id: id,
      prompt: prompt,
      options: options,
      answerIndex: answer,
      explanation: explanation is String ? explanation : '',
    );
  }
}
