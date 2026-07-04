class User {
  final String id;
  final String username;
  final String password;
  final String fullName;
  final String? phone;
  final String position;
  final double salaryBasic;
  final double allowance;
  final String joinDate;
  final bool isActive;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.fullName,
    this.phone,
    required this.position,
    required this.salaryBasic,
    required this.allowance,
    required this.joinDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'username': username, 'password': password, 'full_name': fullName,
    'phone': phone, 'position': position, 'salary_basic': salaryBasic,
    'allowance': allowance, 'join_date': joinDate, 'is_active': isActive ? 1 : 0,
  };

  static User fromMap(Map<String, dynamic> map) => User(
    id: map['id'], username: map['username'], password: map['password'],
    fullName: map['full_name'], phone: map['phone'], position: map['position'],
    salaryBasic: map['salary_basic'], allowance: map['allowance'],
    joinDate: map['join_date'], isActive: map['is_active'] == 1,
  );
}