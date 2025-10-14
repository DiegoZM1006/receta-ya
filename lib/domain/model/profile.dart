class Profile {
  String id;
  String name;
  String email;
  String? avatarUrl;
  DateTime createdAt;

  Profile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
  });

  /// Para enviar a Supabase (ej: insert) - tabla users
  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Para leer desde Supabase (ej: select) - tabla users
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['user_id'] as String,
      name: json['name'] as String,
      email: '', // El email se obtiene de auth.users, no de la tabla users
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  /// Para crear un perfil completo con datos de auth y users
  factory Profile.fromAuthAndUserData({
    required String id,
    required String email,
    required String name,
    String? avatarUrl,
    required DateTime createdAt,
  }) {
    return Profile(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
    );
  }
}
