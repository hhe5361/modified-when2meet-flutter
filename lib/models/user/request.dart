class RegisterLoginRequest {
  final String name;
  final String password;
  final String timeRegion;

  RegisterLoginRequest({
    required this.name,
    required this.password,
    required this.timeRegion,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'password': password,
      'time_region': timeRegion,
    };
  }
}
