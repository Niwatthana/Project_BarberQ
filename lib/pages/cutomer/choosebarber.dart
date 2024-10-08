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
    print(mystarttimestr);
    List<String> startimesplit = mystarttimestr.split(":");
    print(startimesplit);
    DateTime now = DateTime.now();

    TimeOfDay _starttime = TimeOfDay(
        hour: int.parse(startimesplit[0]), minute: int.parse(startimesplit[1]));

    DateTime startTime = DateTime(
        now.year, now.month, now.day, _starttime.hour, _starttime.minute);

    // Query to get barbers who are booked for the selected time and have status "booked"
    QuerySnapshot bookingsSnapshot = await _firestore
        .collection('Bookings')
        // .where('bookingDate', isEqualTo: DateTime.now())
        .where('startTime', isEqualTo: startTime)
        .where('status', isEqualTo: "booked")
        .where("barbershop_id", isEqualTo: barbershopid)
        .get();

    // print("------");
    // print(bookingsSnapshot.size);

    // Extract booked barber ids
    List<String> bookedBarberIds = bookingsSnapshot.docs
        .map<String>((doc) => doc['barber_id'])
        // .map((doc) => doc['barbershop_id1'] as String)
        .toList();
    // print(bookedBarberIds);

    // Query to get all barbers excluding those that are booked
    QuerySnapshot barbersSnapshot = await _firestore
        .collection('Barbers')
        .where("barbershop_id", isEqualTo: barbershopid)
        .get();

    // print("*******");
    // print(barbersSnapshot.size);

    // Filter out booked barbers
    List<Map<String, dynamic>> availableBarbers = barbersSnapshot.docs
        .where((barber) => !bookedBarberIds.contains(barber.id))
        .map((barber) => {
              ...barber.data() as Map<String, dynamic>,
              'barber_id': barber.id // Include barber ID for passing
            })
        .toList();

    // print("//////////");
    // print(availableBarbers);
    // print(availableBarbers.length);

    return availableBarbers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Barbers'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAvailableBarbers(selectedTime),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching barbers'));
          }

          final availableBarbers = snapshot.data ?? [];

          if (availableBarbers.isEmpty) {
            return const Center(
                child: Text(
                    'ไม่มีช่างที่ว่าง ในเวลาที่คุณเลือก โปรดเลือกเวลาใหม่'));
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Barbershop: $barbershopname',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Selected Time: $selectedTime',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: availableBarbers.length,
                    itemBuilder: (context, index) {
                      final barber = availableBarbers[index];
                      final imageUrl = barber['imageUrl'] ??
                          'https://via.placeholder.com/150'; // Placeholder image if no URL
                      final feature =
                          barber['feature'] ?? 'No features available';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(imageUrl),
                            radius: 30,
                          ),
                          title: Text(barber['name'] ?? 'Unnamed Barber'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Features: $feature'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Navigate to ChooseHairstyle and pass the barber ID
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
                            child: const Text('เลือก'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
