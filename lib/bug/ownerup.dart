// import 'package:barberapp/pages/cutomer/owner/editbarber.dart';
// import 'package:barberapp/pages/cutomer/owner/haircut.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:quickalert/quickalert.dart';

// void main() => runApp(const MyHomePage());

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _selectedIndex = 0;

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

//   StreamBuilder showBarber() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection("Barbers").snapshots(),
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
//             print(data['name']);
//             return ListTile(
//               title: Text(data['name']),
//               subtitle: Text(data['tel']),
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
//                         builder: (context) => EditBarberModal(
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
//                           deleteBarber(document.id);
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
//       appBar: AppBar(
//         title: const Text("Menu"),
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(
//                 Icons.account_circle), // Replace with your user picture icon
//             onPressed: () {
//               // Add your action here
//             },
//           ),
//         ],
//       ),
//       body: ListView(
//         shrinkWrap: true,
//         children: [
//           Text("หน้าช่างตัดผม",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             showModalBottomSheet(
//               context: context,
//               builder: (context) => AddBarberModal(),
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
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('ทรงผม'),
//               selected: _selectedIndex == 1,
//               onTap: () {
//                 // Update the state of the app
//                 // _onItemTapped(2);
//                 // Then close the drawer
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => HaircutPage(),
//                     ));
//                 // Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _addBarber(String name, String tel, List<String> haircut_checked) {
//     print(haircut_checked.toList());
//     FirebaseFirestore.instance.collection('Barbers').add({
//       'name': name,
//       'tel': tel,
//       'haircut': FieldValue.arrayUnion(haircut_checked.toList()),
//       // เพิ่มฟิลด์อื่น ๆ ตามต้องการ
//     }).then((value) {
//       if (mounted) {}
//     }).catchError((error) {
//       print("เกิดข้อผิดพลาดในการเพิ่มช่างตัดผม: $error");
//     });
//   }

//   void deleteBarber(String docid) {
//     FirebaseFirestore.instance
//         .collection("Barbers")
//         .doc(docid)
//         .delete()
//         .then((value) {
//       if (mounted) {}
//     }).catchError((error) {
//       print("เกิดข้อผิดพลาดในการลบช่างตัดผม: $error");
//     });
//   }
// }

// class AddBarberModal extends StatefulWidget {
//   const AddBarberModal({Key? key}) : super(key: key);

//   @override
//   _AddBarberModalState createState() => _AddBarberModalState();
// }

// class _AddBarberModalState extends State<AddBarberModal> {
//   TextEditingController _nameController = TextEditingController();
//   TextEditingController _telController = TextEditingController();
//   final List<String> _haircut = [
//     "สกินเฮด",
//     "ทรงนักเรียน",
//     "ทูบล็อก",
//     "ทรงมัลเล็ต",
//     "ทรงอันเดอร์คัต",
//   ];
//   List<String> haircut_checked = <String>[];

//   @override
//   Widget build(BuildContext context) {
//     //final TextTheme textTheme = Theme.of(context).textTheme;
//     return Padding(
//       padding: EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'เพิ่มช่างตัดผม',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           TextField(
//             controller: _nameController,
//             decoration: InputDecoration(labelText: 'ชื่อช่างตัดผม'),
//           ),
//           TextField(
//             controller: _telController,
//             keyboardType: TextInputType.phone,
//             decoration: InputDecoration(labelText: 'เบอร์โทรศัพท์'),
//           ),
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               // Text('Choose an haircut', style: textTheme.labelLarge),
//               const SizedBox(height: 5.0),
//               Wrap(
//                 spacing: 5.0,
//                 children: _haircut.map((hc) {
//                   return FilterChip(
//                     label: Text(hc),
//                     selected: haircut_checked.contains(hc),
//                     onSelected: (bool selected) {
//                       setState(() {
//                         if (selected) {
//                           haircut_checked.add(hc);
//                         } else {
//                           haircut_checked.remove(hc);
//                         }
//                       });
//                     },
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 10.0),
//               // แสดงผลลัพธ์ว่า เชคอะไรไปแล้วบ้าง
//               // Text(
//               //   'Looking for: ${haircut_checked.map((String e) => e).join(', ')}',
//               //   style: textTheme.labelLarge,
//               // ),
//             ],
//           ),
//           SizedBox(height: 5),
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
//                   String name = _nameController.text.trim();
//                   String tel = _telController.text.trim();
//                   String haircut_name = _telController.text.trim();
//                   if (name.isNotEmpty &&
//                       tel.isNotEmpty &&
//                       haircut_name.isNotEmpty) {
//                     _MyHomePageState()._addBarber(name, tel, haircut_checked);
//                     Navigator.pop(context);
//                     QuickAlert.show(
//                       context: context,
//                       type: QuickAlertType.success,
//                       title: 'สำเร็จ',
//                       text: 'เพิ่มข้อมูลช่างตัดผมสำเร็จ',
//                       confirmBtnText: 'ตกลง',
//                       confirmBtnColor: Color.fromARGB(255, 28, 221, 14),
//                     );
//                   } else {
//                     // แสดงข้อความเตือนหากข้อมูลไม่ครบ
//                     QuickAlert.show(
//                       context: context,
//                       type: QuickAlertType.error,
//                       title: 'ผิดพลาด',
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
