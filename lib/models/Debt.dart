import 'dart:ffi';

import 'package:rachacontas/models/Proof.dart';
import 'package:rachacontas/models/UserToDebt.dart';
import 'package:intl/intl.dart';

class Debt {
  int? id;
  String? name;
  String? description;
  double? totalValue;
  String? debtDate;
  String? maxPayDate;
  List<UserToDebt>? userToDebt;
  List<Proofs>? proofs;

  Debt(
      {this.id,
      this.name,
      this.description,
      this.totalValue,
      this.debtDate,
      this.maxPayDate,
      this.userToDebt,
      this.proofs});

  Debt.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    totalValue = json['total_value']?.toDouble();
    debtDate = json['debt_date'];
    maxPayDate = json['max_pay_date'];
    if (json['users'] != null) {
      userToDebt = <UserToDebt>[];
      json['users'].forEach((v) {
        userToDebt!.add(UserToDebt.fromJson(v));
      });
    }
    if (json['proofs'] != null) {
      proofs = <Proofs>[];
      json['proofs'].forEach((v) {
        proofs!.add(Proofs.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['total_value'] = totalValue;
    data['debt_date'] = debtDate;
    data['max_pay_date'] = maxPayDate;
    if (userToDebt != null) {
      data['users'] = userToDebt!.map((v) => v.toJson()).toList();
    }
    if (proofs != null) {
      data['proofs'] = proofs!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  getPendingValue() {
    double pendingValue = totalValue!;
    for (var element in (userToDebt ?? [])) {
      pendingValue -= (element.paidValue ?? 0);
    }
    return pendingValue;
  }
  isVerified() {
    if (userToDebt == null) {
      return true;
    }
    return userToDebt!.every((element) => element.verifiedAt != null || element.relationship != Relationship.PAYER);
  }
  getPaidValue() {
    double paidValue = 0;
    for (var element in (userToDebt ?? [])) {
      paidValue += (element.paidValue ?? 0);
    }
    return paidValue;
  }
}

final oCcy = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');