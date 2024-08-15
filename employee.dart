class Employee {
  final String name;
  final String position;
  final String mobile;
  final DateTime dateOfBirth;

  Employee({
    required this.name,
    required this.position,
    required this.mobile,
    required this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'mobile': mobile,
      'dateOfBirth': dateOfBirth.toIso8601String(),
    };
  }

  static Employee fromJson(Map<String, dynamic> json) {
    return Employee(
      name: json['name'],
      position: json['position'],
      mobile: json['mobile'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
    );
  }
}