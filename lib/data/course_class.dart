import 'navigation_models.dart';

/// Formats a database time (`HH:MM` or `HH:MM:SS`) as `10:00 AM`; with
/// [period] false, just `10:00`.
String formatClockTime(String value, {bool period = true}) {
  final parts = value.split(':');
  final hour = int.tryParse(parts.first) ?? 0;
  final minute = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
  final display = hour % 12 == 0 ? 12 : hour % 12;
  final label = '$display:$minute';
  return period ? '$label ${_period(hour)}' : label;
}

String _period(int hour) => hour % 24 < 12 ? 'AM' : 'PM';

class CourseClass {
  const CourseClass({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.building,
    required this.room,
    required this.weekdays,
    required this.startTime,
    required this.endTime,
    required this.latitude,
    required this.longitude,
    this.isOnline = false,
  });

  final String id;
  final String courseCode;
  final String courseName;
  final String building;
  final String room;
  final List<int> weekdays;
  final String startTime;
  final String endTime;
  final double latitude;
  final double longitude;
  final bool isOnline;

  String get locationLabel => isOnline
      ? 'Online class'
      : room.trim().isEmpty
      ? building
      : '$building $room';

  /// Start time for display, e.g. `10:00 AM`.
  String get startLabel => formatClockTime(startTime);

  /// `10:00–11:15 AM`, or `11:30 AM–12:45 PM` when the class crosses noon.
  String get timeRangeLabel {
    final samePeriod =
        _period(int.tryParse(startTime.split(':').first) ?? 0) ==
        _period(int.tryParse(endTime.split(':').first) ?? 0);
    return samePeriod
        ? '${formatClockTime(startTime, period: false)}–${formatClockTime(endTime)}'
        : '${formatClockTime(startTime)}–${formatClockTime(endTime)}';
  }

  NavigationCoordinate get coordinate =>
      NavigationCoordinate(latitude: latitude, longitude: longitude);

  NaviDestination get destination => NaviDestination(
    name: locationLabel,
    address: '$courseCode · $courseName',
    coordinate: coordinate,
  );

  bool occursOn(int weekday) => weekdays.contains(weekday);

  factory CourseClass.fromJson(Map<String, dynamic> json) {
    final startTime =
        (json['startTime'] ?? json['start_time'])?.toString() ?? '09:00';
    final endTime =
        (json['endTime'] ?? json['end_time'])?.toString() ??
        _addHour(startTime);
    final weekdays = json['weekdays'] as List<dynamic>? ?? const [];
    return CourseClass(
      id: json['id'].toString(),
      courseCode: (json['courseCode'] ?? json['course_code'])?.toString() ?? '',
      courseName: (json['courseName'] ?? json['course_name'])?.toString() ?? '',
      building: json['building']?.toString() ?? '',
      room: json['room']?.toString() ?? '',
      weekdays: weekdays
          .whereType<num>()
          .map((value) => value.toInt())
          .toList(),
      startTime: startTime.length >= 5 ? startTime.substring(0, 5) : '09:00',
      endTime: endTime.length >= 5
          ? endTime.substring(0, 5)
          : _addHour(startTime),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 33.7838,
      longitude: (json['longitude'] as num?)?.toDouble() ?? -118.1141,
      isOnline: _asBool(json['isOnline'] ?? json['is_online']),
    );
  }
}

class CourseClassInput {
  const CourseClassInput({
    this.id,
    required this.courseCode,
    required this.courseName,
    required this.building,
    required this.room,
    required this.weekdays,
    required this.startTime,
    required this.endTime,
    required this.latitude,
    required this.longitude,
    this.isOnline = false,
  });

  final String? id;
  final String courseCode;
  final String courseName;
  final String building;
  final String room;
  final List<int> weekdays;
  final String startTime;
  final String endTime;
  final double latitude;
  final double longitude;
  final bool isOnline;

  Map<String, dynamic> toJson(String userId) => {
    'user_id': userId,
    'course_code': courseCode.trim(),
    'course_name': courseName.trim(),
    'building': building.trim(),
    'room': room.trim(),
    'weekdays': weekdays,
    'start_time': startTime,
    'end_time': endTime,
    'latitude': latitude,
    'longitude': longitude,
    'is_online': isOnline,
  };

  Map<String, dynamic> toApiJson() => {
    'courseCode': courseCode.trim(),
    'courseName': courseName.trim(),
    'building': building.trim(),
    'room': room.trim(),
    'weekdays': weekdays,
    'startTime': startTime,
    'endTime': endTime,
    'latitude': latitude,
    'longitude': longitude,
    'isOnline': isOnline,
  };
}

String _addHour(String value) {
  final parts = value.split(':');
  final hour = int.tryParse(parts.first) ?? 9;
  final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  final totalMinutes = (hour * 60 + minute + 60) % (24 * 60);
  final endHour = (totalMinutes ~/ 60).toString().padLeft(2, '0');
  final endMinute = (totalMinutes % 60).toString().padLeft(2, '0');
  return '$endHour:$endMinute';
}

bool _asBool(Object? value) =>
    value == true || value?.toString().toLowerCase() == 'true';

class DailyClassTask {
  const DailyClassTask({
    required this.course,
    required this.kind,
    required this.label,
    required this.reward,
    required this.done,
  });

  final CourseClass course;
  final String kind;
  final String label;
  final int reward;
  final bool done;

  String keyFor(DateTime date) => '${course.id}|${_dateKey(date)}|$kind';
}

String dailyCompletionKey(String classId, DateTime date, String kind) =>
    '$classId|${_dateKey(date)}|$kind';

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
