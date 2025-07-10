import 'package:flutter/material.dart';

const Color kPrimaryColor = Color.fromARGB(255, 98, 147, 197);


class AiTipsScreen extends StatefulWidget {
  const AiTipsScreen({Key? key}) : super(key: key);

  @override
  State<AiTipsScreen> createState() => _AiTipsScreenState();
}

class _AiTipsScreenState extends State<AiTipsScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _textController.text;
    if (message.isNotEmpty) {
      setState(() {
        _messages.add('Usuario: $message');
        _messages.add('IA: (Respuesta simulada para "$message")'); // Simulación de respuesta de la IA
        _textController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consejos de la IA'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu pregunta...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
