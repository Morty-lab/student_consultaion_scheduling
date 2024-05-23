class Faculty {
  Faculty({required this.id, required this.name, required this.email});
  final String id;
  final String name;
  final String email;

  factory Faculty.fromMap(Map<String, dynamic> data, id) {
    return Faculty(
      id: data['id'],
      name: data['name'],
      email: data['email'],
    );
  }
}
