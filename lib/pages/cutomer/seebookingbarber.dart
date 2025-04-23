import 'package:barberapp/pages/cutomer/seebookingtimeslot.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeeBookingBarber extends StatefulWidget {
  final String barbershopname;
  final String barbershopid;
  final String barbershopopen_hour;
  final String barbershopopen_minute;
  final String barbershopclose_hour;
  final String barbershopclose_minute;

  const SeeBookingBarber({
    super.key,
    required this.barbershopname,
    required this.barbershopid,
    required this.barbershopopen_hour,
    required this.barbershopopen_minute,
    required this.barbershopclose_hour,
    required this.barbershopclose_minute,
  });

  @override
  _SeeBookingBarberState createState() => _SeeBookingBarberState();
}

class _SeeBookingBarberState extends State<SeeBookingBarber> {
  late Future<List<Map<String, dynamic>>> _barbersFuture;

  @override
  void initState() {
    super.initState();
    // Call the function to fetch barbers at the start
    _barbersFuture = getBarbers();
  }

  Future<List<Map<String, dynamic>>> getBarbers() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Query to get all barbers associated with the barbershop
    QuerySnapshot barbersSnapshot = await _firestore
        .collection('Barbers')
        .where("barbershop_id", isEqualTo: widget.barbershopid)
        .get();

    // Map the barbers data into a list
    List<Map<String, dynamic>> barbers = barbersSnapshot.docs
        .map((doc) => {
              'barber_id': doc.id,
              'name': doc['name'],
              'imageUrl': doc['imageUrl'],
              'feature': doc['feature'],
            })
        .toList();

    return barbers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ช่างในร้าน ${widget.barbershopname}'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _barbersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('เกิดข้อผิดพลาด'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่มีช่างในร้านนี้'));
          }

          List<Map<String, dynamic>> barbers = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: barbers.length,
              itemBuilder: (context, index) {
                final barber = barbers[index];
                final imageUrl = barber['imageUrl'] ??
                    'https://via.placeholder.com/150'; // Placeholder image if no URL
                final feature = barber['feature'] ?? 'ไม่มีข้อมูลพิเศษ';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(imageUrl),
                      radius: 30,
                    ),
                    title: Text(barber['name'] ?? 'ไม่มีชื่อ'),
                    subtitle: Text('คุณสมบัติ: $feature'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Handle selecting the barber and navigate to SeeBookingTimeSlot
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SeeBookingTimeSlot(
                              barbershopname: widget.barbershopname,
                              barbershopid: widget.barbershopid,
                              barbershopopen_hour: widget.barbershopopen_hour,
                              barbershopopen_minute:
                                  widget.barbershopopen_minute,
                              barbershopclose_hour: widget.barbershopclose_hour,
                              barbershopclose_minute:
                                  widget.barbershopclose_minute,
                              barber_id: '${barber['barber_id']}',
                              // Corrected passing barber_id
                            ),
                          ),
                        );
                        print(
                            "Selected Barber: ${barber['name']}, ID: ${barber['barber_id']}");
                      },
                      child: const Text('เลือก'),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
