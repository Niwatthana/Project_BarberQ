import 'package:barberapp/loginpage.dart';
import 'package:flutter/material.dart';

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white, // สีพื้นหลังของ AlertDialog
        title: Text('ออกจากระบบ',
            style: TextStyle(color: Colors.red)), // สีของข้อความใน title
        content: Text('ออกจากระบบแล้ว', style: TextStyle(color: Colors.black)),
        actions: <Widget>[
          TextButton(
            child: Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
            onPressed: () {
              Navigator.of(context).pop(); // ปิด AlertDialog
            },
          ),
          TextButton(
            child: Text('ตกลง', style: TextStyle(color: Colors.green)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      );
    },
  );
}