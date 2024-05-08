class Question{
  final String question;
  final List<String> options;
  final int answer;

  Question({
    required this.question,
    required this.options,
    required this.answer,
  });

  Question copyWith({
    String? question,
    List<String>? options,
    int? answer,
  }) {
    return Question(
      question: question ?? this.question,
      options: options ?? this.options,
      answer: answer ?? this.answer,
      
    );
  }
}