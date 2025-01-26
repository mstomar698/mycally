import 'package:isar/isar.dart';

part 'vendor.g.dart';

enum VendorType {
  milk,
  grocery,
  vegetable,
  fruit,
  other,
}

@collection
class Vendor {
  Id id = Isar.autoIncrement;

  late String name;
  late String mobileNumber;

  @Enumerated(EnumType.name)
  late VendorType type;

  String? email;

  String? additionalInfoJson;
}
