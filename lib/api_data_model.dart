class ApiDataModel {
  const ApiDataModel({
    required this.id,
    required this.title,
    required this.company,
    required this.payout,
  });

  final String id;
  final String title;
  final String company;
  final int payout;
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => 'ApiException: $message';
}
