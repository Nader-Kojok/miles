class Profile {
  final String id;
  final String? phone;
  final String? fullName;
  final String? email;
  final String? address;
  final DateTime? birthDate;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    this.phone,
    this.fullName,
    this.email,
    this.address,
    this.birthDate,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'full_name': fullName,
      'email': email,
      'address': address,
      'birth_date': birthDate?.toIso8601String().split('T')[0],
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? phone,
    String? fullName,
    String? email,
    String? address,
    DateTime? birthDate,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName => fullName ?? phone ?? 'Utilisateur';
}
