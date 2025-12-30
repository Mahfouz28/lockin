class SavedNotification {
  final String title;
  final String body;
  final DateTime dateTime;

  SavedNotification({
    required this.title,
    required this.body,
    required this.dateTime,
  });

  factory SavedNotification.fromMap(Map<String, dynamic> map) {
    return SavedNotification(
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      dateTime: DateTime.parse(
        map['dateTime'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}
