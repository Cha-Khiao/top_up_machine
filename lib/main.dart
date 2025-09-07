// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:top_up_machine/screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart'; // 1. Import package intl

void main() async {
  // 2. เปลี่ยน main เป็น async
  WidgetsFlutterBinding.ensureInitialized();

  // 3. เพิ่มบรรทัดนี้เพื่อเตรียมข้อมูลภาษาไทยสำหรับ DateFormat
  await initializeDateFormatting('th_TH', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // โค้ดส่วนที่เหลือเหมือนเดิม
    const primaryColor = Color(0xFF007BFF);
    const backgroundColor = Color(0xFFF5F7FA);
    const textColor = Color(0xFF333333);

    return MaterialApp(
      title: 'Top-up Machine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        textTheme: GoogleFonts.kanitTextTheme(
          ThemeData.light().textTheme,
        ).apply(bodyColor: textColor, displayColor: textColor),
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          elevation: 0,
          centerTitle: true,
          foregroundColor: textColor,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Kanit',
            ),
            elevation: 2,
            shadowColor: primaryColor.withOpacity(0.2),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.grey.shade600),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
