// import 'package:barberapp/loginpage.dart';
// import 'package:barberapp/reusable_widgets/reusable_widgets.dart';
// import 'package:barberapp/services/auth_service.dart';
// import 'package:barberapp/utils/color_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:quickalert/models/quickalert_type.dart';
// import 'package:quickalert/widgets/quickalert_dialog.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final TextEditingController _passwordTextController = TextEditingController();
//   final TextEditingController _usernameTextController = TextEditingController();
//   final TextEditingController _telTextController = TextEditingController();
//   final TextEditingController _nameTextController = TextEditingController();

//   List<String> items = ["ลูกค้า", "เจ้าของร้านตัดผม"];
//   String selectedItem = "ลูกค้า";

//   Future<String?> _signupUser() async {
//     debugPrint(
//         'Signup Name: ${_nameTextController.text}, Password: ${_passwordTextController.text}, tel: ${_telTextController.text}, username: ${_usernameTextController.text}');
//     debugPrint(selectedItem);

//     try {
//       String? result = await AuthService().signupUser(
//           _nameTextController.text,
//           _passwordTextController.text,
//           _telTextController.text,
//           _usernameTextController.text,
//           selectedItem);
//       if (result == "create user success") {
//         await QuickAlert.show(
//           context: context,
//           type: QuickAlertType.success,
//           text: 'สมัครสมาชิกสำเร็จ!',
//           confirmBtnText: 'ตกลง',
//           showConfirmBtn: false,
//           autoCloseDuration: const Duration(seconds: 3),
//         ).then((value) async {
//           // Close the modal
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => LoginPage()),
//           );
//         });
//         return null; // Signup success
//       } else {
//         await QuickAlert.show(
//           context: context,
//           type: QuickAlertType.error,
//           title: 'ผิดพลาด',
//           text: "เกิดข้อผิดพลาดในการสมัครสมาชิก",
//         );
//         return "เกิดข้อผิดพลาดในการสมัครสมาชิก"; // Signup error message
//       }
//     } catch (e) {
//       debugPrint('Signup Error: $e');
//       await QuickAlert.show(
//         context: context,
//         type: QuickAlertType.error,
//         title: 'ผิดพลาด',
//         text: "เกิดข้อผิดพลาดในการสมัครสมาชิก",
//       );
//       return "เกิดข้อผิดพลาดในการสมัครสมาชิก";
//     }
//   }

//   @override
//   void dispose() {
//     _passwordTextController.dispose();
//     _usernameTextController.dispose();
//     _telTextController.dispose();
//     _nameTextController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text(
//           "กลับ",
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: Container(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               hexStringToColor("#6A5ACD"), //#6A5ACD
//               hexStringToColor("#6A5ACD"),
//               hexStringToColor("#000033")
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.fromLTRB(
//                 20, MediaQuery.of(context).size.height * 0.2, 20, 0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 reusableTextField(
//                   "Enter Name",
//                   Icons.person_outline,
//                   false,
//                   _nameTextController,
//                   validator: (value) {
//                     return;
//                   },
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 reusableTextField(
//                   "Enter Tel",
//                   Icons.phone_outlined,
//                   false,
//                   _telTextController,
//                   validator: (value) {
//                     return;
//                   },
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 reusableTextField(
//                   "Enter Username",
//                   Icons.person_outline,
//                   false,
//                   _usernameTextController,
//                   validator: (value) {
//                     return;
//                   },
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 reusableTextField(
//                   "Enter Password",
//                   Icons.lock_outline,
//                   true,
//                   _passwordTextController,
//                   validator: (value) {
//                     return;
//                   },
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 Center(
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 20),
//                     child: DropdownButtonFormField<String>(
//                       value: selectedItem,
//                       items: items
//                           .map((item) => DropdownMenuItem<String>(
//                                 value: item,
//                                 child: Text(
//                                   item,
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     color: Colors
//                                         .white, // Text color in dropdown items
//                                   ),
//                                 ),
//                               ))
//                           .toList(),
//                       onChanged: (item) => setState(() => selectedItem = item!),
//                       dropdownColor:
//                           Colors.black87, // Background color of dropdown
//                       icon: const Icon(Icons.arrow_drop_down,
//                           color: Colors.white),
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(5.0),
//                           borderSide: const BorderSide(
//                             color: Colors.black, // Border color
//                             width: 2.0, // Border width
//                           ),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(5.0),
//                           borderSide: const BorderSide(
//                             color: Colors.white, // Border color
//                             width: 2.0, // Border width
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(5.0),
//                           borderSide: const BorderSide(
//                             color: Colors.white, // Border color
//                             width: 2.0, // Border width
//                           ),
//                         ),
//                       ),
//                       style: const TextStyle(
//                         color: Colors.black, // Text color when selected
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 signInSingUpButton(context, false, () {
//                   _signupUser();
//                 }),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
