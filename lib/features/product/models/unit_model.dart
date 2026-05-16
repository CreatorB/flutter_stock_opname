class UnitModel {
  final String? id;
  final String? puCode;
  final String? description;

  UnitModel({
    this.id,
    this.puCode,
    this.description,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id']?.toString(),
      puCode: json['pu_code'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pu_code': puCode,
      'description': description,
    };
  }
}
