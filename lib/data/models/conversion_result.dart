import 'package:sizesync/data/models/size_entry.dart';

class ConversionResult {
  const ConversionResult({required this.fromSize, required this.toSize, required this.matchMethod, required this.confidence});

  final SizeEntry fromSize;
  final SizeEntry toSize;
  final String matchMethod;
  final double confidence;
}
