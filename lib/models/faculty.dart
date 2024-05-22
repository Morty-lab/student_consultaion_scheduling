class Faculty {
  Faculty({required this.id, required this.name});
  final String id;
  final String name;

  factory Faculty.fromMap(Map<String, dynamic> data, id) {
    return Faculty(
      id: data['id'],
      name: data['name'],
    );
  }
}
