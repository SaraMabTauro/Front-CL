import 'package:flutter/material.dart';

const Color kPrimaryColor = Color.fromARGB(255, 98, 147, 197);


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Perfil'),
            leading: const Icon(Icons.person),
            onTap: () {
              // TODO: Implementar la navegación a la pantalla de perfil
            },
          ),
          ListTile(
            title: const Text('Notificaciones'),
            leading: const Icon(Icons.notifications),
            onTap: () {
              // TODO: Implementar la navegación a la pantalla de notificaciones
            },
          ),
          ListTile(
            title: const Text('Tema'),
            leading: const Icon(Icons.brightness_4),
            onTap: () {
              // TODO: Implementar la lógica para cambiar el tema
            },
          ),
          ListTile(
            title: const Text('Idioma'),
            leading: const Icon(Icons.language),
            onTap: () {
              // TODO: Implementar la lógica para cambiar el idioma
            },
          ),
          ListTile(
            title: const Text('Ayuda/Soporte'),
            leading: const Icon(Icons.help),
            onTap: () {
              // TODO: Implementar la navegación a la pantalla de ayuda/soporte
            },
          ),
        ],
      ),
    );
  }
}