// User class
class User {
  String username;
  String firstName;
  String lastName;
  int date;
  int updated;

  User({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.date,
    required this.updated,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      date: json['date'] as int,
      updated: json['updated'] as int,
    );
  }

  @override
  String toString() {
    return 'User{username: $username, firstName: $firstName, lastName: $lastName, date: $date, updated: $updated}';
  }
}

// Post class
class Post {
  final String id;
  String text;
  final String username;
  bool public;
  int date;
  int updated;

  Post({
    required this.id,
    required this.text,
    required this.username,
    required this.public,
    required this.date,
    required this.updated,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      text: json['text'] as String,
      username: json['username'] as String,
      public: json['public'] as bool,
      date: json['date'] as int,
      updated: json['updated'] as int,
    );
  }

  @override
  String toString() {
    return 'Post{id: $id, text: $text, public: $public, date: $date, updated: $updated}';
  }
}
