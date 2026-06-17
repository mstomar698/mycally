import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mycally/src/data/models/expense.dart';
import 'package:mycally/src/data/models/user.dart';
import 'package:mycally/src/data/models/vendor.dart';

late final Isar isar;

Future<void> initializeIsar({String? directory}) async {
  final dir = directory ?? (await getApplicationDocumentsDirectory()).path;
  isar = await Isar.open(
    [UserSchema, VendorSchema, ExpenseSchema],
    directory: dir,
  );
}

Future<void> closeIsar() async {
  await isar.close();
}
