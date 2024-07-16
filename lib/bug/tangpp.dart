// import 'package:flutter/material.dart';

// class OwnerEmployee extends StatefulWidget {
//   const OwnerEmployee({super.key});

//   @override
//   State<OwnerEmployee> createState() => _OwnerEmployeeState();
// }

// class _OwnerEmployeeState extends State<OwnerEmployee> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // Background color
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text('ข้อมูลช่างตัดผม'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context); // Navigate back when pressed
//           },
//         ),
//       ),
//       body: Center(
//         child: Container(
//           width: 350, // Adjust the width as needed
//           padding: const EdgeInsets.all(17.0),
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(17.0),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'ชื่อช่าง',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Add action for the button
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text('เพิ่ม',
//                         style: TextStyle(color: Colors.white)),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(8.0),
//                 color: Colors.black,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: const [
//                     Text(
//                       'ช่างสุดหล่อ',
//                       style: TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                     Text(
//                       '068-642-xxxx',
//                       style: TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'รายละเอียดช่าง',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.all(8.0),
//                 color: Colors.black,
//                 child: const Text(
//                   'ความสามารถของช่างหรอที่สามารถติดต่อได้ใช้เวลานานโทรไปกี่ครั้งหรอผมอะไรมั้งและสามารถติดต่อช่างหรออะไรได้บ้าง',
//                   style: TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       // Add action for the button
//                     },
//                     style: ElevatedButton.styleFrom(
//                       primary: Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                     child: const Text('ตกลง',
//                         style: TextStyle(color: Colors.white)),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Add action for the button
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                     child: const Text('ยกเลิก',
//                         style: TextStyle(color: Colors.white)),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
