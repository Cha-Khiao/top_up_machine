// lib/widgets/info_dialog.dart

import 'package:flutter/material.dart';

Future<void> showInfoDialog({
  required BuildContext context,
  required String title,
  required String message,
  IconData? icon,
  Color? iconColor,
}) {
  // ดึงค่า Theme มาใช้ในการกำหนดสไตล์
  final theme = Theme.of(context);

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // ผู้ใช้ต้องกดปุ่มเพื่อปิด
    builder: (BuildContext context) {
      return AlertDialog(
        // รูปทรงจะดึงมาจาก cardTheme ใน main.dart
        shape: theme.cardTheme.shape,
        // กำหนด Style ของ Title ให้สอดคล้องกับ Theme
        titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? theme.primaryColor, size: 28),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(title)),
          ],
        ),
        // กำหนด Style ของ Content ให้สอดคล้องกับ Theme
        contentTextStyle: theme.textTheme.bodyLarge,
        content: Text(message),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: <Widget>[
          // เปลี่ยนเป็น ElevatedButton เพื่อให้มีดีไซน์เหมือนปุ่มหลัก
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      );
    },
  );
}
