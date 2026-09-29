import 'package:flutter_test/flutter_test.dart';
import 'package:navipet/data/campus_place.dart';
import 'package:navipet/data/course_class.dart';
import 'package:navipet/data/navigation_models.dart';
import 'package:navipet/widgets/search_overlay.dart';

CourseClass _course(String id, String building) => CourseClass(
  id: id,
  courseCode: 'BUS $id',
  courseName: 'Course $id',
  building: building,
  room: '101',
  weekdays: const [1],
  startTime: '10:00',
  endTime: '11:15',
  latitude: 33.78,
  longitude: -118.11,
);

CampusPlace _recent(String title, {String? code}) => CampusPlace(
  id: 'place-$title',
  type: CampusDestinationType.building,
  title: title,
  subtitle: 'Building',
  source: 'recent',
  buildingCode: code,
  outdoorDestination: const NavigationCoordinate(
    latitude: 33.78,
    longitude: -118.11,
  ),
);

List<String> _titles(List<CampusPlace> places) =>
    places.map((place) => place.title).toList();

void main() {
  test('a class building is not repeated by the curated list', () {
    final places = SearchOverlay.popularPlaces(
      classes: [_course('1', 'College of Business')],
      recents: const [],
    );
    expect(
      _titles(places).where((title) => title == 'College of Business'),
      hasLength(1),
    );
  });

  test('a class building named by its code matches the curated entry', () {
    final places = SearchOverlay.popularPlaces(
      classes: [_course('1', 'COB')],
      recents: const [],
    );
    expect(_titles(places), isNot(contains('College of Business')));
  });

  test('popular locations skip places already in recent searches', () {
    final places = SearchOverlay.popularPlaces(
      classes: [_course('1', 'VEC')],
      recents: [
        _recent('Steve and Nini Horn Center', code: 'HC'),
        _recent('VEC'),
      ],
    );
    // Only class buildings are suggested, and VEC is already a recent search.
    expect(_titles(places), isEmpty);
  });
}
