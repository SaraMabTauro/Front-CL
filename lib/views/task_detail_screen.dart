import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/task_controller.dart';
import '../models/task_model.dart';
import '../core/constants.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskAssignment task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentsController = TextEditingController();
  
  int _satisfactionRating = 3;
  int _difficultyRating = 3;
  int _utilityRating = 3;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _completeTask() async {
    if (_formKey.currentState!.validate()) {
      final feedback = TaskFeedback(
        satisfactionRating: _satisfactionRating,
        difficultyRating: _difficultyRating,
        utilityRating: _utilityRating,
        comments: _commentsController.text.trim().isEmpty 
            ? null : _commentsController.text.trim(),
      );

      final taskController = Provider.of<TaskController>(context, listen: false);
      final success = await taskController.completeTask(widget.task.id, feedback);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task completed successfully!'),
            backgroundColor: Color(0xFF41644A),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.pendingStatus:
        return const Color(0xFFF8C662);
      case AppConstants.completedStatus:
        return const Color(0xFF41644A);
      case AppConstants.delayedStatus:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTaskTypeIcon(String taskType) {
    switch (taskType) {
      case AppConstants.communicationTask:
        return Icons.chat_bubble_outline;
      case AppConstants.mindfulnessTask:
        return Icons.self_improvement;
      case AppConstants.intimacyTask:
        return Icons.favorite_outline;
      case AppConstants.conflictResolutionTask:
        return Icons.handshake_outlined;
      default:
        return Icons.task_alt;
    }
  }

  String _formatTaskType(String taskType) {
    return taskType.toLowerCase().replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task.status == AppConstants.completedStatus;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: const Color(0xFFF8C662),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.task.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getTaskTypeIcon(widget.task.taskType),
                          color: _getStatusColor(widget.task.status),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.task.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF20263F),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTaskType(widget.task.taskType),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.task.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.task.status.toLowerCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (widget.task.dueDate != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Due: ${_formatDate(widget.task.dueDate!)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF20263F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.task.description ?? 'No description available.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Completion Form (only if not completed)
            if (!isCompleted) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Complete Task',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF20263F),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Satisfaction Rating
                      _RatingSection(
                        title: 'How satisfied are you with this task?',
                        value: _satisfactionRating,
                        onChanged: (value) {
                          setState(() {
                            _satisfactionRating = value;
                          });
                        },
                        color: const Color(0xFF41644A),
                      ),
                      const SizedBox(height: 24),
                      
                      // Difficulty Rating
                      _RatingSection(
                        title: 'How difficult was this task?',
                        value: _difficultyRating,
                        onChanged: (value) {
                          setState(() {
                            _difficultyRating = value;
                          });
                        },
                        color: const Color(0xFFF8C662),
                      ),
                      const SizedBox(height: 24),
                      
                      // Utility Rating
                      _RatingSection(
                        title: 'How useful was this task?',
                        value: _utilityRating,
                        onChanged: (value) {
                          setState(() {
                            _utilityRating = value;
                          });
                        },
                        color: const Color(0xFF595082),
                      ),
                      const SizedBox(height: 24),
                      
                      // Comments
                      TextFormField(
                        controller: _commentsController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Additional Comments (Optional)',
                          hintText: 'Share your thoughts about this task...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFF8C662)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Complete Button
                      Consumer<TaskController>(
                        builder: (context, taskController, child) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: taskController.isLoading ? null : _completeTask,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF41644A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: taskController.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'Complete Task',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      
                      // Error Message
                      Consumer<TaskController>(
                        builder: (context, taskController, child) {
                          if (taskController.errorMessage != null) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                taskController.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Completed Task Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF41644A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF41644A).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Color(0xFF41644A),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Task Completed!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF41644A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Great job! You have successfully completed this task.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF41644A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  final String title;
  final int value;
  final ValueChanged<int> onChanged;
  final Color color;

  const _RatingSection({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF20263F),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final rating = index + 1;
            return GestureDetector(
              onTap: () => onChanged(rating),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: rating <= value ? color : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: rating <= value ? color : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    rating.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: rating <= value ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('1', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('2', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('3', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('4', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('5', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}