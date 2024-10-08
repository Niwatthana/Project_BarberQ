import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AuthService {
  Future<String> signInWithEmail(String email, String password) async {
    try {
      var user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "$email@barberq.com",
        password: password,
      );
      debugPrint(user.user!.uid);

      // ดึง FCM Token ของอุปกรณ์

      String? token = await FirebaseMessaging.instance.getToken();
      print("token>>$token");

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.user!.uid)
          .update({
        'deviceToken': token,
      });

      return user.user!.uid;
    } on FirebaseAuthException catch (e) {
      String errorMessage = _handleAuthException(e);
      print(errorMessage);
      return "false";
    } catch (e) {
      return "false";
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "ไม่พบผู้ใช้นี้";
      case 'wrong-password':
        return "รหัสผ่านไม่ถูกต้อง";
      case 'invalid-email':
        return "อีเมลไม่ถูกต้อง";
      case 'user-disabled':
        return "บัญชีผู้ใช้ถูกระงับ";
      default:
        return "เกิดข้อผิดพลาดในการเข้าสู่ระบบ";
    }
  }

  Future<String> signupUser(String name, String password, String tel,
      String username, String type) async {
    try {
      // สร้างผู้ใช้ใหม่ใน Firebase Authentication

      var user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "$username@barberq.com",
        password: password,
      );

      var uid = user.user!.uid;

      // บันทึกข้อมูลผู้ใช้ใน Firestore รวมถึง FCM token
      await FirebaseFirestore.instance.collection('Users').doc(uid).set({
        'name': name,
        'role': type,
        'tel': tel,
        'username': username,
      });

      print(type);

      if (type == "Owner") {
        // เพิ่ม owner_id ใน Collection Barbershops
        await FirebaseFirestore.instance
            .collection("BarberShops")
            .doc(uid)
            .set({
          'owner_id': uid,
          'name': name,
          'owner_id1': FirebaseFirestore.instance.collection("Users").doc(uid),
        });

        await FirebaseFirestore.instance.collection("Barbers").doc(uid).set({
          'barbershop_id': uid,
          'barbershop_id1':
              FirebaseFirestore.instance.collection("BarberShops").doc(uid),
          'status': true,
          'name': name,
          'barber_id': uid,
          'barber_id1': FirebaseFirestore.instance.collection("Users").doc(uid),
        });
        print("in เจ้าของ");
      } else if (type == "Barber") {
        // เพิ่ม status = false ใน Collection Barbers
        await FirebaseFirestore.instance.collection("Barbers").doc(uid).set({
          'barbershop_id': null,
          'barbershop_id1': null,
          'status': false,
          'name': name,
          'barber_id': uid,
          'barber_id1': FirebaseFirestore.instance.collection("Users").doc(uid),
        });
        print("in ช่างตัดผม");
      } else if (type == 'Customer') {
        // เพิ่มข้อมูลใน Collection Customers (คุณสามารถเพิ่มข้อมูลเพิ่มเติมที่ต้องการ)
      }

      return "create user success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'รหัสผ่านไม่ปลอดภัยพอ';
      } else if (e.code == 'email-already-in-use') {
        return 'ชื่อนี้มีอยู่แล้วบนอีเมลนั้น';
      }
      return 'ข้อผิดพลาด กรุณาลองใหม่';
    } catch (e) {
      print(e);
      return 'ข้อผิดพลาด กรุณาลองใหม่';
    }
  }
}
