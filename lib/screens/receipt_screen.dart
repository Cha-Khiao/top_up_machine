// lib/screens/receipt_screen.dart

import 'package:flutter/material.dart';
import 'package:top_up_machine/models/transaction_data.dart';
import 'package:intl/intl.dart';

class ReceiptScreen extends StatelessWidget {
  final ReceiptData receipt;
  const ReceiptScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat formatter = DateFormat('dd MMMM yyyy, HH:mm:ss', 'th_TH');
    final String formattedDate = formatter.format(receipt.timestamp);
    final statusColor = receipt.isSuccess
        ? Colors.green.shade600
        : Colors.red.shade600;

    return Scaffold(
      // AppBar จะใช้ดีไซน์จาก Theme ใน main.dart โดยอัตโนมัติ
      appBar: AppBar(
        title: const Text('ผลการทำรายการ'),
        // ปิดปุ่ม back อัตโนมัติ เพราะผู้ใช้ควรกด "เสร็จสิ้น" เท่านั้น
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. ไอคอนสถานะ
                Icon(
                  receipt.isSuccess
                      ? Icons.check_circle_outline_rounded
                      : Icons.error_outline_rounded,
                  color: statusColor,
                  size: 80,
                ),
                const SizedBox(height: 16),

                // 2. ข้อความสถานะ
                Text(
                  receipt.isSuccess ? 'เติมเงินสำเร็จ' : 'เติมเงินล้มเหลว',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 32),

                // 3. การ์ดใบเสร็จ
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'ใบเสร็จ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildReceiptRow(
                          theme,
                          'สถานะ:',
                          receipt.isSuccess ? 'สำเร็จ' : 'ล้มเหลว',
                        ),
                        _buildReceiptRow(
                          theme,
                          'เครือข่าย:',
                          receipt.carrierName,
                        ),
                        _buildReceiptRow(
                          theme,
                          'หมายเลข:',
                          receipt.phoneNumber,
                        ),
                        _buildReceiptRow(
                          theme,
                          'จำนวนเงิน:',
                          '${receipt.topupAmount.toInt()} บาท',
                        ),
                        _buildReceiptRow(theme, 'วันที่-เวลา:', formattedDate),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(thickness: 1),
                        ),
                        _buildReceiptRow(
                          theme,
                          'เงินสะสมคงเหลือ:',
                          '${receipt.finalSavedCredit.toStringAsFixed(2)} บาท',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. ข้อความแจ้งเตือนกรณีล้มเหลว
                if (!receipt.isSuccess)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text(
                      'เงินของท่านได้ถูกเก็บเป็นยอดสะสมเรียบร้อยแล้ว หากมีปัญหาติดต่อ 02-123-4567',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),

                // 5. ปุ่มเสร็จสิ้น
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('กลับสู่หน้าหลัก'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget สำหรับสร้างแถวในใบเสร็จ
  Widget _buildReceiptRow(
    ThemeData theme,
    String title,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
