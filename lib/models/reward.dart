class Reward {
  String id;
  String name;
  String description;
  int pointsNeeded; // Puntos necesarios para desbloquear la recompensa
  String imageUrl; // URL de la imagen de la recompensa
  bool isUnlocked; // Indica si la recompensa ya fue desbloqueada

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsNeeded,
    required this.imageUrl,
    this.isUnlocked = false, // Valor por defecto: false
  });

  Reward copyWith({
    String? id,
    String? name,
    String? description,
    int? pointsNeeded,
    String? imageUrl,
    bool? isUnlocked,
  }) {
    return Reward(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pointsNeeded: pointsNeeded ?? this.pointsNeeded,
      imageUrl: imageUrl ?? this.imageUrl,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pointsNeeded': pointsNeeded,
      'imageUrl': imageUrl,
      'isUnlocked': isUnlocked,
    };
  }

  factory Reward.fromMap(Map<String, dynamic> map) {
    return Reward(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      pointsNeeded: map['pointsNeeded'],
      imageUrl: map['imageUrl'],
      isUnlocked: map['isUnlocked'] ?? false,
    );
  }
}