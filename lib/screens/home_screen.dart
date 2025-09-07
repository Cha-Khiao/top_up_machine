// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:top_up_machine/screens/carrier_screen.dart';
import 'package:top_up_machine/services/topup_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ใช้ LayoutBuilder เพื่อให้ปรับขนาดตามหน้าจอได้ดีขึ้น
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                // กำหนดความกว้างสูงสุดของการ์ด
                constraints: const BoxConstraints(maxWidth: 400),
                margin: const EdgeInsets.all(24.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      spreadRadius: 5,
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ไอคอนโทรศัพท์
                    Icon(
                      Icons.phone_iphone_rounded,
                      size: 60,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(height: 24),
                    // ข้อความหัวข้อ
                    const Text(
                      'ตู้เติมเงินมือถืออัจฉริยะ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ข้อความรอง
                    Text(
                      'บริการเติมเงินออนไลน์ สะดวก รวดเร็ว',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),
                    // ปุ่มเริ่มทำรายการ
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CarrierScreen(topupService: TopupService()),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(
                          double.infinity,
                          50,
                        ), // ทำให้ปุ่มกว้างเต็ม
                      ),
                      child: const Text('เริ่มทำรายการ'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
