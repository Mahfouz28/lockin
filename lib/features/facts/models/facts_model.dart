class FactsModel {
  final String id;
  final String name;

  FactsModel({required this.id, required this.name});

  factory FactsModel.fromJson(Map<String, dynamic> json) {
    return FactsModel(id: json['id'] as String, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
