/// عضو أو منتسب في الجمعية.
class AssociationMember {
  const AssociationMember({
    required this.name,
    required this.role,
    this.isAffiliate = false,
  });

  final String name;
  final String role;
  final bool isAffiliate;
}
