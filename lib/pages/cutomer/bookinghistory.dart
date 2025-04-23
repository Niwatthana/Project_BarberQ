import 'package:barberapp/loginpage.dart';
import 'package:barberapp/pages/cutomer/bookingshop.dart';
import 'package:barberapp/pages/cutomer/homecutomer.dart';
import 'package:barberapp/pages/cutomer/profilecutomer.dart';
import 'package:barberapp/pages/cutomer/seebookingshop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class BookingHistory extends StatefulWidget {
  const BookingHistory({super.key});

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  List historyBooking = [];
  bool isLoading = true;
  bool hasError = false;
  bool hasExistingBooking = false; // เพิ่มตัวแปรนี้
  final Color primaryColor = Color(0xFF1B4B4B);
  final Color accentColor = Colors.redAccent;
  int _selectedIndex = 1; // เปลี่ยนเป็น 1 (ประวัติ) แทน 4 (Account)

  @override
  void initState() {
    super.initState();
    _fetchData();
    checkExistingBooking(); // เรียกฟังก์ชันตรวจสอบการจอง
  }

  Future<void> _fetchData() async {
    try {
      String userid = FirebaseAuth.instance.currentUser!.uid;

      var bookingSnapshot = await FirebaseFirestore.instance
          .collection("Bookings")
          .where("user_id", isEqualTo: userid)
          .get();

      List<DocumentSnapshot> bookingDoc = bookingSnapshot.docs;

      List<Future> futures = bookingDoc.map((doc) async {
        var bookingdata = doc.data() as Map<String, dynamic>;

        DocumentSnapshot<Map<String, dynamic>> barbershopSnapshot =
            await bookingdata['barbershopid'].get();
        var shopdata = barbershopSnapshot.data() as Map<String, dynamic>;

        DocumentSnapshot<Map<String, dynamic>> barberSnapshot =
            await bookingdata['barberid'].get();
        var barberdata = barberSnapshot.data() as Map<String, dynamic>;

        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await barberdata['barber_id1'].get();
        var userdata = userSnapshot.data() as Map<String, dynamic>;

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
      }).toList();

      await Future.wait(futures);
    } catch (e) {
      setState(() {
        hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkExistingBooking() async {
    try {
      String userid = FirebaseAuth.instance.currentUser!.uid;
      var bookingSnapshot = await FirebaseFirestore.instance
          .collection('Bookings')
          .where('user_id', isEqualTo: userid)
          .where('status', isEqualTo: 'booked')
          .get();

      setState(() {
        hasExistingBooking = bookingSnapshot.docs.isNotEmpty;
      });
    } catch (e) {
      print('Error checking existing booking: $e');
      setState(() {
        hasExistingBooking = false;
      });
    }
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('ออกจากระบบ', style: TextStyle(color: accentColor)),
          content: Text('คุณต้องการออกจากระบบหรือไม่?',
              style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('ตกลง', style: TextStyle(color: Colors.green)),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0: // หน้าหลักนะจ๊ะ
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeCustomer()));
        break;
      case 1: // แน่นอนต่อๆกันไปอย่างง
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BookingHistory()));
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BookingShop()));
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SeeBookingShop()));
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CutomerProfile(docid: FirebaseAuth.instance.currentUser!.uid),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, Colors.blueGrey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: Text('ประวัติการจอง',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, Colors.teal],
                    ),
                  ),
                ),
                actions: <Widget>[
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.account_circle),
                    onSelected: (String result) {
                      switch (result) {
                        case 'history':
                          // อยู่หน้า BookingHistory อยู่แล้ว ไม่ต้อง push ซ้ำ
                          break;
                        case 'logout':
                          showLogoutDialog(context);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                          value: 'history', child: Text('ประวัติของฉัน')),
                      const PopupMenuItem<String>(
                          value: 'logout', child: Text('ออกจากระบบ')),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: accentColor))
                      : hasError
                          ? Center(
                              child: Text('ไม่สามารถโหลดข้อมูลได้',
                                  style: TextStyle(color: Colors.black87)))
                          : AnimationLimiter(
                              child: ListView.builder(
                                itemCount: historyBooking.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> booking =
                                      historyBooking[index]["booking"];
                                  Map<String, dynamic> barbershop =
                                      historyBooking[index]["barbershop"];
                                  Map<String, dynamic> barber =
                                      historyBooking[index]["barber"];
                                  Map<String, dynamic> user =
                                      historyBooking[index]["user"];

                                  var dateTime = booking['startTime'].toDate();
                                  var yearInBuddhistEra = dateTime.year + 543;
                                  var bookingDate = DateFormat.yMMMMd("th")
                                      .format(dateTime)
                                      .replaceAll((dateTime.year).toString(),
                                          yearInBuddhistEra.toString());
                                  var startTime = DateFormat.Hm()
                                      .format(booking['startTime'].toDate());
                                  var endTime = DateFormat.Hm()
                                      .format(booking['endTime'].toDate());

                                  var bookingStatus =
                                      booking['status'] == "booked"
                                          ? "จอง"
                                          : booking['status'] == 'cancelled'
                                              ? 'ยกเลิก'
                                              : 'เสร็จสิ้น';

                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: Card(
                                          margin: const EdgeInsets.all(10.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          elevation: 5,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(barber[
                                                                  'imageUrl'] ??
                                                              ''),
                                                      radius: 30,
                                                      onBackgroundImageError:
                                                          (exception,
                                                                  stackTrace) =>
                                                              Icon(
                                                                  Icons.person),
                                                    ),
                                                    const SizedBox(width: 16.0),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            user['name'] ??
                                                                'ไม่พบชื่อช่างตัดผม',
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                          Text(
                                                            barbershop[
                                                                    'shop_name'] ??
                                                                'ไม่พบชื่อร้าน',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .grey[600],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 15.0),
                                                Text(
                                                  'วันที่จอง: $bookingDate',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black87),
                                                ),
                                                const SizedBox(height: 5.0),
                                                Text(
                                                  'เวลาที่จอง: $startTime - $endTime น.',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black87),
                                                ),
                                                const SizedBox(height: 5.0),
                                                Text(
                                                  'สถานะ: $bookingStatus',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black87),
                                                ),
                                                const SizedBox(height: 10.0),
                                                (booking['status'] ==
                                                            'cancelled' ||
                                                        booking['status'] ==
                                                            'done')
                                                    ? SizedBox.shrink()
                                                    : ElevatedButton(
                                                        onPressed:
                                                            booking['status'] ==
                                                                    'cancelled'
                                                                ? null
                                                                : () async {
                                                                    DateTime
                                                                        now =
                                                                        DateTime
                                                                            .now();
                                                                    DateTime
                                                                        bookingStartTime =
                                                                        booking['startTime']
                                                                            .toDate();
                                                                    Duration
                                                                        timeDifference =
                                                                        bookingStartTime
                                                                            .difference(now);

                                                                    if (timeDifference
                                                                            .inMinutes <=
                                                                        30) {
                                                                      QuickAlert
                                                                          .show(
                                                                        context:
                                                                            context,
                                                                        type: QuickAlertType
                                                                            .warning,
                                                                        title:
                                                                            'ไม่สามารถยกเลิกได้',
                                                                        text:
                                                                            'ใกล้ถึงคิวตัดผมของคุณแล้ว ไม่สามารถยกเลิกได้!!',
                                                                        confirmBtnText:
                                                                            'ตกลง',
                                                                        confirmBtnColor:
                                                                            Colors.red,
                                                                      );
                                                                    } else {
                                                                      QuickAlert
                                                                          .show(
                                                                        context:
                                                                            context,
                                                                        type: QuickAlertType
                                                                            .confirm,
                                                                        title:
                                                                            'ยืนยันการยกเลิก',
                                                                        text:
                                                                            'คุณจะยกเลิกการจองคิวใช่หรือไม่?',
                                                                        confirmBtnText:
                                                                            'ตกลง',
                                                                        cancelBtnText:
                                                                            'ยกเลิก',
                                                                        confirmBtnColor:
                                                                            Colors.red,
                                                                        onConfirmBtnTap:
                                                                            () async {
                                                                          try {
                                                                            await FirebaseFirestore.instance.collection('Bookings').doc(historyBooking[index]["docId"]).update({
                                                                              'status': 'cancelled'
                                                                            });
                                                                            setState(() {
                                                                              booking['status'] = 'cancelled';
                                                                            });
                                                                            Navigator.of(context).pop();
                                                                          } catch (e) {
                                                                            print('Error updating booking: $e');
                                                                          }
                                                                        },
                                                                        onCancelBtnTap:
                                                                            () =>
                                                                                Navigator.of(context).pop(),
                                                                      );
                                                                    }
                                                                  },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              accentColor,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                        ),
                                                        child: Text(
                                                          booking['status'] ==
                                                                  'cancelled'
                                                              ? 'ยกเลิกแล้ว'
                                                              : 'ยกเลิก',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, Colors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person, size: 64, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "Barber Shop",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home,
                  color: _selectedIndex == 0 ? accentColor : Colors.black),
              title: const Text('หน้าหลัก'),
              selected: _selectedIndex == 0,
              selectedTileColor: Colors.grey[300],
              onTap: () {
                setState(() => _selectedIndex = 0);
                // อยู่หน้า HomeCustomer อยู่แล้ว ไม่ต้อง push ซ้ำ
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeCustomer()));
              },
            ),
            ListTile(
              leading: Icon(Icons.book_online,
                  color: _selectedIndex == 2 ? accentColor : Colors.black),
              title: const Text('การจอง'),
              selected: _selectedIndex == 2,
              selectedTileColor: Colors.grey[300],
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BookingShop()));
              },
            ),
            ListTile(
              leading: Icon(Icons.history,
                  color: _selectedIndex == 1 ? accentColor : Colors.black),
              title: const Text('ประวัติการจอง'),
              selected: _selectedIndex == 1,
              selectedTileColor: Colors.grey[300],
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BookingHistory()));
              },
            ),
            ListTile(
              leading: Icon(Icons.tab_outlined,
                  color: _selectedIndex == 3 ? accentColor : Colors.black),
              title: const Text('ดูตารางช่าง'),
              selected: _selectedIndex == 3,
              selectedTileColor: Colors.grey[300],
              onTap: () {
                setState(() => _selectedIndex = 3);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SeeBookingShop()));
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'ประวัติ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'การจอง',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tab_outlined),
            label: 'ตารางช่าง',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black, // ไอคอนที่เลือก (เช่น ประวัติ)
        unselectedItemColor: Colors.grey, // ไอคอนที่ไม่เลือก
        backgroundColor: Colors.white,
        elevation: 20,
        selectedLabelStyle: TextStyle(color: Colors.black),
        unselectedLabelStyle: TextStyle(color: Colors.grey),
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
