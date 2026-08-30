class Machine {
  final int? id;
  final String name;
  final String code;
  final String location;
  final double commissionPercent;
  final bool active;
  final DateTime? installedAt;

  const Machine({
    this.id,
    required this.name,
    required this.code,
    required this.location,
    this.commissionPercent = 0,
    this.active = true,
    this.installedAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'code': code,
        'location': location,
        'commission_percent': commissionPercent,
        'active': active ? 1 : 0,
        'installed_at': installedAt?.toIso8601String(),
      };

  factory Machine.fromMap(Map<String, Object?> map) => Machine(
        id: map['id'] as int?,
        name: map['name'] as String,
        code: map['code'] as String,
        location: map['location'] as String,
        commissionPercent: (map['commission_percent'] as num?)?.toDouble() ?? 0,
        active: (map['active'] as int? ?? 1) == 1,
        installedAt: map['installed_at'] == null
            ? null
            : DateTime.tryParse(map['installed_at'] as String),
      );
}
