import 'package:intl/intl.dart';

DateTime parsePublicationDateToDateTime(String publicationDate) {
  final format = DateFormat("EEE, dd MMM y H:m:s 'GMT'");
  final dateTime = format.parse(publicationDate, true);

  return dateTime;
}

/// Converts the publicationDate from a format such as "Sat, 28 Oct 2023 12:35:08 GMT" to
/// a duration relative to now, e.g. "2 days 11 hours ago".
String dateTimeToDurationFromNow(DateTime dateTimeUtc) {
  final now = DateTime.now().toUtc();

  Duration duration = now.difference(dateTimeUtc);

  final parts = <String>[];

  final days = duration.inDays;
  if (days > 0) {
    parts.add("$days days");
    duration -= Duration(days: days);
  }
  final hours = duration.inHours;
  if (hours > 0) {
    parts.add("$hours hours");
    duration -= Duration(hours: hours);
  }
  final minutes = duration.inMinutes;
  if (minutes > 0) {
    parts.add("$minutes minutes");
    duration -= Duration(minutes: minutes);
  }

  parts.add("ago");

  final text = parts.join(" ");

  return text;
}
