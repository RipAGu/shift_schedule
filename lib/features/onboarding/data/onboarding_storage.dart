import 'package:hive_ce_flutter/hive_flutter.dart';

class OnboardingStorage {
  OnboardingStorage(this._box);

  final Box<dynamic> _box;

  static const _completedKey = 'onboarding_done_v1';

  static Future<OnboardingStorage> open() async {
    await Hive.initFlutter();
    final box = await Hive.openBox('app_settings');
    return OnboardingStorage(box);
  }

  bool isCompleted() => _box.get(_completedKey) == true;

  Future<void> setCompleted() => _box.put(_completedKey, true);
}
