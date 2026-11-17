class Earning {
  const Earning({
    required this.id,
    required this.amount,
    required this.formattedAmount,
  });

  final String id;
  final double amount;
  final String formattedAmount;
}

String formatCurrency(double amount) => '₹${amount.toStringAsFixed(0)}';
