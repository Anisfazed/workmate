class User {
  final String userId;
  final String userName;
  final String userEmail;
  final String userPassword;
  final String userPhone;
  final String userAddress;
  final String userImage;

  User({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPassword,
    required this.userPhone,
    required this.userAddress,
    required this.userImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id']?.toString() ?? '',
      userName: json['name'] ?? '',
      userEmail: json['email'] ?? '',
      userPassword: json['password'] ?? '',
      userPhone: json['phone'] ?? '',
      userAddress: json['address'] ?? '',
      userImage: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': userName,
      'email': userEmail,
      'password': userPassword,
      'phone': userPhone,
      'address': userAddress,
      'image': userImage,
    };
  }
}
