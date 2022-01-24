import 'package:hive/hive.dart';

part 'model.g.dart';

@HiveType(typeId: 0)
class Settings extends HiveObject {
  @HiveField(0)
  late bool darkMode = false;

  @HiveField(1)
  late bool metricSystem = true;

  @HiveField(2)
  late bool appBarImages = true;

  @HiveField(3)
  late bool reduceAnimations = false;

  @HiveField(4)
  late bool marqueMusicTitle = true;

  @HiveField(5)
  late bool hideNavBarOnScroll = false;

  @HiveField(6)
  late bool fullscreenModeOnScroll = false;

  @HiveField(7)
  late bool floatingNavBar = true;
}
