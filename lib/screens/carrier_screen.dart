// lib/screens/carrier_screen.dart

import 'package:flutter/material.dart';
import 'package:top_up_machine/screens/phone_screen.dart';
import 'package:top_up_machine/services/topup_service.dart';

class CarrierScreen extends StatelessWidget {
  final TopupService topupService;
  const CarrierScreen({super.key, required this.topupService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final carriers = [
      {'name': 'TrueMove H', 'logo': 'true_logo.png'},
      {'name': 'dtac', 'logo': 'dtac_logo.png'},
      {'name': 'AIS', 'logo': 'ais_logo.png'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ขั้นตอนที่ 1: เลือกเครือข่าย'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ListView.separated(
            padding: const EdgeInsets.all(24.0),
            itemCount: carriers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final carrier = carriers[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhoneScreen(
                          carrierName: carrier['name'] as String,
                          topupService: topupService,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // --- ปรับปรุงส่วนนี้ ---
                        SizedBox(
                          // ใช้ SizedBox กำหนดขนาดที่แน่นอน
                          width: 120, // กำหนดความกว้างที่ต้องการ
                          height: 60, // กำหนดความสูงที่ต้องการ
                          child: Image.asset(
                            'assets/${carrier['logo'] as String}',
                            // height: 50, // ไม่จำเป็นต้องกำหนด height ตรงนี้แล้ว
                            fit: BoxFit
                                .contain, // จะทำให้ภาพขยาย/ย่อให้พอดีกับขนาดของ SizedBox โดยไม่บิดเบี้ยว
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                        // --- สิ้นสุดการปรับปรุง ---
                        const SizedBox(height: 12),
                        Text(
                          carrier['name'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
