import 'navigation_models.dart';

class CourseClass {
  const CourseClass({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.building,
    required this.room,
    required this.weekdays,
    required this.startTime,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String courseCode;
  final String courseName;
  final String building;
  final String room;
  final List<int> weekdays;
  final String startTime;
  final double latitude;
  final double longitude;

  String get locationLabel => room.trim().isEmpty ? building : '$building $room';

  NavigationCoordinate get coordinate => NavigationCoordinate(
    latitude: latitude,
    longitude: longitude,
  );

  NaviDestination get destination => NaviDestination(
    name: locationLabel,
    address: '$courseCode · $courseName',
    coordinate: coordinate,
  );

  bool occursOn(int weekday) => weekdays.contains(weekday);

  factory CourseClass.fromJson(Map<String, dynamic> json) {
    return CourseClass(
      id: json['id'].toString(),
      courseCode: json['course_code']?.toString() ?? '',
      courseName: json['course_name']?.toString() ?? '',
      building: json['building']?.toString() ?? '',
      room: json['room']?.toString() ?? '',
      weekdays: (json['weekdays'] as List<dynamic>? ?? const [])
          .map((value) => (value as num).toInt())
          .toList(),
      startTime: json['start_time']?.toString().substring(0, 5) ?? '09:00',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 33.7838,
      longitude: (json['longitude'] as num?)?.toDouble() ?? -118.1141,
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
    required this.latitude,
    required this.longitude,
  });

  final String? id;
  final String courseCode;
  final String courseName;
  final String building;
  final String room;
  final List<int> weekdays;
  final String startTime;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson(String userId) => {
    'user_id': userId,
    'course_code': courseCode.trim(),
    'course_name': courseName.trim(),
    'building': building.trim(),
    'room': room.trim(),
    'weekdays': weekdays,
    'start_time': startTime,
    'latitude': latitude,
    'longitude': longitude,
  };
}

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

  String keyFor(DateTime date) =>
      '${course.id}|${_dateKey(date)}|$kind';
}

String dailyCompletionKey(String classId, DateTime date, String kind) =>
    '$classId|${_dateKey(date)}|$kind';

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
