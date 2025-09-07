// lib/models/transaction_data.dart

class ReceiptData {
  final bool isSuccess;
  final String transactionId;
  final DateTime timestamp;
  final String carrierName;
  final String phoneNumber;
  final double topupAmount;
  final double finalSavedCredit;

  ReceiptData({
    required this.isSuccess,
    required this.transactionId,
    required this.timestamp,
    required this.carrierName,
    required this.phoneNumber,
    required this.topupAmount,
    required this.finalSavedCredit,
  });
}
