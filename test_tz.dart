import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  await initializeDateFormatting('id_ID', null);
  final dt = DateTime.parse("2026-05-24T17:00:00.000000Z");
  print(dt.toString());
  print(dt.toLocal().toString());
  print(DateFormat('EEEE, dd MMM', 'id_ID').format(dt));
  print(DateFormat('EEEE, dd MMM', 'id_ID').format(dt.toLocal()));
}
