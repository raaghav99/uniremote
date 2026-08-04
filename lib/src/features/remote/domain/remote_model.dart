import 'package:hive/hive.dart';

part 'remote_model.g.dart';

@HiveType(typeId: 0)
class RemoteModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String deviceType; // 'tv' | 'ac' | 'fan' | 'dth'

  @HiveField(3)
  late String brandName;

  @HiveField(4)
  late String iconEmoji;

  @HiveField(5)
  late List<IrButton> buttons;

  RemoteModel({
    required this.id,
    required this.name,
    required this.deviceType,
    required this.brandName,
    required this.iconEmoji,
    required this.buttons,
  });
}

@HiveType(typeId: 1)
class IrButton extends HiveObject {
  @HiveField(0)
  late String label;

  @HiveField(1)
  late String icon; // icon name string (mapped to IconData in UI)

  @HiveField(2)
  late int freqHz;

  @HiveField(3)
  late List<int> pattern;

  IrButton({
    required this.label,
    required this.icon,
    required this.freqHz,
    required this.pattern,
  });
}
