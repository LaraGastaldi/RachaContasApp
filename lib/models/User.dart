class User {
  int? id;
  String? firstName;
  String? lastName;
  String? emailAddress;
  String? phone;
  String? emailVerifiedAt;
  String? phoneVerifiedAt;

  User(
      {this.id,
        this.firstName,
        this.lastName,
        this.emailAddress,
        this.phone,
        this.emailVerifiedAt,
        this.phoneVerifiedAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    emailAddress = json['email_address'];
    phone = json['phone'];
    emailVerifiedAt = json['email_verified_at'];
    phoneVerifiedAt = json['phone_verified_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email_address'] = emailAddress;
    data['phone'] = phone;
    data['email_verified_at'] = emailVerifiedAt;
    data['phone_verified_at'] = phoneVerifiedAt;
    return data;
  }
}