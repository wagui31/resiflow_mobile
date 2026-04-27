class ResidenceAdminSettings {
  const ResidenceAdminSettings({
    required this.id,
    required this.name,
    required this.address,
    required this.code,
    required this.montantMensuel,
    required this.currency,
    required this.maxOccupantsParLogement,
  });

  factory ResidenceAdminSettings.fromJson(Map<String, dynamic> json) {
    return ResidenceAdminSettings(
      id: json['id'] as int? ?? 0,
      name: (json['name'] as String?)?.trim() ?? '',
      address: (json['address'] as String?)?.trim() ?? '',
      code: (json['code'] as String?)?.trim() ?? '',
      montantMensuel: _parseAmount(json['montantMensuel']),
      currency: (json['currency'] as String?)?.trim(),
      maxOccupantsParLogement: json['maxOccupantsParLogement'] as int? ?? 1,
    );
  }

  final int id;
  final String name;
  final String address;
  final String code;
  final double montantMensuel;
  final String? currency;
  final int maxOccupantsParLogement;
}

class UpdateResidenceAdminSettingsPayload {
  const UpdateResidenceAdminSettingsPayload({
    required this.name,
    required this.address,
    required this.code,
    required this.montantMensuel,
    required this.maxOccupantsParLogement,
  });

  final String name;
  final String address;
  final String code;
  final double montantMensuel;
  final int maxOccupantsParLogement;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name.trim(),
      'address': address.trim(),
      'code': code.trim(),
      'montantMensuel': montantMensuel,
      'maxOccupantsParLogement': maxOccupantsParLogement,
    };
  }
}

double _parseAmount(Object? rawValue) {
  if (rawValue is num) {
    return rawValue.toDouble();
  }
  if (rawValue is String) {
    return double.tryParse(rawValue.trim()) ?? 0;
  }
  return 0;
}
