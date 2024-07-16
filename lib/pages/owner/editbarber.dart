// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:quickalert/models/quickalert_type.dart';
// import 'package:quickalert/widgets/quickalert_dialog.dart';

// class EditBarberModal extends StatefulWidget {
//   const EditBarberModal({super.key, required this.docid});

//   final String docid;

//   @override
//   State<EditBarberModal> createState() => _EditBarberModalState();
// }

// class _EditBarberModalState extends State<EditBarberModal> {
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

//   FirebaseFirestore firestore = FirebaseFirestore.instance;

//   @override
//   void initState() {
//     super.initState();
//     getBarber();
//   }

//   void getBarber() async {
//     DocumentSnapshot<Map<String, dynamic>> barber =
//         await firestore.collection("Barbers").doc(widget.docid).get();

//     var data = barber.data();
//     List<String> haircut = [];
//     for (var hair in data!['haircut']) {
//       haircut.add(hair);
//     }
//     setState(() {
//       _nameController.text = data['name'];
//       _telController.text = data['tel'];
//       haircut_checked = haircut;
//     });
//   }

//   void _editBarber() {
//     print(haircut_checked);
//     FirebaseFirestore.instance.collection('Barbers').doc(widget.docid).set({
//       'name': _nameController.text,
//       'tel': _telController.text,
//       'haircut': FieldValue.arrayUnion(haircut_checked),
//     }).then((value) {
//       if (mounted) {}
//     }).catchError((error) {
//       print("เกิดข้อผิดพลาดในการแก้ไขช่างตัดผม: $error");
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     //ตรวจสถานะ
//     // final TextTheme textTheme = Theme.of(context).textTheme;
//     return Padding(
//       padding: EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'แก้ไขช่างตัดผม',
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
//                   String name = _nameController.text.trim();
//                   String tel = _telController.text.trim();
//                   if (name.isNotEmpty && tel.isNotEmpty) {
//                     // แก้ไข
//                     // _MyHomePageState()._addBarber(name, tel);
//                     _editBarber();

//                     Navigator.pop(context);
//                     QuickAlert.show(
//                       context: context,
//                       type: QuickAlertType.success,
//                       title: "สำเร็จ!",
//                       text: 'แก้ไขข้อมูลช่างตัดผมสำเร็จ',
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
//                 child: Text('แก้ไข'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
