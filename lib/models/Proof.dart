class Proofs {
  int? id;
  String? src;
  String? type;

  Proofs({this.id, this.src, this.type});

  Proofs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    src = json['src'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['src'] = src;
    data['type'] = type;
    return data;
  }
}