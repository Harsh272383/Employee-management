class DateFormat {
  static final DateFormat _instance = DateFormat._internal();

  factory DateFormat() {
    return _instance;
  }

  DateFormat._internal();

  String format(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime parse(String dateString) {
    List<String> parts = dateString.split('-');
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int day = int.parse(parts[2]);
    return DateTime.utc(year, month, day);
  }
}