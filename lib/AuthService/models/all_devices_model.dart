import 'package:hive/hive.dart';
part 'all_devices_model.g.dart';

@HiveType(typeId: 0)
class Appliance extends HiveObject {
  @HiveField(0)
  String applianceId;

  @HiveField(1)
  String applianceName;

  @HiveField(2)
  double wattage;

  @HiveField(3)
  double usagePatternPerDay;

  @HiveField(4)
  List<int> selectedDays;

  @HiveField(5)
  double monthlyCost;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? updatedAt;

  @HiveField(8)
  DateTime? deletedAt;
  @HiveField(9)

  String? userId;

  Appliance({
    required this.applianceId,
    required this.applianceName,
    required this.wattage,
    required this.usagePatternPerDay,
    required this.selectedDays,
    this.monthlyCost = 0,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.userId,
  });
}
