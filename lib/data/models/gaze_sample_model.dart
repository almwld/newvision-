class GazeSampleModel {
  const GazeSampleModel({
    required this.xPx,
    required this.yPx,
    required this.confidence,
    required this.isBlinking,
    required this.timestampNs,
  });

  final double xPx;
  final double yPx;
  final double confidence;
  final bool isBlinking;
  final int timestampNs;

  factory GazeSampleModel.fromMap(Map<String, dynamic> map) {
    return GazeSampleModel(
      xPx: (map['xPx'] as num).toDouble(),
      yPx: (map['yPx'] as num).toDouble(),
      confidence: (map['confidence'] as num).toDouble(),
      isBlinking: map['isBlinking'] == true,
      timestampNs: (map['timestampNs'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'xPx': xPx,
        'yPx': yPx,
        'confidence': confidence,
        'isBlinking': isBlinking,
        'timestampNs': timestampNs,
      };
}
