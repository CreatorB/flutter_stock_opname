class RackModel {
  final String raId;
  final String raName;

  RackModel({
    required this.raId,
    required this.raName,
  });

  factory RackModel.fromJson(Map<String, dynamic> json) {
    return RackModel(
      raId: json['ra_id'] ?? '',
      raName: json['ra_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ra_id': raId,
      'ra_name': raName,
    };
  }
}