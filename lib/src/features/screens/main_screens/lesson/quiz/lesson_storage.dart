import 'package:hive/hive.dart';

class LessonStorageService {
  final String _boxName = 'lessonsBox';

  Future<void> saveLessons(List<Map<String, dynamic>> lessons) async {
    var box = await Hive.openBox(_boxName);
    await box.put('lessons', lessons);
  }

  Future<List<Map<String, dynamic>>?> getLessons() async {
    var box = await Hive.openBox(_boxName);
    return box.get('lessons')?.cast<Map<String, dynamic>>();
  }

  Future<void> clearLessons() async {
    var box = await Hive.openBox(_boxName);
    await box.delete('lessons');
  }
}
