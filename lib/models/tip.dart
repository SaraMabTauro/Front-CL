class Tip {
  String id;
  String content; // El consejo o tip
  String habitCategory; // Categoría del hábito al que se aplica el tip (ej: "Ejercicio", "Alimentación", "Productividad")

  Tip({
    required this.id,
    required this.content,
    required this.habitCategory,
  });

  Tip copyWith({
    String? id,
    String? content,
    String? habitCategory,
  }) {
    return Tip(
      id: id ?? this.id,
      content: content ?? this.content,
      habitCategory: habitCategory ?? this.habitCategory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'habitCategory': habitCategory,
    };
  }

  factory Tip.fromMap(Map<String, dynamic> map) {
    return Tip(
      id: map['id'],
      content: map['content'],
      habitCategory: map['habitCategory'],
    );
  }
}