class User {
  int id;
  String nik;
  String nama;
  String email;
  String? telepon;
  String? alamat;
  String role;
  String? fotoProfil;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    required this.id,
    required this.nik,
    required this.nama,
    required this.email,
    this.telepon,
    this.alamat,
    required this.role,
    this.fotoProfil,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] as int,
        nik: json["nik"]?.toString() ?? '',
        nama: json["nama"]?.toString() ?? '',
        email: json["email"]?.toString() ?? '',
        telepon: json["telepon"]?.toString(),
        alamat: json["alamat"]?.toString(),
        role: json["role"]?.toString() ?? 'warga',
        fotoProfil: json["foto_profil"]?.toString(),
        isActive: json["is_active"] ?? true,
        createdAt: json["created_at"] != null 
            ? DateTime.parse(json["created_at"].toString())
            : DateTime.now(),
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"].toString())
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nik": nik,
        "nama": nama,
        "email": email,
        "telepon": telepon,
        "alamat": alamat,
        "role": role,
        "foto_profil": fotoProfil,
        "is_active": isActive,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };

  String get initial => nama.isNotEmpty ? nama[0].toUpperCase() : 'U';
}

class LoginResponse {
  User user;
  String token;

  LoginResponse({
    required this.user,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        user: User.fromJson(json["user"] as Map<String, dynamic>),
        token: json["token"]?.toString() ?? '',
      );
}