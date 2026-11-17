import 'earning.dart';

abstract class EarningsApi {
  Future<List<Earning>> fetchEarnings(String userId);
  Stream<Earning> walletUpdates(String userId);
  Future<Object> fetchDetail(String id);
}

class DemoEarningsApi implements EarningsApi {
  DemoEarningsApi({this.itemCount = 2000});

  final int itemCount;

  @override
  Future<List<Earning>> fetchEarnings(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return List<Earning>.generate(itemCount, (i) {
      final amount = (i + 1) * 10.0;
      return Earning(
        id: 'e$i',
        amount: amount,
        formattedAmount: formatCurrency(amount),
      );
    });
  }

  @override
  Stream<Earning> walletUpdates(String userId) {
    return Stream<Earning>.periodic(const Duration(seconds: 12), (n) {
      final amount = 500.0 + n;
      return Earning(
        id: 'live_$n',
        amount: amount,
        formattedAmount: formatCurrency(amount),
      );
    });
  }

  @override
  Future<Object> fetchDetail(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return 'Details for earning $id';
  }
}
