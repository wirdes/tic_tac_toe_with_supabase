class Profile {
  final String username;

  Profile({required this.username});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(username: json['username']);
  }

  Map<String, dynamic> toJson() => {'username': username};
}
