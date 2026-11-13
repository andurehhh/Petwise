import 'package:flutter_test/flutter_test.dart';
import 'package:petwise/services/storage/storage_destination.dart';
import 'package:petwise/utils/app_config.dart';

void main() {
  group('StorageDestination Directory Structure Tests', () {
    test('Pet profile destination formats correctly for specific ID and environment', () {
      final destination = StorageDestination.petProfile(
        petId: '42',
        environment: 'staging',
      );
      expect(destination.folderPath, equals('petwise/staging/pets/42/profile'));
      expect(destination.toString(), equals('petwise/staging/pets/42/profile'));
    });

    test('Pet profile destination uses fallback when ID is null or blank', () {
      final destinationDefault = StorageDestination.petProfile(environment: 'staging');
      expect(destinationDefault.folderPath, equals('petwise/staging/pets/temp/profile'));

      final destinationBlank = StorageDestination.petProfile(
        petId: '   ',
        environment: 'staging',
      );
      expect(destinationBlank.folderPath, equals('petwise/staging/pets/general/profile'));
    });

    test('User avatar destination formats correctly for staging', () {
      final destination = StorageDestination.userAvatar(
        userId: 'usr_abc123',
        environment: 'staging',
      );
      expect(destination.folderPath, equals('petwise/staging/users/usr_abc123/avatar'));
    });

    test('Pen background destination formats correctly', () {
      final destination = StorageDestination.penBackground(
        userId: 'usr_abc123',
        environment: 'staging',
      );
      expect(destination.folderPath, equals('petwise/staging/users/usr_abc123/pen_backgrounds'));
    });

    test('Health record destination formats correctly', () {
      final destination = StorageDestination.healthRecord(
        petId: '77',
        environment: 'staging',
      );
      expect(destination.folderPath, equals('petwise/staging/health/77/records'));
    });

    test('Automatically resolves to AppConfig.currentEnvironment when omitted', () {
      final defaultDestination = StorageDestination.petProfile(petId: '10');
      final currentEnv = AppConfig.currentEnvironment;
      expect(
        defaultDestination.folderPath,
        equals('petwise/$currentEnv/pets/10/profile'),
      );
    });

    test('Respects custom dev environment override', () {
      final devDestination = StorageDestination.petProfile(
        petId: '42',
        environment: 'dev',
      );
      expect(devDestination.folderPath, equals('petwise/dev/pets/42/profile'));
    });
  });
}
