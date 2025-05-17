class User {
  String? userId;
  String? userName;
  String? userEmail;
  String? userPassword;
  String? userPhone;
  String? userAddress;

  User(
      {this.userId,
      this.userName,
      this.userEmail,
      this.userPassword,
      this.userPhone,
      this.userAddress});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['id'];
    userName = json['full_name'];
    userEmail = json['email'];
    userPassword = json['password'];
    userPhone = json['phone'];
    userAddress = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = userId;
    data['full_name'] = userName;
    data['email'] = userEmail;
    data['password'] = userPassword;
    data['phone'] = userPhone;
    data['address'] = userAddress;
    return data;
  }
}