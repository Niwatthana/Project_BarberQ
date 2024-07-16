import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  Future<String> signInWithEmail(String email, String password) async {
    try {
      var user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "$email@test.com",
        password: password,
      );
      debugPrint(user.user!.uid);

      return user.user!.uid;
    } on FirebaseAuthException catch (e) {
      String errorMessage = _handleAuthException(e);
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
        email: "$username@test.com",
        password: password,
      );

      var uid = user.user!.uid;

      // บันทึกข้อมูลผู้ใช้ใน Firestore
      await FirebaseFirestore.instance.collection('Users').doc(uid).set({
        'name': name,
        'role': type,
        'tel': tel,
        'username': username,
      });

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
