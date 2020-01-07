import 'dart:io';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('Note', () {
    Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('__notes_test__');
    });

    tearDownAll(() async {
      tempDir.deleteSync(recursive: true);
    });

    test('Should respect modified key as modified', () async {
      var content = """---
title: Foo
modified: 2017-02-15T22:41:19+01:00
---

Hello""";

      var notePath = p.join(tempDir.path, "note.md");
      File(notePath).writeAsString(content);

      var parentFolder = NotesFolder(null, tempDir.path);
      var note = Note(parentFolder, notePath);
      await note.load();

      note.modified = DateTime.utc(2019, 12, 02, 4, 0, 0);

      await note.save();

      var expectedContent = """---
title: Foo
modified: 2019-12-02T04:00:00+00:00
---

Hello""";

      var actualContent = File(notePath).readAsStringSync();
      expect(actualContent, equals(expectedContent));
    });

    test('Should respect modified key as mod', () async {
      var content = """---
title: Foo
mod: 2017-02-15T22:41:19+01:00
---

Hello""";

      var notePath = p.join(tempDir.path, "note.md");
      File(notePath).writeAsString(content);

      var parentFolder = NotesFolder(null, tempDir.path);
      var note = Note(parentFolder, notePath);
      await note.load();

      note.modified = DateTime.utc(2019, 12, 02, 4, 0, 0);

      await note.save();

      var expectedContent = """---
title: Foo
mod: 2019-12-02T04:00:00+00:00
---

Hello""";

      var actualContent = File(notePath).readAsStringSync();
      expect(actualContent, equals(expectedContent));
    });
  });
}
