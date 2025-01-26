import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mycally/src/data/models/user.dart';
import 'package:mycally/src/data/models/vendor.dart';

late final Isar isar;

Future<void> initializeIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [UserSchema, VendorSchema],
    directory: dir.path,
  );
}
