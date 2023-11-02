import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;

import '../constants.dart';

Future<void> cleanOldCacheFiles() async {
  final Directory cacheDirectory = await getApplicationCacheDirectory();

  await for (var file in cacheDirectory.list()) {
    final stat = await file.stat();
    final modified = stat.modified;
    final now = DateTime.now();
    final duration = now.difference(modified);

    if (duration.inDays >= maxFileCacheAgeInDays) {
      developer.log("Removing stale cache file '${file.path}'");
      await file.delete();
    }
  }
}
