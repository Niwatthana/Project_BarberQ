import 'package:barberapp/pages/cutomer/choosehairstyle.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChooseBarber extends StatelessWidget {
  final String selectedTime;
  final String barbershopname;
  final String barbershopid;

  const ChooseBarber({
    super.key,
    required this.selectedTime,
    required this.barbershopname,
    required this.barbershopid,
  });

  Future<List<Map<String, dynamic>>> _getAvailableBarbers(
      String selectedTime) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    var mytime = selectedTime.split("-");
    var mystarttimestr = mytime[0].toString().trim();
    List<String> startimesplit = mystarttimestr.split(":");
    DateTime now = DateTime.now();

    TimeOfDay _starttime = TimeOfDay(
        hour: int.parse(startimesplit[0]), minute: int.parse(startimesplit[1]));

    DateTime startTime = DateTime(
        now.year, now.month, now.day, _starttime.hour, _starttime.minute);

    // Query to get barbers who are booked for the selected time and have status "booked"
    QuerySnapshot bookingsSnapshot = await _firestore
        .collection('Bookings')
        .where('startTime', isEqualTo: startTime)
        .where('status', isEqualTo: "booked")
        .where("barbershop_id", isEqualTo: barbershopid)
        .get();

    // Extract booked barber ids
    List<String> bookedBarberIds = bookingsSnapshot.docs
        .map<String>((doc) => doc['barber_id'])
        .toList();

    // Query to get all barbers excluding those that are booked
    QuerySnapshot barbersSnapshot = await _firestore
        .collection('Barbers')
        .where("barbershop_id", isEqualTo: barbershopid)
        .get();

    // Filter out booked barbers
    List<Map<String, dynamic>> availableBarbers = barbersSnapshot.docs
        .where((barber) => !bookedBarberIds.contains(barber.id))
        .map((barber) => {
              ...barber.data() as Map<String, dynamic>,
              'barber_id': barber.id // Include barber ID for passing
            })
        .toList();

    return availableBarbers;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF1B4B4B); // สีหลัก (เขียวเข้ม)
    final Color accentColor = Colors.redAccent; // สีรอง (แดง)

    return Scaffold(
      // ข้อ 9: Gradient Background
      backgroundColor: Colors.white, // ใช้สีพื้นหลังขาวก่อน แล้วปรับด้วย gradient
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
              // ข้อ 10: Custom AppBar (ไม่ใช้ PopupMenuButton)
              AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text('เลือกช่าง', style: TextStyle(color: Colors.white, fontSize: 20)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, Colors.teal],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getAvailableBarbers(selectedTime),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: accentColor)); // ข้อ 2: Loading (ปรับสี)
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error fetching barbers', style: TextStyle(color: Colors.black87))); // ข้อ 8: Error Handling (ปรับสี)
                      }

                      final availableBarbers = snapshot.data ?? [];

                      if (availableBarbers.isEmpty) {
                        return Center(
                          child: Text(
                            'ไม่มีช่างที่ว่าง ในเวลาที่คุณเลือก โปรดเลือกเวลาใหม่',
                            style: TextStyle(color: Colors.black87, fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: availableBarbers.length,
                        itemBuilder: (context, index) {
                          final barber = availableBarbers[index];
                          final imageUrl = barber['imageUrl'] ?? 'https://via.placeholder.com/150'; // Placeholder image if no URL
                          final feature = barber['feature'] ?? 'No features available';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5,
                            color: Colors.white, // ข้อ 3: Card Design (ปรับสีพื้นหลัง Card)
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(imageUrl),
                                radius: 30,
                              ),
                              title: Text(barber['name'] ?? 'Unnamed Barber',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)), // ข้อ 4: Typography (ปรับสี)
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Features: $feature',
                                      style: TextStyle(fontSize: 14, color: Colors.grey[600])), // ข้อ 4: Typography (ปรับสี)
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChooseHairstyle(
                                        barbershopid: barbershopid,
                                        selectedTime: selectedTime,
                                        barbershopname: barbershopname,
                                        barberid: barber['barber_id'],
                                        barbername: barber['name'],
                                        imgbarber: barber['imageUrl'],
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: accentColor, // ข้อ 1: Theme Color (ปรับสีปุ่ม)
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('เลือก'),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}