import 'package:powersync/powersync.dart';

/// Tables in the phone's local database. They must match the columns that the
/// PowerSync sync streams send down (`powersync/sync-rules.yaml`).
/// Every table gets a text `id` column automatically.
const schema = Schema([
  // TEMPORARY: connection test only (setup guide, Step 9).
  Table('connection_checks', [
    Column.text('user_id'),
    Column.text('note'),
    Column.text('created_at'),
  ]),
]);
