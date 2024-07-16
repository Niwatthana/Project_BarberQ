// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:quickalert/models/quickalert_type.dart';
// import 'package:quickalert/widgets/quickalert_dialog.dart';

// class EditHaircutModal extends StatefulWidget {
//   const EditHaircutModal({super.key, required this.docid});

//   final String docid;

//   @override
//   State<EditHaircutModal> createState() => _EditHaircutModalState();
// }

// class _EditHaircutModalState extends State<EditHaircutModal> {
//   TextEditingController _haircut_nameController = TextEditingController();
//   TextEditingController _priceController = TextEditingController();

//   FirebaseFirestore firestore = FirebaseFirestore.instance;

//   getHaircut() async {
//     DocumentSnapshot<Map<String, dynamic>> barber =
//         await firestore.collection("Haircuts").doc(widget.docid).get();

//     var data = barber.data();
//     setState(() {
//       _haircut_nameController.text = data!['haircut_name'];
//       _priceController.text = data['price'];
//     });
//   }

//   void _editHaircut() {
//     FirebaseFirestore.instance.collection('Haircuts').doc(widget.docid).update({
//       'haircut_name': _haircut_nameController.text,
//       'price': _priceController.text,

//       // เพิ่มฟิลด์อื่น ๆ ตามต้องการ
//     }).then((value) {
//       if (mounted) {}
//     }).catchError((error) {
//       print("เกิดข้อผิดพลาดในการแก้ไขทรงผม: $error");
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     getHaircut();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'แก้ไขทรงผม',
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
//                   int price = int.tryParse(_priceController.text) ?? 0;
//                   if (haircut_name.isNotEmpty && price != null) {
//                     // แก้ไข
//                     _editHaircut();

//                     Navigator.pop(context);
//                     QuickAlert.show(
//                       context: context,
//                       type: QuickAlertType.success,
//                       title: "สำเร็จ!",
//                       text: 'แก้ไขข้อมูลทรงผมสำเร็จ',
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
