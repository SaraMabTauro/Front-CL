import 'package:flutter/material.dart';

const Color kPrimaryColor = Color.fromARGB(255, 98, 147, 197);

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidad'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('¡Aquí podrás compartir tus logros con otros usuarios!'),
      ),
    );
  }
}