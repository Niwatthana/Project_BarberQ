import 'package:barberapp/pages/cutomer/homecutomer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class BookingResults extends StatefulWidget {
  const BookingResults({
    super.key,
    required this.barbershopid,
    required this.barbershopname,
    required this.selectedTime,
    required this.barberid,
    required this.barbername,
    required this.haircut,
    required this.haircutid,
    required this.imgbarber,
    required this.selectedGroup,
    required this.time,
    required this.price,
  });

  final String barbershopname;
  final String barbershopid;
  final String selectedTime;
  final String barberid;
  final String barbername;
  final String haircut;
  final String haircutid;
  final String imgbarber;
  final String? selectedGroup;
  final String time;
  final String price;

  @override
  State<BookingResults> createState() => _BookingResultsState();
}

class _BookingResultsState extends State<BookingResults> {
  bool isBookingInProgress = false; // ตัวแปรสำหรับเช็คสถานะการจอง
  List<String> timeSlots = []; // เก็บช่วงเวลา 30 นาที
  String? customerName; // ตัวแปรสำหรับเก็บชื่อลูกค้า

  @override
  void initState() {
    super.initState();
    _loadCustomerName(); // เรียกฟังก์ชันดึงข้อมูลชื่อเมื่อตอนเริ่มต้น
    print(widget.selectedGroup);
  }

  Future<void> _loadCustomerName() async {
    String name = await _getCustomerName(); // ดึงชื่อจาก Firebase
    setState(() {
      customerName = name; // อัปเดตตัวแปร state เมื่อได้ชื่อ
    });
  }

  Future<String> _getCustomerName() async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();

