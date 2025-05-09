import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BarberBookingHistoryPage extends StatefulWidget {
  const BarberBookingHistoryPage({super.key});

  @override
  State<BarberBookingHistoryPage> createState() =>
      _BarberBookingHistoryPageState();
}

class _BarberBookingHistoryPageState extends State<BarberBookingHistoryPage> {
  List bookingUser = [];

  // State variables for dropdown selections
  String? selectedMonth;
  String? selectedYear;

  // Lists for dropdowns
  List<String> months = List.generate(12, (index) => (index + 1).toString());
  List<String> years =
      List.generate(10, (index) => (DateTime.now().year - index).toString());

  Future<void> _fetchData() async {
    try {
      String barberid = FirebaseAuth.instance.currentUser!.uid;

      // Fetch the bookings for the specific user
      var bookingSnapshot = await FirebaseFirestore.instance
          .collection("Bookings")
          .where("barber_id", isEqualTo: barberid) // Filter by userId
          .orderBy("startTime", descending: true)
          .get();

      print(bookingSnapshot.size);
      List<DocumentSnapshot> bookings = bookingSnapshot.docs;

      setState(() {
        bookingUser = [];
      });

      bookings.map(
        (doc) async {
          var bookingdata = doc.data() as Map<String, dynamic>;
          // User
          DocumentSnapshot<Map<String, dynamic>> userSnapshot =
              await bookingdata['userid'].get();
          var userdata = userSnapshot.data() as Map<String, dynamic>;

          // Haircut
          DocumentSnapshot<Map<String, dynamic>> haircutSnapshot =
              await bookingdata['haircutid'].get();
          var haircutdata = haircutSnapshot.data() as Map<String, dynamic>;

          setState(() {
            bookingUser.add({
              "bookingId": doc.id,
              "booking": bookingdata,
              "user": userdata,
              "hair": haircutdata
            });
            bookingUser.sort((a, b) {
              var aDate = a["booking"]["startTime"].toDate();
              var bDate = b["booking"]["startTime"].toDate();
              return bDate.compareTo(aDate); // เรียงจากน้อยไปมาก
            });
          });
        },
      ).toList();
    } catch (e) {
      print('Error fetching bookings: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ประวัติการจองทั้งหมด"),
      ),
      body: bookingUser.isEmpty
          ? Center(child: Text("ยังไม่มีข้อมูลประวัติการจอง"))
          : ListView.builder(
              itemCount: bookingUser.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> bookings = bookingUser[index]["booking"];
                Map<String, dynamic> user = bookingUser[index]["user"];
                Map<String, dynamic> hair = bookingUser[index]["hair"];

                // ใช้ DateFormat "d MMMM y" เพื่อเรียงวัน/เดือน/ปี
                var dateTime = bookings['startTime'].toDate();
                var bookingDate = DateFormat("d MMMM y", "th").format(dateTime);

                // แปลงปีเป็นพุทธศักราช
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
                  ),
                );
              },
            ),
    );
  }
}
