import 'package:barberapp/pages/barber/barberpage.dart';
import 'package:barberapp/pages/cutomer/homecutomer.dart';
import 'package:barberapp/pages/owner/ownerpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:barberapp/services/auth_service.dart'; // Import your AuthService here
import 'package:barberapp/signuppage.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:barberapp/utils/color_utils.dart';
import 'package:barberapp/reusable_widgets/reusable_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Duration get loginTime => const Duration(milliseconds: 1500);

  String? errorText;

  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  String getUserRole(String role) {
    switch (role.toLowerCase()) {
      case "owner":
        return "Owner";
      case "customer":
        return "Customer";
      case "barber":
        return "Barber";
      default:
        return "Unknown";
    }
  }

  @override
  void dispose() {
    _passwordTextController.dispose();
    _emailTextController.dispose();
    super.dispose();
  }

  Future<void> _authUser(LoginData data) async {
    debugPrint('Email: ${data.name}, Password: ${data.password}');
    try {
      String? result =
          await AuthService().signInWithEmail(data.name, data.password);

      if (result == "false") {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'ผิดพลาด',
          text: "มีข้อผิดพลาดจากการเข้าสู่ระบบ",
        );
      } else {
        var userid = FirebaseAuth.instance.currentUser!.uid;

        var user = await FirebaseFirestore.instance
            .collection("Users")
            .doc(userid)
            .get();
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'เข้าสู่ระบบสำเร็จ!',
          confirmBtnText: 'ตกลง',
          showConfirmBtn: false,
          autoCloseDuration: const Duration(seconds: 1),
        );
        var role = user.data()!["role"];
        switch (role) {
          case "Customer":
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeCustomer()),
            );
            print("Customer");
            break;
          case "Barber":
            // Navigate to EmployeePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BarberPage()),
            );
            print("Barber");
            break;
          case "Owner":
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OwnerPage()),
            );
            print("Owner");
            break;
          default:
            await QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'ผิดพลาด',
              text: "ไม่มีบทบาทผู้ใช้ที่ถูกต้อง",
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
            break;
        }

        return null; // Success, no error message
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        errorText = "เกิดข้อผิดพลาดในการเข้าสู่ระบบ";
      });
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'ผิดพลาด',
        text: errorText!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("#000033"),
              hexStringToColor("#000033"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.2,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                logowidget("assets/images/logo1.png"),
                SizedBox(height: 30),
                reusableTextField(
                  "Enter Username",
                  Icons.person_outline,
                  false,
                  _emailTextController,
                  validator: (value) {
                    return null;
                  },
                ),
                SizedBox(height: 20),
                reusableTextField(
                  "Enter Password",
                  Icons.lock_outline,
                  true,
                  _passwordTextController,
                  validator: (value) {
                    return null;
                  },
                ),
                SizedBox(height: 20),
                if (errorText != null)
                  Text(
                    errorText!,
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 20),
                signInSingUpButton(context, true, () async {
                  final loginData = LoginData(
                    name: _emailTextController.text.trim(),
                    password: _passwordTextController.text.trim(),
                  );
                  await _authUser(loginData);
                }),
                signUpOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "คุณยังไม่มีบัญชีหรอ? ",
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignupPage()),
            );
          },
          child: Text(
            "สมัครสมาชิก",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
