class Usuario {
  String id;
  String name;
  String email;
  String description;
  String instagram;
  String whatsapp;
  String logo;
  String sede;

  Usuario({
    required this.id,
    required this.name,
    required this.email,
    required this.description,
    required this.instagram,
    required this.whatsapp,
    required this.logo,
    required this.sede,
  });

  Usuario.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        name = json['name'] ?? "",
        email = json['email'] ?? "",
        description = json['description'] ?? "",
        instagram = json['instagram'] ?? "",
        whatsapp = json['whatsapp'] ?? "",
        logo = json['logo'] ?? "",
        sede = json['sede'] ?? "";

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['description'] = description;
    data['instagram'] = instagram;
    data['whatsapp'] = whatsapp;
    data['logo'] = logo;
    data['sede'] = sede;
    return data;
  }
}
