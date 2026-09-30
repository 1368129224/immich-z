import 'package:flutter_test/flutter_test.dart';
import 'package:immich_z/src/api/generated/models.dart';
import 'package:immich_z/src/repositories/asset_repository.dart';
import 'package:immich_z/src/repositories/search_repository.dart';

void main() {
  group('timeline bucket mapping', () {
    test('uses file creation date and preserves image/video flags', () {
      final bucket = TimeBucketAssetResponseDto(
        id: const ['image-id', 'video-id'],
        fileCreatedAt: const [
          '2025-03-04T12:00:00.000Z',
          '2025-03-03T12:00:00.000Z',
        ],
        isImage: const [true, false],
      );

      final assets = flattenBucket(bucket);

      expect(assets.map((asset) => asset.id), ['image-id', 'video-id']);
      expect(assets.map((asset) => asset.isImage), [true, false]);
      expect(assets.first.createdAt.toUtc(), DateTime.utc(2025, 3, 4, 12));
    });
  });

  group('metadata query filter', () {
    test('searches filenames, paths and descriptions with a contains pattern',
        () {
      expect(metadataQueryFilter(' trip ').toJson(), {
        'or': [
          {
            'originalFileName': {'like': '%trip%'}
          },
          {
            'originalPath': {'like': '%trip%'}
          },
          {
            'description': {'like': '%trip%'}
          },
        ],
      });
    });
  });

  group('search result ordering', () {
    test('sorts by local date, falling back to file and upload dates', () {
      const older = AssetResponseDto(
        id: 'older',
        localDateTime: '2024-01-01T00:00:00.000Z',
      );
      const newer = AssetResponseDto(
        id: 'newer',
        localDateTime: '2025-01-01T00:00:00.000Z',
      );
      const fallback = AssetResponseDto(
        id: 'fallback',
        fileCreatedAt: '2024-06-01T00:00:00.000Z',
      );

      final assets = sortAssetsNewestFirst([older, newer, fallback]);

      expect(assets.map((asset) => asset.id), ['newer', 'fallback', 'older']);
    });
  });
}
