// lib/screens/amount_screen.dart

import 'package:flutter/material.dart';
import 'package:top_up_machine/models/transaction_data.dart';
import 'package:top_up_machine/screens/payment_screen.dart';
import 'package:top_up_machine/screens/receipt_screen.dart';
import 'package:top_up_machine/services/topup_service.dart';

class AmountScreen extends StatefulWidget {
  final String carrierName;
  final String phoneNumber;
  final TopupService topupService;

  const AmountScreen({
    super.key,
    required this.carrierName,
    required this.phoneNumber,
    required this.topupService,
  });

  @override
  State<AmountScreen> createState() => _AmountScreenState();
}

class _AmountScreenState extends State<AmountScreen> {
  double _savedCredit = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final isFirstTime = await widget.topupService.isFirstTransaction(
      widget.phoneNumber,
    );
    final credit = await widget.topupService.getSavedCredit(widget.phoneNumber);

    if (mounted) {
      setState(() {
        // ยอดเงินสะสมจะแสดงก็ต่อเมื่อไม่ใช่การเติมครั้งแรก
        _savedCredit = isFirstTime ? 0.0 : credit;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectAmount(double amount) async {
    final totalCredit = await widget.topupService.getSavedCredit(
      widget.phoneNumber,
    );

    if (totalCredit >= amount) {
      final remainingCredit = totalCredit - amount;
      await widget.topupService.updateSavedCredit(
        widget.phoneNumber,
        remainingCredit,
      );
      _processAndNavigate(amount, 0);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            carrierName: widget.carrierName,
            phoneNumber: widget.phoneNumber,
            selectedAmount: amount,
            topupService: widget.topupService,
          ),
        ),
      );
    }
  }

  Future<void> _processAndNavigate(double amount, double paidAmount) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("กำลังดำเนินการ..."),
              ],
            ),
          ),
        );
      },
    );

    final isSuccess = await widget.topupService.processTopup(
      widget.phoneNumber,
      amount,
    );
    Navigator.pop(context);

    if (isSuccess) {
      await widget.topupService.markFirstTransactionAsComplete(
        widget.phoneNumber,
      );
      final finalCredit = await widget.topupService.getSavedCredit(
        widget.phoneNumber,
      );

      final receipt = ReceiptData(
        isSuccess: true,
        transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        carrierName: widget.carrierName,
        phoneNumber: widget.phoneNumber,
        topupAmount: amount,
        finalSavedCredit: finalCredit,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(receipt: receipt),
        ),
        (Route<dynamic> route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final amounts = [10, 20, 30, 40, 50, 60, 70, 80, 100, 200, 300, 400, 500];

    return Scaffold(
      appBar: AppBar(title: const Text('ขั้นตอนที่ 3: เลือกจำนวนเงิน')),
      body: Center(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  children: [
                    Text(
                      widget.phoneNumber,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.carrierName,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    if (_savedCredit > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'เงินสะสม: $_savedCredit บาท',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.8,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: amounts.length,
                        itemBuilder: (context, index) {
                          final amount = amounts[index].toDouble();
                          final amountToPay = (amount - _savedCredit).clamp(
                            0,
                            double.infinity,
                          );

                          return ElevatedButton(
                            onPressed: () => _selectAmount(amount),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${amount.toInt()} บาท',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (amountToPay > 0 && _savedCredit > 0)
                                  Text(
                                    'จ่ายเพิ่ม ${amountToPay.toInt()} บ.',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                if (amountToPay == 0)
                                  const Text(
                                    '(ใช้เงินสะสม)',
                                    style: TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('ย้อนกลับ'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
