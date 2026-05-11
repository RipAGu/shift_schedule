import 'package:hive_ce/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  Note({this.emoji, this.memo = ''});

  @HiveField(0)
  final String? emoji;

  @HiveField(1)
  final String memo;
}
