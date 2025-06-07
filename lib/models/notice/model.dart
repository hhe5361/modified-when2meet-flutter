class Notice {
  final int id;
  final String userName;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Notice({
    required this.id,
    required this.userName,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  //josn -> room 
  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'],
      userName: json['user_name'],
      content: json['content'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