    if (userSnapshot.exists) {
      return userSnapshot['name']; // สมมติว่าชื่อผู้ใช้เก็บในฟิลด์ 'name'
    } else {
      return 'Unknown'; // กรณีที่ไม่มีข้อมูลชื่อผู้ใช้
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'รายละเอียดการจอง',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildBarberInfo(),
              const SizedBox(height: 20.0),
              _buildBookingDate(),
              const SizedBox(height: 20.0),
              _buildBookingResultss(),
              const SizedBox(height: 20.0),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for displaying barber info (profile picture, name, haircut)
  Widget _buildBarberInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(widget.imgbarber),
        ),
        const SizedBox(width: 16.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.barbername,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(widget.haircut),
          ],
        ),
      ],
    );
  }

  // Widget for displaying the booking date
  Widget _buildBookingDate() {
    final String formattedDate =
        DateFormat('dd MMMM yyyy').format(DateTime.now());
    return Text(
      formattedDate,
      style: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // Widget for displaying booking details
  Widget _buildBookingResultss() {
    String group = widget.selectedGroup ?? '';

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: [
          Text(
            'รายละเอียดการจอง',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),
          Text('ทรงผม: ${widget.haircut}',
              style: const TextStyle(fontSize: 20)),
          Text('ประเภทลูกค้า: $group', style: const TextStyle(fontSize: 20)),
          Text('ราคา: ${widget.price} บาท',
              style: const TextStyle(fontSize: 20)),
          Text('เวลาที่จอง: ${widget.selectedTime} ',
              style: const TextStyle(fontSize: 20)),
          Text('เวลาที่ตัด: ${widget.time} นาที',
              style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  // Widget for displaying the action buttons (Book and Back)
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: isBookingInProgress ? null : _handleBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 15.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text('จอง', style: TextStyle(color: Colors.black)),
        ),
        const SizedBox(width: 20.0),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // กลับไปหน้าก่อนหน้า
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(
              horizontal: 35.0,
              vertical: 15.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('ย้อนกลับ', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  Future<void> _handleBooking() async {
    setState(() {
      isBookingInProgress = true; // ป้องกันการกดปุ่มซ้ำ
    });

    try {
      // ตรวจสอบการจองซ้ำก่อนบันทึก
      bool hasExistingBooking = await _checkExistingBooking();

      if (hasExistingBooking) {
        QuickAlert.show(
          context: context,
          title: 'คำเตือน',
          confirmBtnText: 'ตกลง',
          type: QuickAlertType.warning,
          text:
              'คุณมีการจองแล้วไม่สามารถจองซ้ำได้ กรุณายกเลิกการจองล่าสุดเพื่อดำเนินการจองใหม่!',
          onConfirmBtnTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeCustomer()),
            );
          },
        );
        setState(() {
          isBookingInProgress = false; // เปิดใช้งานปุ่มอีกครั้ง
        });
      } else {
        await _createNewBooking();
      }
    } catch (error) {
      // แสดง error เพื่อดีบัก
      print('Error during booking: $error');
      setState(() {
        isBookingInProgress =
            false; // เปิดใช้งานปุ่มอีกครั้งเมื่อเกิดข้อผิดพลาด
      });

      QuickAlert.show(
        context: context,
        title: 'เกิดข้อผิดพลาด',
        confirmBtnText: 'ตกลง',
        type: QuickAlertType.error,
        text: 'ไม่สามารถทำการจองได้ กรุณาลองใหม่อีกครั้ง',
      );
    }
  }

  Future<bool> _checkExistingBooking() async {
    try {
      QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
          .collection('Bookings')
          .where('barberid', isEqualTo: widget.barberid)
          .where('status', isEqualTo: 'booked')
          .where('selectedTime', isEqualTo: widget.selectedTime)
          .get();

      print('Existing bookings found: ${bookingSnapshot.docs.length}');
      return bookingSnapshot.docs.isNotEmpty;
    } catch (error) {
      print('Error checking existing bookings: $error');
      return false;
    }
  }

  Future<void> _createNewBooking() async {
    try {
      // var uid = FirebaseAuth.instance.currentUser!.uid;
      // String customerName = await _getCustomerName(); // ดึงข้อมูลชื่อลูกค้า
      // DateTime startTime = DateTime.parse(widget.selectedTime);
      // DateTime endTime =
      //     startTime.add(Duration(minutes: int.parse(widget.time)));

      var mytime = widget.selectedTime.split("-");
      var mystarttimestr = mytime[0].toString().trim();
      print(mystarttimestr);
      List<String> startimesplit = mystarttimestr.split(":");
      print(startimesplit);
      DateTime now = DateTime.now();

      TimeOfDay _starttime = TimeOfDay(
          hour: int.parse(startimesplit[0]),
          minute: int.parse(startimesplit[1]));

      TimeOfDay _endtime = TimeOfDay.fromDateTime(DateTime(
              now.year, now.month, now.day, _starttime.hour, _starttime.minute)
          .add(Duration(minutes: 30)));

      DateTime startTime = DateTime(
          now.year, now.month, now.day, _starttime.hour, _starttime.minute);
      DateTime endTime = DateTime(
          now.year, now.month, now.day, _endtime.hour, _endtime.minute);

      Map<String, dynamic> bookingData = {
        'userid': FirebaseFirestore.instance
            .collection("Users")
            .doc(FirebaseAuth.instance.currentUser!.uid),
        'user_id': FirebaseAuth.instance.currentUser!.uid,
        'barbershop_id': widget.barbershopid,
        'barbershopid': FirebaseFirestore.instance
            .collection("BarberShops")
            .doc(widget.barbershopid),
        'barberid': FirebaseFirestore.instance
            .collection("Barbers")
            .doc(widget.barberid),
        'barber_id': widget.barberid,
        'haircutid': FirebaseFirestore.instance
            .collection("Haircuts")
            .doc(widget.haircutid),
        'selectedGroup': widget.selectedGroup,
        'time': widget.time,
        'price': widget.price,
        'status': 'booked',
        'bookingDate': DateFormat.yMMMMd().format(DateTime.now()),
        'startTime': startTime,
        'endTime': endTime,
        'notified': false,
      };

      // แสดงข้อมูลการจองก่อนบันทึก
      // print('Booking data: $bookingData');

      await FirebaseFirestore.instance.collection('Bookings').add(bookingData);

      // setState(() {
      //   isBookingInProgress = false; // ปิดสถานะการจอง
      // });

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'การจองสำเร็จ',
        confirmBtnText: 'ตกลง',
        onConfirmBtnTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeCustomer()),
          );
        },
      );
    } catch (error) {
      // แสดง error เพื่อดีบัก
      print('Error creating booking: $error');
      setState(() {
        isBookingInProgress =
            false; // เปิดใช้งานปุ่มอีกครั้งเมื่อเกิดข้อผิดพลาด
      });

      QuickAlert.show(
        context: context,
        title: 'เกิดข้อผิดพลาด',
        confirmBtnText: 'ตกลง',
        type: QuickAlertType.error,
        text: 'ไม่สามารถบันทึกการจองได้ กรุณาลองใหม่อีกครั้ง',
      );
    }
  }
}
