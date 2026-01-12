class User {
  int? id;
  String username;
  String password;
  String role; // Contoh value: 'admin' atau 'user'

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  // Konversi dari Object ke Map (untuk simpan ke Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
    };
  }

  // Konversi dari Map ke Object (saat baca dari Database)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
    );
  }

  // Optional: Untuk debugging (print object di console)
  @override
  String toString() {
    return 'User{id: $id, username: $username, role: $role}';
  }
}