// import 'package:barberapp/homepage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_login/flutter_login.dart';
// import 'package:barberapp/services/auth_service.dart'; // Import your AuthService here
// import 'package:barberapp/signuppage.dart';
// import 'package:quickalert/models/quickalert_type.dart';
// import 'package:quickalert/widgets/quickalert_dialog.dart';
// import 'package:barberapp/utils/color_utils.dart';
// import 'package:barberapp/reusable_widgets/reusable_widgets.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);

//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   Duration get loginTime => const Duration(milliseconds: 1500);

//   String? errorText;

//   final TextEditingController _passwordTextController = TextEditingController();
//   final TextEditingController _emailTextController = TextEditingController();

//   String getUserRole(String name) {
//     switch (name.toLowerCase()) {
//       case "user":
//         return "User";
//       case "customer":
//         return "Customer";
//       case "employee":
//         return "Employee";
//       case "admin":
//         return "Administrator";
//       default:
//         return "Unknown";
//     }
//   }

//   @override
//   void dispose() {
//     _passwordTextController.dispose();
//     _emailTextController.dispose();
//     super.dispose();
//   }

//   Future<void> _authUser(LoginData data) async {
//     debugPrint('Email: ${data.name}, Password: ${data.password}');
//     try {
//       String? result =
//           await AuthService().signInWithEmail(data.name, data.password);

//       if (result == "false") {
//         print("non role");
//         await QuickAlert.show(
//           context: context,
//           type: QuickAlertType.error,
//           title: 'ผิดพลาด',
//           text: "มีข้อผิดพลาดจากการเข้าสู่ระบบ",
//         );
//       } else {
//         // has user
//         var userid = FirebaseAuth.instance.currentUser!.uid;

//         var user = FirebaseFirestore.instance
//             .collection("Users")
//             .doc(userid)
//             .get()
//             .then((value) {
//           var role = value.data()!["role"];
//           if (role == "Customer") {
//             // Navigator to CustomerPage
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => MyHomePage()),
//             );
//             print("go to customerPage");
//           } else if (role == "Admin") {
//             // Navigator to AdminPage
//             print("AdminPage");
//           }
//         });
//       }

//       if (result == "success") {
//         // Get user role after successful login
//         String role = getUserRole(data.name);
//         setState(() {
//           errorText = null;
//         });
//         await QuickAlert.show(
//           context: context,
//           type: QuickAlertType.success,
//           text: 'เข้าสู่ระบบสำเร็จ!',
//           confirmBtnText: 'ตกลง',
//           showConfirmBtn: true,
//           autoCloseDuration: const Duration(seconds: 3),
//         ).then((value) async {
//           // Navigate to appropriate home page based on user role
//           if (role == "User") {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => MyHomePage()),
//             );
//             // } else if (role == "Owner") {
//             //   Navigator.pushReplacement(
//             //     context,
//             //     MaterialPageRoute(builder: (context) => EmployeeHomePage()),
//             //   );
//             // } else if (role == "Employee") {
//             //   Navigator.pushReplacement(
//             //     context,
//             //     MaterialPageRoute(builder: (context) => CustomerHomePage()),
//             //   );
//             // } else if (role == "Admin") {
//             //   Navigator.pushReplacement(
//             //     context,
//             //     MaterialPageRoute(builder: (context) => CustomerHomePage()),
//             //   );
//           } else {
//             print("non role");
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => LoginPage()),
//             );
//           }
//         });

//         return null; // Success, no error message
//       } else {
//         setState(() {
//           errorText = "ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้องกรุณากรอกใหม่";
//         });
//         await QuickAlert.show(
//           context: context,
//           type: QuickAlertType.error,
//           title: 'ผิดพลาด',
//           text: errorText!,
//         );
//         // return errorText;
//       }
//     } catch (e) {
//       debugPrint('Error: $e');
//       setState(() {
//         errorText = "เกิดข้อผิดพลาดในการเข้าสู่ระบบ";
//       });
//       await QuickAlert.show(
//         context: context,
//         type: QuickAlertType.error,
//         title: 'ผิดพลาด',
//         text: errorText!,
//       );
//       // return errorText;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               hexStringToColor("#000033"),
//               hexStringToColor("#000033"),
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.fromLTRB(
//               20,
//               MediaQuery.of(context).size.height * 0.2,
//               20,
//               0,
//             ),
//             child: Column(
//               children: <Widget>[
//                 logowidget("assets/images/logo1.png"),
//                 SizedBox(height: 30),
//                 reusableTextField(
//                   "Enter Username",
//                   Icons.person_outline,
//                   false,
//                   _emailTextController,
//                   validator: (value) {
//                     return;
//                   },
//                 ),
//                 SizedBox(height: 20),
//                 reusableTextField(
//                   "Enter Password",
//                   Icons.lock_outline,
//                   true,
//                   _passwordTextController,
//                   validator: (value) {
//                     return;
//                   },
//                 ),
//                 SizedBox(height: 20),
//                 if (errorText != null)
//                   Text(
//                     errorText!,
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 SizedBox(height: 20),
//                 signInSingUpButton(context, true, () async {
//                   final loginData = LoginData(
//                     name: _emailTextController.text.trim(),
//                     password: _passwordTextController.text.trim(),
//                   );
//                   await _authUser(loginData);
//                 }),
//                 signUpOption(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Row signUpOption() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           "คุณยังไม่มีบัญชีหรอ? ",
//           style: TextStyle(color: Colors.white70),
//         ),
//         GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => SignupPage()),
//             );
//           },
//           child: Text(
//             "สมัครสมาชิก",
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
