import 'package:intl/intl.dart';

String toDateString(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

DateTime fromDateString(String value) => DateFormat('yyyy-MM-dd').parse(value);

bool isSameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;
