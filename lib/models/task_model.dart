class TaskAssignment {
  final int id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String status;
  final String taskType;

  TaskAssignment({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.status,
    required this.taskType,
  });

  factory TaskAssignment.fromJson(Map<String, dynamic> json) {
    return TaskAssignment(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      status: json['status'],
      taskType: json['taskType'],
    );
  }
}

class TaskFeedback {
  final int satisfactionRating;
  final int difficultyRating;
  final int utilityRating;
  final String? comments;

  TaskFeedback({
    required this.satisfactionRating,
    required this.difficultyRating,
    required this.utilityRating,
    this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      'satisfactionRating': satisfactionRating,
      'difficultyRating': difficultyRating,
      'utilityRating': utilityRating,
      'comments': comments,
    };
  }
}
