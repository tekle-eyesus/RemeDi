class UserEntity {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime? dateOfBirth;
  final String? bio;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    this.dateOfBirth,
    this.bio,
    this.createdAt,
    this.updatedAt,
  });

  static const empty = UserEntity(id: '', email: '');

  bool get isEmpty => this == UserEntity.empty;
  bool get isNotEmpty => this != UserEntity.empty;

  static const _unset = Object();

  UserEntity copyWith({
    String? id,
    String? email,
    Object? displayName = _unset,
    Object? phoneNumber = _unset,
    Object? photoUrl = _unset,
    Object? dateOfBirth = _unset,
    Object? bio = _unset,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: identical(displayName, _unset)
          ? this.displayName
          : displayName as String?,
      phoneNumber: identical(phoneNumber, _unset)
          ? this.phoneNumber
          : phoneNumber as String?,
      photoUrl:
          identical(photoUrl, _unset) ? this.photoUrl : photoUrl as String?,
      dateOfBirth: identical(dateOfBirth, _unset)
          ? this.dateOfBirth
          : dateOfBirth as DateTime?,
      bio: identical(bio, _unset) ? this.bio : bio as String?,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _unset)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
