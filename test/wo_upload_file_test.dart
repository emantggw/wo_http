import 'package:flutter_test/flutter_test.dart';
import 'package:wo_http/src/models/wo_upload_file.dart';

void main() {
  group('WoUploadFile', () {
    test('infers image/png for .png', () {
      final file = WoUploadFile(filename: 'image.png');
      expect(file.contentType, 'image/png');
    });

    test('infers image/jpeg for .jpg and .jpeg', () {
      expect(WoUploadFile(filename: 'image.jpg').contentType, 'image/jpeg');
      expect(WoUploadFile(filename: 'image.jpeg').contentType, 'image/jpeg');
    });

    test('infers image/gif for .gif', () {
      final file = WoUploadFile(filename: 'image.gif');
      expect(file.contentType, 'image/gif');
    });

    test('infers image/webp for .webp', () {
      final file = WoUploadFile(filename: 'image.webp');
      expect(file.contentType, 'image/webp');
    });

    test('infers audio/mpeg for .mp3', () {
      final file = WoUploadFile(filename: 'audio.mp3');
      expect(file.contentType, 'audio/mpeg');
    });

    test('infers audio/wav for .wav', () {
      final file = WoUploadFile(filename: 'audio.wav');
      expect(file.contentType, 'audio/wav');
    });

    test('infers audio/mp4 for .m4a', () {
      final file = WoUploadFile(filename: 'audio.m4a');
      expect(file.contentType, 'audio/mp4');
    });

    test('infers audio/ogg for .ogg', () {
      final file = WoUploadFile(filename: 'audio.ogg');
      expect(file.contentType, 'audio/ogg');
    });

    test('returns null for unknown extensions', () {
      final file = WoUploadFile(filename: 'document.pdf');
      expect(file.contentType, isNull);
    });

    test('respects explicit contentType', () {
      final file = WoUploadFile(
        filename: 'image.png',
        contentType: 'custom/type',
      );
      expect(file.contentType, 'custom/type');
    });

    test('handles uppercase extensions', () {
      final file = WoUploadFile(filename: 'IMAGE.PNG');
      expect(file.contentType, 'image/png');
    });
  });
}
