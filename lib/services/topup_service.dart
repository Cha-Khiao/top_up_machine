// lib/services/topup_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class TopupService {
  // --- ฐานข้อมูลจำลอง ---
  final Map<String, String> _phoneStatus = {
    '0823456789': 'inactive', // เบอร์ปิดบริการ
  };

  // ใหม่: ฐานข้อมูลจำลองสำหรับตรวจสอบว่าเบอร์ไหนอยู่ค่ายไหนจาก Prefix
  final Map<String, String> _phoneCarrierDatabase = {
    // AIS Prefixes
    '081': 'AIS',
    '092': 'AIS',
    '093': 'AIS',
    '098': 'AIS',
    // TrueMove H Prefixes
    '083': 'TrueMove H',
    '084': 'TrueMove H',
    '086': 'TrueMove H',
    '095': 'TrueMove H',
    // dtac Prefixes
    '085': 'dtac',
    '089': 'dtac',
    '094': 'dtac',
    '099': 'dtac',
  };

  // --- ฟังก์ชันใหม่ ---
  // ดึงชื่อค่ายจากเบอร์โทรศัพท์
  String? getCarrierForPhoneNumber(String phoneNumber) {
    if (phoneNumber.length < 3) {
      return null;
    }
    final prefix = phoneNumber.substring(0, 3);
    return _phoneCarrierDatabase[prefix];
  }

  // --- Methods for interacting with local storage (คงเดิม) ---
  Future<double> getSavedCredit(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('credit_$phoneNumber') ?? 0.0;
  }

  Future<void> updateSavedCredit(String phoneNumber, double newAmount) async {
    final prefs = await SharedPreferences.getInstance();
    if (newAmount > 0) {
      await prefs.setDouble('credit_$phoneNumber', newAmount);
    } else {
      await prefs.remove('credit_$phoneNumber');
    }
  }

  Future<bool> isFirstTransaction(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('completed_$phoneNumber') ?? false);
  }

  Future<void> markFirstTransactionAsComplete(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('completed_$phoneNumber', true);
  }

  // --- Methods for business logic (คงเดิม) ---
  String getPhoneStatus(String phoneNumber) {
    return _phoneStatus[phoneNumber] ?? 'active';
  }

  Future<bool> processTopup(String phoneNumber, double amount) async {
    await Future.delayed(const Duration(seconds: 3));
    if (getPhoneStatus(phoneNumber) == 'inactive') {
      return false;
    }
    return true;
  }
}
