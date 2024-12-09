import 'dart:ffi';

import 'package:rachacontas/models/User.dart';

class UserToDebt {
  int? id;
  String? relationship;
  String? phone;
  String? name;
  String? email;
  bool? smsSent;
  bool? emailSent;
  String? verifiedAt;
  double? value;
  User? user;
  double? paidValue;

  UserToDebt(
      {this.id,
        this.relationship,
        this.phone,
        this.name,
        this.email,
        this.smsSent,
        this.emailSent,
        this.verifiedAt,
        this.value,
        this.user,
        this.paidValue});

  UserToDebt.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    relationship = json['relationship'];
    phone = json['phone'];
    name = json['name'];
    email = json['email'];
    smsSent = json['sms_sent'];
    emailSent = json['email_sent'];
    verifiedAt = json['verified_at'];
    value = json['value']?.toDouble();
    paidValue = json['paid_value']?.toDouble();
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['relationship'] = relationship;
    data['phone'] = phone;
    data['name'] = name;
    data['email'] = email;
    data['sms_sent'] = smsSent;
    data['email_sent'] = emailSent;
    data['verified_at'] = verifiedAt;
    data['value'] = value;
    data['paid_value'] = paidValue;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class Relationship {
  static const String PAYER = 'payer';
  static const String RECEIVER = 'receiver';
  static const String WITNESS = 'witness';

  static const List<String> relationships = [PAYER, RECEIVER, WITNESS];

  static String getRelationship(String relationship) {
    switch (relationship) {
      case PAYER:
        return 'Pagador';
      case RECEIVER:
        return 'Recebedor';
      case WITNESS:
        return 'Testemunha';
      default:
        return 'Desconhecido';
    }
  }
}