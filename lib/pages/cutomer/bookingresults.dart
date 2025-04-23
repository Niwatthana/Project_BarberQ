import 'package:barberapp/pages/cutomer/homecutomer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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
  bool isLoading = true; // ข้อ 2: Loading State

  final Color primaryColor = Color(0xFF1B4B4B); // สีหลัก (เขียวเข้ม)
  final Color accentColor = Colors.redAccent; // สีรอง (แดง)

  @override
  void initState() {
    super.initState();
    _loadCustomerName().then((_) => setState(
        () => isLoading = false)); // เรียกฟังก์ชันดึงข้อมูลชื่อเมื่อตอนเริ่มต้น
    print(widget.selectedGroup);
  }

  Future<void> _loadCustomerName() async {
    try {
      String name = await _getCustomerName(); // ดึงชื่อจาก Firebase
      setState(() {
        customerName = name; // อัปเดตตัวแปร state เมื่อได้ชื่อ
      });
    } catch (e) {
      // ข้อ 8: Error Handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<String> _getCustomerName() async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();

    if (userSnapshot.exists) {
      return userSnapshot['name'] ?? 'Unknown'; // กรณีที่ไม่มีข้อมูลชื่อผู้ใช้
    } else {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ข้อ 9: Gradient Background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, Colors.blueGrey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: accentColor)) // ข้อ 2: Loading
                  : AnimationLimiter(
                      // ข้อ 11: Animation
                      child: Container(
                        margin: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white, // ข้อ 3: Card Design
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ข้อ 10: Custom AppBar (ไม่ใช้ PopupMenuButton)
                              AppBar(
                                leading: IconButton(
                                  icon: Icon(Icons.arrow_back,
                                      color: Colors.black),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                elevation: 0,
                                centerTitle: true,
                                title: Text(
                                  'รายละเอียดการจอง',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                backgroundColor: Colors.transparent,
                                flexibleSpace: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [primaryColor, Colors.teal],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20.0),
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
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget for displaying barber info (profile picture, name, haircut)
  Widget _buildBarberInfo() {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(widget.imgbarber),
                onBackgroundImageError: (exception, stackTrace) => Icon(
                    Icons.person,
                    color: Colors.grey[600]), // ข้อ 5: Handle image error
              ),
              const SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.barbername,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // ข้อ 4: Typography
                    ),
                  ),
                  Text(
                    widget.haircut,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600], // ข้อ 4: Typography
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for displaying the booking date
  Widget _buildBookingDate() {
    final String formattedDate =
        DateFormat('dd MMMM yyyy').format(DateTime.now());
    return AnimationConfiguration.staggeredList(
      position: 1,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Text(
            formattedDate,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black87, // ข้อ 4: Typography
            ),
          ),
        ),
      ),
    );
  }

  // Widget for displaying booking details
  Widget _buildBookingResultss() {
    String group = widget.selectedGroup ?? '';

    return AnimationConfiguration.staggeredList(
      position: 2,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white, // ข้อ 3: Card Design
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'รายละเอียดการจอง',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // ข้อ 4: Typography
                  ),
                ),
                const SizedBox(height: 10.0),
                Text('ทรงผม: ${widget.haircut}',
                    style: TextStyle(fontSize: 20, color: Colors.black87)),
                Text('ประเภทลูกค้า: $group',
                    style: TextStyle(fontSize: 20, color: Colors.black87)),
                Text('ราคา: ${widget.price} บาท',
                    style: TextStyle(fontSize: 20, color: Colors.black87)),
                Text('เวลาที่จอง: ${widget.selectedTime}',
                    style: TextStyle(fontSize: 20, color: Colors.black87)),
                Text('เวลาที่ตัด: ${widget.time} นาที',
                    style: TextStyle(fontSize: 20, color: Colors.black87)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget for displaying the action buttons (Book and Back)
  Widget _buildActionButtons() {
    return AnimationConfiguration.staggeredList(
      position: 3,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: isBookingInProgress ? null : _handleBooking,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Colors.green, // ปรับเป็นสีเขียว (ยังคงไว้ตามต้นฉบับ)
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('จอง',
                    style: TextStyle(color: Colors.white)), // ข้อ 4: Typography
              ),
              const SizedBox(width: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // กลับไปหน้าก่อนหน้า
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      accentColor, // ข้อ 1: Theme Color (ปรับสีปุ่มเป็น accentColor)
                  padding: const EdgeInsets.symmetric(
                      horizontal: 35.0, vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('ย้อนกลับ',
                    style: TextStyle(color: Colors.white)), // ข้อ 4: Typography
              ),
            ],
          ),
        ),
      ),
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
          confirmBtnColor: accentColor, // ปปรับสีปุ่มใน QuickAlert
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
        confirmBtnColor: accentColor, // ปปรับสีปุ่มใน QuickAlert
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
      var mytime = widget.selectedTime.split("-");
      var mystarttimestr = mytime[0].toString().trim();
      List<String> startimesplit = mystarttimestr.split(":");
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

      await FirebaseFirestore.instance.collection('Bookings').add(bookingData);

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'การจองสำเร็จ',
        confirmBtnText: 'ตกลง',
        confirmBtnColor: accentColor, // ปปรับสีปุ่มใน QuickAlert
        onConfirmBtnTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeCustomer()),
          );
        },
      );
    } catch (error) {
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
        confirmBtnColor: accentColor, // ปปรับสีปุ่มใน QuickAlert
      );
    }
  }
}
