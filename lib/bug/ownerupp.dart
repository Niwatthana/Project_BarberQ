// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class Ownershop extends StatefulWidget {
//   const Ownershop({super.key});

//   @override
//   State<Ownershop> createState() => _OwnershopState();
// }

// class _OwnershopState extends State<Ownershop> {
//   final TextEditingController _detailsController = TextEditingController();
//   Uint8List? _image;
//   File? selectedImage;
//   int _selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Menu"),
//         actions: <Widget>[
//           PopupMenuButton<String>(
//             icon: Icon(Icons.account_circle),
//             onSelected: (String result) {
//               switch (result) {
//                 case 'history':
//                   // Navigate to customer booking history page
//                   break;
//                 case 'logout':
//                   showLogoutDialog(context);
//                   break;
//               }
//             },
//             itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//               const PopupMenuItem<String>(
//                 value: 'history',
//                 child: Text('ประวัติของฉัน'),
//               ),
//               const PopupMenuItem<String>(
//                 value: 'logout',
//                 child: Text('ออกจากระบบ'),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: ListView(
//         shrinkWrap: true,
//         children: [
//           Container(
//             height: 700,
//             padding: EdgeInsets.only(top: 15),
//             decoration: BoxDecoration(
//               color: Color(0xFFEDECF2),
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(35),
//                 topRight: Radius.circular(35),
//               ),
//             ),
//             child: Column(
//               children: [
//                 Center(
//                   child: GestureDetector(
//                     onTap: () {
//                       showImagePickerOption(context);
//                     },
//                     child: CircleAvatar(
//                       radius: 55,
//                       backgroundColor: Color(0xffFDCF09),
//                       child: _image != null
//                           ? ClipRRect(
//                               borderRadius: BorderRadius.circular(50),
//                               child: Image.memory(
//                                 _image!,
//                                 width: 100,
//                                 height: 100,
//                                 fit: BoxFit.cover,
//                               ),
//                             )
//                           : Container(
//                               decoration: BoxDecoration(
//                                   color: Colors.grey[200],
//                                   borderRadius: BorderRadius.circular(50)),
//                               width: 100,
//                               height: 100,
//                               child: Icon(
//                                 Icons.camera_alt,
//                                 color: Colors.grey[800],
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Text(
//                   'รายละเอียดร้าน',
//                   style: TextStyle(fontSize: 18),
//                 ),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: _detailsController,
//                   maxLines: 4,
//                   decoration: InputDecoration(
//                     hintText: 'โปรดกรอกรายละเอียดของร้าน',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Row(
//                   children: <Widget>[
//                     Icon(Icons.gps_fixed),
//                     SizedBox(width: 10),
//                     GestureDetector(
//                       // onTap: ,
//                       child: Text(
//                         'gps ของร้าน',
//                         style: TextStyle(fontSize: 16, color: Colors.blue),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Spacer(),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: <Widget>[
//                     ElevatedButton(
//                       onPressed: () {
//                         // handle submit
//                       },
//                       child: Text('ตกลง'),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         // handle cancel
//                       },
//                       child: Text('ยกเลิก'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             const DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//               ),
//               child: Text("BarBer Shop"),
//             ),
//             ListTile(
//               title: const Text('ร้านตัดผมของฉัน'),
//               selected: _selectedIndex == 0,
//               onTap: () {
//                 setState(() {
//                   _selectedIndex = 0;
//                 });
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => Ownershop()));
//               },
//             ),
//             ListTile(
//               title: const Text('ช่างตัดผม'),
//               selected: _selectedIndex == 1,
//               onTap: () {
//                 setState(() {
//                   _selectedIndex = 1;
//                 });
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('ทรงผม'),
//               selected: _selectedIndex == 2,
//               onTap: () {
//                 setState(() {
//                   _selectedIndex = 2;
//                 });
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('การจองของลูกค้า'),
//               selected: _selectedIndex == 3,
//               onTap: () {
//                 setState(() {
//                   _selectedIndex = 3;
//                 });
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('รายงานสรุป'),
//               selected: _selectedIndex == 4,
//               onTap: () {
//                 setState(() {
//                   _selectedIndex = 4;
//                 });
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Function to show image picker options
//   void showImagePickerOption(BuildContext context) {
//     showModalBottomSheet(
//       backgroundColor: Colors.blue[100],
//       context: context,
//       builder: (builder) {
//         return Padding(
//           padding: const EdgeInsets.all(18.0),
//           child: SizedBox(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height / 4.5,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       _pickImageFromGallery();
//                     },
//                     child: const Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.image,
//                           size: 70,
//                         ),
//                         Text("Gallery"),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       _pickImageFromCamera();
//                     },
//                     child: const Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.camera_alt,
//                           size: 70,
//                         ),
//                         Text("Camera"),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Function to pick image from gallery
//   Future<void> _pickImageFromGallery() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile == null) return;
//     setState(() {
//       selectedImage = File(pickedFile.path);
//       _image = File(pickedFile.path).readAsBytesSync();
//     });
//     Navigator.of(context).pop(); // Close the modal sheet
//   }

//   // Function to pick image from camera
//   Future<void> _pickImageFromCamera() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.camera);
//     if (pickedFile == null) return;
//     setState(() {
//       selectedImage = File(pickedFile.path);
//       _image = File(pickedFile.path).readAsBytesSync();
//     });
//     Navigator.of(context).pop(); // Close the modal sheet
//   }

//   // Function to show logout dialog
//   void showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("ออกจากระบบ"),
//           content: Text("คุณแน่ใจหรือว่าต้องการออกจากระบบ?"),
//           actions: <Widget>[
//             TextButton(
//               child: Text("ยกเลิก"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text("ตกลง"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 // Perform logout operation
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
