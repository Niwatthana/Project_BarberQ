import 'package:barberapp/pages/barber/barber_bookinghistory.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';

class OwnerBookingUser extends StatefulWidget {
  const OwnerBookingUser({super.key});

  @override
  State<OwnerBookingUser> createState() => _OwnerBookingUserState();
}

class _OwnerBookingUserState extends State<OwnerBookingUser> {
  List bookingUser = [];

  Future<void> _fetchData() async {
    try {
      String barberid = FirebaseAuth.instance.currentUser!.uid;

      // Fetch the bookings for the specific user
      var bookingSnapshot = await FirebaseFirestore.instance
          .collection("Bookings")
          .where("barber_id", isEqualTo: barberid) // Filter by userId
          .where('bookingDate',
              isEqualTo: DateFormat.yMMMMd().format(DateTime.now()))
          .orderBy("startTime", descending: true)
          .get();

      print(bookingSnapshot.size);
      List<DocumentSnapshot> bookings = bookingSnapshot.docs;

      setState(() {
        bookingUser = [];
      });

      bookings.map(
        (doc) async {
          // print(doc.id);
          var bookingdata = doc.data() as Map<String, dynamic>;
          // User
          DocumentSnapshot<Map<String, dynamic>> userSnapshot =
              await bookingdata['userid'].get();
          var userdata = userSnapshot.data() as Map<String, dynamic>;

          // Haircut
          DocumentSnapshot<Map<String, dynamic>> haircutSnapshot =
              await bookingdata['haircutid'].get();
          var haircutdata = haircutSnapshot.data() as Map<String, dynamic>;

          // print(userdata);
          // print(haircutdata);

          setState(() {
            bookingUser.add({
              "bookingId": doc.id,
              "booking": bookingdata,
              "user": userdata,
              "hair": haircutdata
            });
          });
        },
      ).toList();

      // ----------------
    } catch (e) {
      print('Error fetching bookings: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // ฟังก์ชันในการอัปเดตสถานะของการจอง
  Future<void> _updateBookingStatus(String bookingId) async {
    await FirebaseFirestore.instance
        .collection('Bookings')
        .doc(bookingId)
        .update({'status': 'done'});
  }

  // ฟังก์ชันสำหรับการยืนยันก่อนอัปเดตสถานะ
  void _confirmCompletion(String bookingId) {
    print(bookingId);

    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'ยืนยัน',
      text: 'ท่านตัดเสร็จแล้วใช่ไหม?',
      confirmBtnText: 'ตกลง',
      cancelBtnText: 'ยกเลิก',
      confirmBtnColor: Colors.green,
      onConfirmBtnTap: () {
        _updateBookingStatus(bookingId); // อัปเดตสถานะการจอง
        _fetchData();
        Navigator.of(context).pop(); // ปิด dialog
      },
      onCancelBtnTap: () {
        Navigator.of(context).pop(); // ปิด dialog
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายการจองคิววันนี้"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const BarberBookingHistoryPage()), // ไปยังหน้าประวัติการตัดผม
              );
            },
          ),
        ],
      ),
      body: bookingUser.isEmpty
          ? Center(child: Text("ยังไม่มีข้อมูลการจองของวันนี้"))
          : ListView.builder(
              itemCount: bookingUser.length,
              itemBuilder: (context, index) {
                // print(bookingUser);

                String bookingId = bookingUser[index]["bookingId"];
                Map<String, dynamic> bookings = bookingUser[index]["booking"];
                Map<String, dynamic> user = bookingUser[index]["user"];
                Map<String, dynamic> hair = bookingUser[index]["hair"];

                var bookingDate = DateFormat.yMMMMd("th")
                    .format(bookings['startTime'].toDate());
                var dateTime = bookings['startTime'].toDate();
                var yearInBuddhistEra = dateTime.year + 543;

                var formattedDate = bookingDate.replaceAll(
                    (dateTime.year).toString(), yearInBuddhistEra.toString());

                var startTime =
                    DateFormat.Hm().format(bookings['startTime'].toDate());
                var endTime =
                    DateFormat.Hm().format(bookings['endTime'].toDate());

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    title: Text('ชื่อคนจอง: ${user['name']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('เบอร์โทรศัพท์: ${user['tel']}'),
                        Text('วันที่จอง: $formattedDate'),
                        Text('เวลาที่จอง: $startTime - $endTime น.'),
                        Text('ทรงผม: ${hair['haircut_name']}'),
                        Text(
                            'สถานะ: ${bookings['status'] == 'booked' ? 'จอง' : bookings['status'] == 'cancelled' ? 'ยกเลิก' : 'เสร็จแล้ว'}'),
                      ],
                    ),
                    trailing: bookings['status'] == 'done'
                        ? const Icon(Icons.check, color: Colors.green)
                        : bookings['status'] == 'cancelled'
                            ? const Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  _confirmCompletion(
                                      bookingId); // เรียกฟังก์ชันยืนยัน
                                },
                                child: const Text('ตัดเสร็จแล้ว'),
                              ),
                  ),
                );
              },
            ),
    );
  }
}

// //---------------------------------------------------
// class HaircutHistoryPage extends StatelessWidget {
//   const HaircutHistoryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     User? currentUser = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("ประวัติการตัดผม"),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('Bookings')
//             .where("barberid", isEqualTo: currentUser!.uid)
//             .where("status", isEqualTo: 'สำเร็จ') // กรองเฉพาะที่สถานะเป็นสำเร็จ
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           List bookingUsers = [];

//           if (bookingUsers.isEmpty) {
//             return const Center(
//               child: Text(
//                 'ไม่มีประวัติการตัดผม',
//                 style: TextStyle(fontSize: 20),
//               ),
//             );
//           }

//           return ListView.builder(
//             itemCount: bookingUsers.length,
//             itemBuilder: (context, index) {
//               print(bookingUsers);

//               String bookingId = bookingUsers[index]["bookingId"];
//               Map<String, dynamic> bookings = bookingUsers[index]["booking"];
//               Map<String, dynamic> barbershop =
//                   bookingUsers[index]["barbershop"];
//               Map<String, dynamic> barber = bookingUsers[index]["barber"];
//               Map<String, dynamic> user = bookingUsers[index]["user"];
//               Map<String, dynamic> hair = bookingUsers[index]["hair"];

//               return Card(
//                 margin:
//                     const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//                 child: ListTile(
//                   leading: Image.network(bookings['imgbarber'],
//                       width: 50, height: 50),
//                   title: Text('ชื่อช่าง: ${bookings['barbername']}'),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Text('ชื่อร้าน: ${bookingss['barbershopname']}'),
//                       // Text('ทรงผม: ${booking['haircut']}'),
//                       // Text('เวลาที่ตัด: ${booking['selectedTime']}'),
//                       // Text('ราคา: ${booking['price']}'),
//                       Text('สถานะ: สำเร็จ'),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
