// lib/screens/payment_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:top_up_machine/models/transaction_data.dart';
import 'package:top_up_machine/screens/receipt_screen.dart';
import 'package:top_up_machine/services/topup_service.dart';
import 'package:top_up_machine/widgets/info_dialog.dart';

class PaymentScreen extends StatefulWidget {
  final String carrierName;
  final String phoneNumber;
  final double selectedAmount;
  final TopupService topupService;

  const PaymentScreen({
    super.key,
    required this.carrierName,
    required this.phoneNumber,
    required this.selectedAmount,
    required this.topupService,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  double _amountToPay = 0.0;
  double _insertedMoney = 0.0;
  bool _isLoading = true;

  late Timer _timer;
  int _timeRemaining = 60;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    final isFirstTime = await widget.topupService.isFirstTransaction(
      widget.phoneNumber,
    );
    final savedCredit = isFirstTime
        ? 0.0
        : await widget.topupService.getSavedCredit(widget.phoneNumber);

    if (mounted) {
      setState(() {
        _amountToPay = widget.selectedAmount - savedCredit;
        _isLoading = false;
      });
      startTimer();
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        _timer.cancel();
        if (mounted) handleTimeout();
      }
    });
  }

  Future<void> handleTimeout() async {
    if (_insertedMoney > 0) {
      final currentCredit = await widget.topupService.getSavedCredit(
        widget.phoneNumber,
      );
      await widget.topupService.updateSavedCredit(
        widget.phoneNumber,
        currentCredit + _insertedMoney,
      );
    }

    showInfoDialog(
      context: context,
      title: 'หมดเวลา',
      message:
          'หมดเวลาในการชำระเงิน! เงินที่ท่านใส่จำนวน ${_insertedMoney.toInt()} บาท ได้ถูกเก็บเป็นยอดสะสมเรียบร้อยแล้ว',
      icon: Icons.timer_off,
      iconColor: Colors.orange,
    ).then((_) {
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  Future<void> insertMoney(double value) async {
    setState(() {
      _insertedMoney += value;
    });

    if (_insertedMoney >= _amountToPay) {
      _timer.cancel();
      final excess = _insertedMoney - _amountToPay;
      final currentCredit = await widget.topupService.getSavedCredit(
        widget.phoneNumber,
      );
      await widget.topupService.updateSavedCredit(
        widget.phoneNumber,
        currentCredit + excess,
      );
      _processAndNavigate();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coins = [1, 2, 5, 10];
    final banknotes = [20, 50, 100];
    final remainingToPay = (_amountToPay - _insertedMoney).clamp(
      0,
      double.infinity,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('ขั้นตอนที่ 4: ชำระเงิน'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // การ์ดแสดงสถานะการชำระเงิน
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'เวลาที่เหลือ: $_timeRemaining วินาที',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: _timeRemaining > 10
                                      ? Colors.grey.shade600
                                      : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // แถบแสดงเวลา
                              LinearProgressIndicator(
                                value: _timeRemaining / 60.0,
                                backgroundColor: Colors.grey.shade300,
                                color: _timeRemaining > 10
                                    ? theme.primaryColor
                                    : Colors.red,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'คงเหลือที่ต้องชำระ',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                '${remainingToPay.toInt()} บาท',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.displayMedium?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ยอดที่ต้องชำระ:',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  Text(
                                    '${_amountToPay.toInt()} บาท',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ใส่เงินแล้ว:',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  Text(
                                    '${_insertedMoney.toInt()} บาท',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),

                      // ส่วนปุ่มหยอดเหรียญ/ใส่ธนบัตร
                      _buildPaymentButtons(
                        context,
                        'จำลองการหยอดเหรียญ',
                        coins,
                        Icons.monetization_on_rounded,
                      ),
                      const SizedBox(height: 20),
                      _buildPaymentButtons(
                        context,
                        'จำลองการใส่ธนบัตร',
                        banknotes,
                        Icons.receipt_long_rounded,
                      ),

                      const Spacer(),

                      // ปุ่มยกเลิก
                      OutlinedButton(
                        onPressed: () {
                          _timer.cancel();
                          handleTimeout();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('ยกเลิกรายการ'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Helper Widget สำหรับสร้างกลุ่มปุ่มชำระเงิน
  Widget _buildPaymentButtons(
    BuildContext context,
    String title,
    List<int> values,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Text(title, style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: values
              .map(
                (value) => ElevatedButton(
                  onPressed: () => insertMoney(value.toDouble()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.primaryColor,
                    side: BorderSide(color: Colors.grey.shade300),
                    elevation: 1,
                  ),
                  child: Text('${value.toInt()}฿'),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Future<void> _processAndNavigate() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Dialog(
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
      ),
    );

    final isSuccess = await widget.topupService.processTopup(
      widget.phoneNumber,
      widget.selectedAmount,
    );
    Navigator.pop(context);

    if (isSuccess) {
      await widget.topupService.markFirstTransactionAsComplete(
        widget.phoneNumber,
      );
    } else {
      // Logic for failure
    }

    final finalCredit = await widget.topupService.getSavedCredit(
      widget.phoneNumber,
    );
    final receipt = ReceiptData(
      isSuccess: isSuccess,
      transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      carrierName: widget.carrierName,
      phoneNumber: widget.phoneNumber,
      topupAmount: widget.selectedAmount,
      finalSavedCredit: finalCredit,
    );

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(receipt: receipt),
        ),
        (Route<dynamic> route) => route.isFirst,
      );
    }
  }
}
