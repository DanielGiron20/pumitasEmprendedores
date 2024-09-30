class Usuario {
  String id;
  String UID;
  String name;
  String email;
  String description;
  String instagram;
  String whatsapp;
  String logo;
  String sede;
  int eneable;

  Usuario({
    required this.id,
    required this.UID,
    required this.name,
    required this.email,
    required this.description,
    required this.instagram,
    required this.whatsapp,
    required this.logo,
    required this.sede,
    required this.eneable,
  });

  Usuario.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        UID = json['UID'] ?? "",
        name = json['name'] ?? "",
        email = json['email'] ?? "",
        description = json['description'] ?? "",
        instagram = json['instagram'] ?? "",
        whatsapp = json['whatsapp'] ?? "",
        logo = json['logo'] ?? "",
        sede = json['sede'] ?? "",
        eneable = json['eneable'] ?? 0;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['UID'] = UID;
    data['name'] = name;
    data['email'] = email;
    data['description'] = description;
    data['instagram'] = instagram;
    data['whatsapp'] = whatsapp;
    data['logo'] = logo;
    data['sede'] = sede;
    data['eneable'] = eneable;
    return data;
  }
}
