// Future<Map<String, dynamic>?> getUserData(String barbername) async {
//     var userSnapshot;
//     if (barbername.isEmpty) {
//       userSnapshot = await FirebaseFirestore.instance
//           .collection('Barbers')
//           .where("status", isEqualTo: false)
//           .orderBy("name", descending: false)
//           .get();
//     } else {
//       userSnapshot = await FirebaseFirestore.instance
//           .collection('Barbers')
//           .where("name", isLessThan: barbername)
//           .where("status", isEqualTo: false)
//           .orderBy("name", descending: false)
//           .get();
//     }

//     print(userSnapshot.docs);
//     setState(() {
//       barberList = [];
//     });

//     userSnapshot.docs.forEach(
//       (mydoc) {
//         print(mydoc.data());
//         setState(() {
//           barberList.add(mydoc.data());
//         });
//       },
//     );

//     return null;
  