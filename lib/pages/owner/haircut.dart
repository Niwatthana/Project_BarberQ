// import 'package:barberapp/homepage.dart';
// import 'package:barberapp/pages/cutomer/owner/edithaircut.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:quickalert/quickalert.dart';

// void main() => runApp(const HaircutPage());

// class HaircutPage extends StatefulWidget {
//   const HaircutPage({super.key});
//   @override
//   State<HaircutPage> createState() => _HaircutPageState();
// }

// class _HaircutPageState extends State<HaircutPage> {
//   int _selectedIndex = 1;
//   static const TextStyle optionStyle =
//       TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

//   // List<Widget> widgetOptions = <Widget>[
//   //   CreateBarberScreen(),
//   //   Text(
//   //     'Index 1: ช่างตัดผม',
//   //     style: optionStyle,
//   //   ),
//   //   Text(
//   //     'Index 2: ทรงผม',
//   //     style: optionStyle,
//   //   ),
//   // ];

//   // void _onItemTapped(int index) {
//   //   setState(() {
//   //     _selectedIndex = index;
//   //   });
//   // }

//   StreamBuilder showhaircut() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection("Haircuts").snapshots(),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return Text('Something went wrong');
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Text("Loading");
//         }

//         return Column(
//           children: snapshot.data!.docs.map((DocumentSnapshot document) {
//             Map<String, dynamic> data =
//                 document.data()! as Map<String, dynamic>;
//             print(data['haircut_name']);
//             return ListTile(
//               title: Text(data['haircut_name']),
//               subtitle: Text(data['price'].toString()),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   IconButton(
//                     icon: Icon(
//                       Icons.edit,
//                       color: Colors.blue,
//                     ),
//                     onPressed: () {
//                       showModalBottomSheet(
//                         context: context,
//                         builder: (context) => EditHaircutModal(
//                           docid: document.id,
//                         ),
//                       );
//                     },
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       Icons.delete,
//                       color: Colors.red,
//                     ),
//                     onPressed: () {
//                       QuickAlert.show(
//                         onCancelBtnTap: () {
//                           Navigator.pop(context);
//                         },
//                         onConfirmBtnTap: () {
//                           print("Delete");
//                           deleteHaircut(document.id);
//                           Navigator.pop(context);
//                         },
//                         context: context,
//                         type: QuickAlertType.error,
//                         title: 'ลบข้อมูล!',
//                         text: 'ต้องการลบข้อมูล',
//                         confirmBtnText: 'ตกลง',
//                         cancelBtnText: 'ยกเลิก',
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               // subtitle: Text(data['company']),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("แอปพลิเคชันร้านตัดผม")),
//       body: ListView(
//         shrinkWrap: true,
//         children: [
//           Text("หน้าทรงผม",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

//           // show barbers

//           showhaircut(),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             showModalBottomSheet(
//               context: context,
//               builder: (context) => AddHaircutModal(),
//             );
//           },
//           child: const Icon(Icons.add)),
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
//               title: const Text('ช่างตัดผม'),
//               selected: _selectedIndex == 0,
//               onTap: () {
//                 // Update the state of the app
//                 // _onItemTapped(1);
//                 // Then close the drawer
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => MyHomePage(),
//                     ));
//                 // Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('ทรงผม'),
//               selected: _selectedIndex == 1,
//               onTap: () {
//                 // Update the state of the app
//                 // _onItemTapped(2);
//                 // Then close the drawer
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _addHaircut(String haircut_name, String price) {
//     FirebaseFirestore.instance.collection('Haircuts').add({
//       'haircut_name': haircut_name,
//       'price': price,
//       // เพิ่มฟิลด์อื่น ๆ ตามต้องการ
//     }).then((value) {
//       if (mounted) {}
//     }).catchError((error) {
//       print("เกิดข้อผิดพลาดในการเพิ่มช่างตัดผม: $error");
//     });
//   }

//   void deleteHaircut(String docid) {
//     FirebaseFirestore.instance
//         .collection("Haircuts")
//         .doc(docid)
//         .delete()
//         .then((value) {
//       if (mounted) {}
//     }).catchError((error) {
//       print("เกิดข้อผิดพลาดในการลบช่างตัดผม: $error");
//     });
//   }
// }

// class AddHaircutModal extends StatefulWidget {
//   const AddHaircutModal({Key? key}) : super(key: key);

//   @override
//   _AddHaircutModalState createState() => _AddHaircutModalState();
// }

// class _AddHaircutModalState extends State<AddHaircutModal> {
//   TextEditingController _haircut_nameController = TextEditingController();
//   TextEditingController _priceController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'เพิ่มทรงผม',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           TextField(
//             controller: _haircut_nameController,
//             decoration: InputDecoration(labelText: 'ชื่อทรงผม'),
//           ),
//           TextField(
//             controller: _priceController,
//             decoration: InputDecoration(labelText: 'ราคาทรงผม'),
//           ),
//           SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text('ยกเลิก'),
//               ),
//               SizedBox(width: 8),
//               ElevatedButton(
//                 onPressed: () {
//                   String haircut_name = _haircut_nameController.text.trim();
//                   String price = _priceController.text.trim();
//                   if (haircut_name.isNotEmpty && price.isNotEmpty) {
//                     _HaircutPageState()._addHaircut(haircut_name, price);
//                     Navigator.pop(context);
//                     QuickAlert.show(
//                       context: context,
//                       type: QuickAlertType.success,
//                       title: "สำเร็จ!",
//                       text: 'เพิ่มข้อมูลทรงผมสำเร็จ',
//                       confirmBtnText: 'ตกลง',
//                       confirmBtnColor: Color.fromARGB(255, 28, 221, 14),
//                     );
//                   } else {
//                     // แสดงข้อความเตือนหากข้อมูลไม่ครบ
//                     QuickAlert.show(
//                       context: context,
//                       type: QuickAlertType.error,
//                       title: 'ผิดพลาด!',
//                       text: 'ไม่สามารถเพิ่มข้อมูลได้ กรุณาลองใหม่อีกครั้ง',
//                       confirmBtnText: 'ตกลง',
//                       confirmBtnColor: Color.fromARGB(255, 255, 0, 0),
//                     );
//                   }
//                 },
//                 child: Text('เพิ่ม'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
