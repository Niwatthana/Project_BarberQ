import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart'; // สำหรับการจัดรูปแบบวันที่

class BookingHistory extends StatefulWidget {
  const BookingHistory({super.key});

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  List historyBooking = [];

  // Future<List<DocumentSnapshot>> _fetchBookings() async {
  //   try {
  //     // Get the current user's ID
  //     String userid = FirebaseAuth.instance.currentUser!.uid;

  //     // Fetch the bookings for the specific user
  //     var querySnapshot = await FirebaseFirestore.instance
  //         .collection("Bookings")
  //         .where("user_id", isEqualTo: userid) // Filter by userId
  //         .get();

  //     // print('>>>>>>$userid');

  //     return querySnapshot.docs; // Return the list of booking documents
  //   } catch (e) {
  //     print('Error fetching bookings: $e');
  //     return [];
  //   }
  // }

  Future<void> _fetchData() async {
    try {
      String userid = FirebaseAuth.instance.currentUser!.uid;

      // Fetch the bookings for the specific user
      var bookingSnapshot = await FirebaseFirestore.instance
          .collection("Bookings")
          .where("user_id", isEqualTo: userid) // Filter by userId
          .get();

      // print(bookingSnapshot.size);
      List<DocumentSnapshot> bookingDoc = bookingSnapshot.docs;

      bookingDoc.map(
        (doc) async {
          // print(doc.id);
          var bookingdata = doc.data() as Map<String, dynamic>;
          // print(bookingdata['barberid']);

          // BarberShop
          // print("barbershop-----");
          DocumentSnapshot<Map<String, dynamic>> barbershopSnapshot =
              await bookingdata['barbershopid'].get();

          var shopdata = barbershopSnapshot.data() as Map<String, dynamic>;
          // print(shopdata['shop_name']);

          // Barber
          // print("barber");
          DocumentSnapshot<Map<String, dynamic>> barberSnapshot =
              await bookingdata['barberid'].get();
          var barberdata = barberSnapshot.data() as Map<String, dynamic>;
          // print(barberdata['imageUrl']);

          // print(barberdata['barber_id1']);

          // User
          // print("user");
          DocumentSnapshot<Map<String, dynamic>> userSnapshot =
              await barberdata['barber_id1'].get();
          var userdata = userSnapshot.data() as Map<String, dynamic>;
          // print(userdata['name']);

          setState(() {
            historyBooking.add({
              "booking": bookingdata,
              "barbershop": shopdata,
              "barber": barberdata,
              "user": userdata,
              "docId": doc.id
            });
            historyBooking.sort((a, b) {
              var aDate = a["booking"]["startTime"].toDate();
              var bDate = b["booking"]["startTime"].toDate();
              return bDate.compareTo(aDate);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการจอง'),
      ),
      body: ListView.builder(
        itemCount: historyBooking.length,
        itemBuilder: (context, index) {
          // print(historyBooking[index]);

          Map<String, dynamic> booking = historyBooking[index]["booking"];
          Map<String, dynamic> barbershop = historyBooking[index]["barbershop"];
          Map<String, dynamic> barber = historyBooking[index]["barber"];
          Map<String, dynamic> user = historyBooking[index]["user"];

          // var bookingDate =
          //     DateFormat.yMMMMd("th").format(booking['startTime'].toDate());
          // print(bookingDate);

          var bookingDate =
              DateFormat.yMMMMd("th").format(booking['startTime'].toDate());
          var dateTime = booking['startTime'].toDate();
          var yearInBuddhistEra = dateTime.year + 543;

          var formattedDate = bookingDate.replaceAll(
              (dateTime.year).toString(), yearInBuddhistEra.toString());

          var startTime = DateFormat.Hm().format(booking['startTime'].toDate());
          var endTime = DateFormat.Hm().format(booking['endTime'].toDate());

          var bookingStatus = booking['status'] == "booked"
              ? "จอง"
              : booking['status'] == 'cancelled'
                  ? 'ยกเลิก'
                  : 'เสร็จสิ้น';

          return Card(
            margin: const EdgeInsets.all(10.0),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barber name
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(barber['imageUrl']),
                        radius: 30,
                      ),
                      const SizedBox(width: 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'] ?? 'ไม่พบชื่อช่างตัดผม',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            barbershop['shop_name'] ?? 'ไม่พบชื่อร้าน',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  // Booking date
                  Text(
                    'วันที่จอง: $formattedDate',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5.0),

                  // Time and selected time slot
                  Text(
                    'เวลาที่จอง: $startTime - $endTime น.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5.0),

                  // Booking date
                  Text(
                    'สถานะ: $bookingStatus',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5.0),
                  (booking['status'] == 'cancelled' ||
                          booking['status'] == 'done')
                      ? SizedBox.shrink() // ซ่อนปุ่มเมื่อยกเลิกแล้ว
                      : ElevatedButton(
                          onPressed: booking['status'] == 'cancelled'
                              ? null // ปิดการใช้งานปุ่มถ้าการจองถูกยกเลิกแล้ว
                              : () async {
                                  DateTime now = DateTime.now();
                                  DateTime bookingStartTime =
                                      booking['startTime'].toDate();
                                  Duration timeDifference =
                                      bookingStartTime.difference(now);

                                  // Check if the booking is within 30 minutes
                                  if (timeDifference.inMinutes <= 30) {
                                    QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.warning,
                                        title: 'ไม่สามารถยกเลิกได้',
                                        text:
                                            'ใกล้ถึงคิวตัดผมของคุณแล้ว ไม่สามารถยกเลิกได้!!',
                                        confirmBtnText: 'ตกลง');
                                  } else {
                                    // Show confirmation dialog with QuickAlert
                                    QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.confirm,
                                      title: 'ยืนยันการยกเลิก',
                                      text: 'คุณจะยกเลิกการจองคิวใช่หรือไม่?',
                                      confirmBtnText: 'ตกลง',
                                      cancelBtnText: 'ยกเลิก',
                                      onConfirmBtnTap: () async {
                                        try {
                                          // Cancel the booking
                                          await FirebaseFirestore.instance
                                              .collection('Bookings')
                                              .doc(historyBooking[index][
                                                  "docId"]) // Reference correct booking
                                              .update({'status': 'cancelled'});
                                          print(
                                              "Updating booking ID: ${historyBooking[index]["docId"]}");

                                          setState(() {
                                            booking['status'] =
                                                'cancelled'; // Update booking status
                                          });

                                          Future.delayed(
                                              Duration(milliseconds: 1), () {
                                            Navigator.of(context)
                                                .pop(); // Close QuickAlert
                                          });
                                        } catch (e) {
                                          print('Error updating booking: $e');
                                        }
                                      },
                                      onCancelBtnTap: () {
                                        Navigator.of(context)
                                            .pop(); // Close QuickAlert if cancelled
                                      },
                                    );
                                  }
                                },
                          child: Text(booking['status'] == 'cancelled'
                              ? 'ยกเลิกแล้ว'
                              : 'ยกเลิก'),
                        )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
