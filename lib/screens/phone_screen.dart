// lib/screens/phone_screen.dart

import 'package:flutter/material.dart';
import 'package:top_up_machine/screens/amount_screen.dart';
import 'package:top_up_machine/services/topup_service.dart';
import 'package:top_up_machine/widgets/info_dialog.dart';

class PhoneScreen extends StatefulWidget {
  final String carrierName;
  final TopupService topupService;
  const PhoneScreen({
    super.key,
    required this.carrierName,
    required this.topupService,
  });

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _phoneController = TextEditingController();
  String? _errorText;
  Future<Map<String, dynamic>>? _creditDataFuture;

  void _validatePhoneNumber() {
    final phone = _phoneController.text;
    setState(() {
      _errorText = null;
    });

    if (phone.length != 10) {
      setState(() {
        _errorText = 'กรุณากรอกหมายเลขโทรศัพท์ให้ครบ 10 หลัก';
      });
      return;
    }

    if (widget.topupService.getPhoneStatus(phone) == 'inactive') {
      showInfoDialog(
        context: context,
        title: 'เกิดข้อผิดพลาด',
        message: 'เบอร์ $phone ถูกปิดบริการ ไม่สามารถทำรายการได้',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      );
      return;
    }

    // --- ตรรกะใหม่: ตรวจสอบค่ายของเบอร์โทร ---
    final actualCarrier = widget.topupService.getCarrierForPhoneNumber(phone);

    if (actualCarrier == null) {
      showInfoDialog(
        context: context,
        title: 'ไม่พบข้อมูล',
        message: 'ไม่พบข้อมูลเครือข่ายสำหรับเบอร์โทรศัพท์นี้',
        icon: Icons.help_outline,
        iconColor: Colors.orange,
      );
      return;
    }

    if (actualCarrier != widget.carrierName) {
      showInfoDialog(
        context: context,
        title: 'เครือข่ายไม่ถูกต้อง',
        message:
            'หมายเลข $phone ไม่ได้อยู่ในเครือข่าย ${widget.carrierName} กรุณาตรวจสอบอีกครั้ง',
        icon: Icons.wifi_off,
        iconColor: Colors.red,
      );
      return;
    }
    // --- สิ้นสุดตรรกะใหม่ ---

    // ถ้าทุกอย่างถูกต้อง ไปยังหน้าถัดไป
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AmountScreen(
          carrierName: widget.carrierName,
          phoneNumber: phone,
          topupService: widget.topupService,
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchCreditData(String phone) async {
    if (phone.length != 10) return {'show': false, 'credit': 0.0};
    final savedCredit = await widget.topupService.getSavedCredit(phone);
    final isFirstTime = await widget.topupService.isFirstTransaction(phone);
    return {'show': savedCredit > 0 && !isFirstTime, 'credit': savedCredit};
  }

  void _onPhoneChanged(String phone) {
    setState(() {
      if (phone.length == 10) {
        _creditDataFuture = _fetchCreditData(phone);
      } else {
        _creditDataFuture = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() => _onPhoneChanged(_phoneController.text));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ขั้นตอนที่ 2: กรอกเบอร์ (${widget.carrierName})'),
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_creditDataFuture != null)
                FutureBuilder<Map<String, dynamic>>(
                  future: _creditDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasData && snapshot.data!['show'] == true) {
                      final credit = snapshot.data!['credit'];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ยอดเงินสะสม: $credit บาท',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'หมายเลขโทรศัพท์',
                  prefixIcon: const Icon(Icons.phone),
                  border: const OutlineInputBorder(),
                  errorText: _errorText,
                ),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ย้อนกลับ'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _validatePhoneNumber,
                      child: const Text('ถัดไป'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
