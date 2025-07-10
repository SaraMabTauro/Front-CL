class Achievement {
  String id;
  String name;
  String description;
  String imageUrl; // URL de la imagen del logro
  bool isUnlocked; // Indica si el logro ya fue desbloqueado
  DateTime? unlockedDate; // Fecha en que se desbloqueó el logro (opcional)

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.isUnlocked = false, // Valor por defecto: false
    this.unlockedDate,
  });

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    bool? isUnlocked,
    DateTime? unlockedDate,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'isUnlocked': isUnlocked,
      'unlockedDate': unlockedDate?.toIso8601String(), // Convertir DateTime a String
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      isUnlocked: map['isUnlocked'] ?? false,
      unlockedDate: map['unlockedDate'] != null ? DateTime.tryParse(map['unlockedDate']) : null,
    );
  }
}