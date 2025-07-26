class User {
  final int id;
  final String correo;
  final String username;
  final String contrasena;
  final String nombre;
  final String apellido;
  final String rol;
  final int idPsicologo;
  final int? parejaId;
  final String fechaCreacion;

  User({
    required this.id,
    required this.correo,
    required this.username,
    required this.contrasena,
    required this.nombre,
    required this.apellido,
    required this.rol,
    required this.idPsicologo,
    this.parejaId,
    required this.fechaCreacion,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      correo: json['correo'],
      username: json['username'],
      contrasena: json['contrasena'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      rol: json['rol'],
      idPsicologo: json['idPsicologo'] ?? 0, 
      fechaCreacion: json['fechaCreacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'correo': correo,
      'username': username,
      'contrasena': contrasena,
      'nombre': nombre,
      'apellido': apellido,
      'rol': rol,
      'idPsicologo': idPsicologo,
      'parejaId': parejaId,
      'fechaCreacion': fechaCreacion,
    };
  }

  User copyWith({
    int? id,
    String? correo,
    String? username,
    String? contrasena,
    String? nombre,
    String? apellido,
    String? rol,
    int? idPsicologo,
    int? parejaId,
    String? fechaCreacion,
  }) {
    return User(
      id: id ?? this.id,
      correo: correo ?? this.correo,
      username: username ?? this.username,
      contrasena: contrasena ?? this.contrasena,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      rol: rol ?? this.rol,
      idPsicologo: idPsicologo ?? this.idPsicologo,
      parejaId: parejaId ?? this.parejaId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}

class Client {
  final int id;
  final String nombre;
  final String apellido;

  Client({required this.id, required this.nombre, required this.apellido});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
    );
  }
}