// import 'dart:io';
// import 'package:barberapp/pages/cutomer/owner/owner_epy.dart';
// import 'package:barberapp/pages/cutomer/owner/owner_hair.dart';
// import 'package:barberapp/pages/cutomer/owner/ownerpage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';

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
//   bool _isLoading = false;
//   String? _imageUrl; // Variable to store the image URL
//   double lat = 0, long = 0;

//   @override
//   void initState() {
//     getPosition();
//     super.initState();
//   }

//   void getPosition() async {
//     Position position = await _determinePosition();
//     print(position.latitude);
//     setState(() {
//       lat = position.latitude;
//       long = position.longitude;
//     });
//   }

//   Future<Position> _determinePosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Test if location services are enabled.
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Location services are not enabled don't continue
//       // accessing the position and request users of the
//       // App to enable the location services.
//       return Future.error('Location services are disabled.');
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // Permissions are denied, next time you could try
//         // requesting permissions again (this is also where
//         // Android's shouldShowRequestPermissionRationale
//         // returned true. According to Android guidelines
//         // your App should show an explanatory UI now.
//         return Future.error('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       // Permissions are denied forever, handle appropriately.
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }

//     // When we reach here, permissions are granted and we can
//     // continue accessing the position of the device.
//     return await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//   }

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
//                           : _imageUrl != null
//                               ? ClipRRect(
//                                   borderRadius: BorderRadius.circular(50),
//                                   child: Image.network(
//                                     _imageUrl!,
//                                     width: 100,
//                                     height: 100,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 )
//                               : Container(
//                                   decoration: BoxDecoration(
//                                       color: Colors.grey[200],
//                                       borderRadius: BorderRadius.circular(50)),
//                                   width: 100,
//                                   height: 100,
//                                   child: Icon(
//                                     Icons.camera_alt,
//                                     color: Colors.grey[800],
//                                   ),
//                                 ),
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
//                       child: Text(
//                         'gps ของร้าน: lat: $lat, long: $long',
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
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         minimumSize: Size(150, 50),
//                       ),
//                       child: Text(
//                         'ยกเลิก',
//                         style: TextStyle(color: Colors.black, fontSize: 18),
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: _isLoading ? null : _uploadImage,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         minimumSize: Size(150, 50),
//                       ),
//                       child: _isLoading
//                           ? CircularProgressIndicator()
//                           : Text(
//                               'บันทึก',
//                               style:
//                                   TextStyle(color: Colors.black, fontSize: 18),
//                             ),
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
//               title: const Text('หน้าหลัก'),
//               selected: _selectedIndex == 0,
//               onTap: () {
//                 setState(() {
//                   _selectedIndex = 0;
//                 });

//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => OwnerPage()));
//               },
//             ),
//             ListTile(
//               title: const Text('ร้านตัดผมของฉัน'),
//               selected: _selectedIndex == 1,
//               onTap: () {
//                 setState(() {
//                   _selectedIndex = 1;
//                 });

//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => Ownershop()));
//               },
//             ),
//             ListTile(
//               title: const Text('ช่างตัดผม'),
//               selected: _selectedIndex == 2,
//               onTap: () {
//                 setState(() {
//                   _selectedIndex = 2;
//                 });
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => OwnerEmployee()));
//               },
//             ),
//             ListTile(
//               title: const Text('ทรงผม'),
//               selected: _selectedIndex == 3,
//               onTap: () {
//                 setState(() {
//                   _selectedIndex = 3;
//                 });
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => Ownerhair()));
//               },
//             ),
//             ListTile(
//               title: const Text('การจองของลูกค้า'),
//               selected: _selectedIndex == 4,
//               onTap: () {
//                 setState(() {
//                   _selectedIndex = 4;
//                 });
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('รายงานสรุป'),
//               selected: _selectedIndex == 5,
//               onTap: () {
//                 setState(() {
//                   _selectedIndex = 5;
//                 });
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

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

//   Future<void> _uploadImage() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       if (selectedImage != null) {
//         // Upload image to Firebase Storage
//         String fileName = FirebaseAuth.instance.currentUser!.uid;
//         Reference ref =
//             FirebaseStorage.instance.ref().child('images/$fileName.jpg');

//         SettableMetadata metadata = SettableMetadata(
//           contentType: 'image/jpeg',
//         );

//         UploadTask uploadTask = ref.putFile(selectedImage!, metadata);
//         TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
//         // String imageUrl = await taskSnapshot.ref.getDownloadURL();
//         // Get download URL
//         String downloadUrl = await taskSnapshot.ref.getDownloadURL();
//         // Save data to Firestore
//         DocumentReference docRef = FirebaseFirestore.instance
//             .collection('BarberShops')
//             .doc(FirebaseAuth.instance.currentUser!.uid);
//         await docRef.set({
//           'test': "e-gill",
//           'shop_img': downloadUrl,
//           'details': _detailsController.text,
//           'latitude': lat,
//           'longitude': long,
//         });

//         // Set the uploaded image URL to the state variable
//         setState(() {
//           _imageUrl = downloadUrl;
//         });
//       }

//       // Perform any additional logic here (e.g., saving details to Firestore)
//       // Example:
//       // await FirebaseFirestore.instance.collection('shops').add({
//       //   'details': _detailsController.text,
//       //   'imageUrl': _imageUrl,
//       // });

//       // Clear the input fields and reset the state
//       _detailsController.clear();
//       setState(() {
//         _image = null;
//         selectedImage = null;
//         _isLoading = false;
//       });

//       // Show a success message or navigate to another screen
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
//         duration: Duration(seconds: 2),
//       ));
//     } catch (error) {
//       // Handle any errors that occur during the upload process
//       print('เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ: $error');
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล'),
//         duration: Duration(seconds: 2),
//       ));
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('ยืนยันการออกจากระบบ'),
//           content: Text('คุณต้องการที่จะออกจากระบบหรือไม่?'),
//           actions: <Widget>[
//             TextButton(
//               child: Text('ยกเลิก'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('ยืนยัน'),
//               onPressed: () {
//                 // Implement logout functionality
//                 Navigator.of(context).pop();
//                 // Example:
//                 // FirebaseAuth.instance.signOut();
//                 // Navigator.of(context).pushReplacementNamed('/login');
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
