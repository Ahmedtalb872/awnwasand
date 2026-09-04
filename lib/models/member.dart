/// عضو أو منتسب في الجمعية.
class AssociationMember {
  const AssociationMember({
    required this.name,
    required this.role,
    this.isAffiliate = false,
  });

  factory AssociationMember.fromMap(Map<String, dynamic> map) {
    return AssociationMember(
      name: map['name'] as String,
      role: map['role'] as String,
      isAffiliate: map['is_affiliate'] as bool? ?? false,
    );
  }

  final String name;
  final String role;
  final bool isAffiliate;
}
