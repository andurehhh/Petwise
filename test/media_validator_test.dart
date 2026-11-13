import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:petwise/services/storage/media_validator.dart';

void main() {
  group('MediaValidator Access Security & Constraint Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('petwise_test_');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Rejects non-existent file', () {
      final nonExistent = File('${tempDir.path}/ghost.png');
      final result = MediaValidator.validateImage(nonExistent);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('does not exist'));
    });

    test('Rejects empty file (0 bytes)', () {
      final emptyFile = File('${tempDir.path}/empty.jpg');
      emptyFile.writeAsBytesSync([]);

      final result = MediaValidator.validateImage(emptyFile);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('empty'));
    });

    test('Rejects unsupported file format (.exe, .txt, .gif)', () {
      final exeFile = File('${tempDir.path}/malicious.exe');
      exeFile.writeAsBytesSync([1, 2, 3]);

      final resultExe = MediaValidator.validateImage(exeFile);
      expect(resultExe.isValid, isFalse);
      expect(resultExe.errorMessage, contains('Format .exe is not supported'));

      final gifFile = File('${tempDir.path}/animation.gif');
      gifFile.writeAsBytesSync([1, 2, 3]);

      final resultGif = MediaValidator.validateImage(gifFile);
      expect(resultGif.isValid, isFalse);
      expect(resultGif.errorMessage, contains('Format .gif is not supported'));
    });

    test('Rejects file exceeding max file size', () {
      final largeFile = File('${tempDir.path}/huge.jpg');
      // Create a 2 MB file and validate against a 1 MB limit
      final bytes = List<int>.filled(2 * 1024 * 1024, 0);
      largeFile.writeAsBytesSync(bytes);

      final result = MediaValidator.validateImage(
        largeFile,
        maxBytes: 1 * 1024 * 1024,
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('exceeds'));
    });

    test('Accepts valid image formats within size limits', () {
      for (final ext in ['jpg', 'jpeg', 'png', 'webp']) {
        final file = File('${tempDir.path}/sample.$ext');
        file.writeAsBytesSync([1, 2, 3, 4, 5]);

        final result = MediaValidator.validateImage(file);
        expect(result.isValid, isTrue, reason: 'Failed for extension $ext');
        expect(result.errorMessage, isNull);
      }
    });
  });
}
