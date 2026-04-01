import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/library_catalog_repository.dart';

void main() {
  test(
    'ensureProjectionBackfillStarted repairs legacy text timestamps in projection meta',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'aero_stream_library_catalog_test_',
      );
      final databaseFile = File(
        '${tempDir.path}${Platform.pathSeparator}library_catalog.sqlite',
      );

      final seededDatabase = AppDatabase(NativeDatabase(databaseFile));
      await seededDatabase.ensureLibraryProjectionMetaRow();
      await seededDatabase.customStatement(
        '''
        UPDATE library_projection_meta
        SET last_backfill_at = CURRENT_TIMESTAMP
        WHERE id = 1
        ''',
      );
      await seededDatabase.close();

      final reopenedDatabase = AppDatabase(NativeDatabase(databaseFile));
      addTearDown(() async {
        await reopenedDatabase.close();
        await tempDir.delete(recursive: true);
      });

      final repository = DatabaseLibraryCatalogRepository(reopenedDatabase);
      await repository.ensureProjectionBackfillStarted();

      final meta = await reopenedDatabase.getLibraryProjectionMeta();

      expect(meta, isNotNull);
      expect(meta!.backfillState, 'ready');
      expect(meta.lastBackfillAt, isNotNull);
    },
  );
}
