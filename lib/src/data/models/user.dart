import 'package:isar/isar.dart';
import 'package:mycally/src/data/models/vendor.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  late String name;
  String? mobileNumber;
  String? profileImage;
  String? email;

  final vendors = IsarLinks<Vendor>();

  int? dob;
  int? createdAt;
  int? updatedAt;
}
