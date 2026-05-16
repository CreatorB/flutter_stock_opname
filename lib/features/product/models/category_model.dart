class CategoryModel {
  final String? id;
  final String? pcrCode;
  final String? pcrName;
  final String? description;
  final String? pcrGroup;

  CategoryModel({
    this.id,
    this.pcrCode,
    this.pcrName,
    this.description,
    this.pcrGroup,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString(),
      pcrCode: json['pcr_code'],
      pcrName: json['pcr_name'],
      description: json['description'],
      pcrGroup: json['pcr_group'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pcr_code': pcrCode,
      'pcr_name': pcrName,
      'description': description,
      'pcr_group': pcrGroup,
    };
  }
}
