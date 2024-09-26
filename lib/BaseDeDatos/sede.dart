class Sede {
  String? id;
  String cede;

  Sede({
    this.id,
    required this.cede,
  });

  Sede.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        cede = json['cede'] ?? "";

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cede'] = cede;
    return data;
  }
}
