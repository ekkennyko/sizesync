import 'package:flutter_test/flutter_test.dart';
import 'package:sizesync/data/models/conversion_result.dart';
import 'package:sizesync/data/models/size_entry.dart';

void main() {
  const sizeS = SizeEntry(label: 'S', order: 1, eu: ['36'], us: ['4']);
  const sizeM = SizeEntry(label: 'M', order: 2, eu: ['38', '40'], us: ['8', '10']);

  group('ConversionResult', () {
    test('confidence is 1.0 for eu match', () {
      final result = ConversionResult(fromSize: sizeS, toSize: sizeM, matchMethod: 'eu', confidence: 1.0);
      expect(result.confidence, 1.0);
      expect(result.matchMethod, 'eu');
    });

    test('confidence is 1.0 for us match', () {
      final result = ConversionResult(fromSize: sizeS, toSize: sizeM, matchMethod: 'us', confidence: 1.0);
      expect(result.confidence, 1.0);
    });

    test('confidence is 0.5 for nearest match', () {
      final result = ConversionResult(fromSize: sizeS, toSize: sizeM, matchMethod: 'nearest', confidence: 0.5);
      expect(result.confidence, lessThan(1.0));
      expect(result.confidence, 0.5);
    });

    test('fromSize and toSize are preserved', () {
      final result = ConversionResult(fromSize: sizeS, toSize: sizeM, matchMethod: 'eu', confidence: 1.0);
      expect(result.fromSize.label, 'S');
      expect(result.toSize.label, 'M');
    });
  });
}
