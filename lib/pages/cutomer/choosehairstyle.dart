import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bookingresults.dart'; // นำเข้าหน้าการจอง

class ChooseHairstyle extends StatefulWidget {
  final String barbershopname;
  final String barbershopid;
  final String selectedTime;
  final String barberid;
  final String barbername;
  final String imgbarber;

  const ChooseHairstyle({
    super.key,
    required this.barbershopid,
    required this.barbershopname,
    required this.selectedTime,
    required this.barberid,
    required this.barbername,
    required this.imgbarber,
  });

  @override
  State<ChooseHairstyle> createState() => _ChooseHairstyleState();
}

class _ChooseHairstyleState extends State<ChooseHairstyle> {
  String? selectedGroup = 'เด็ก';

  @override
  void initState() {
    super.initState();
  }

  Stream<QuerySnapshot> fetchHairstyles() {
    return FirebaseFirestore.instance
        .collection("Haircuts")
        .where("owner_id", isEqualTo: widget.barbershopid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Hairstyle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 150,
              padding: const EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFEDECF2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: DropdownButton<String>(
                          value: selectedGroup,
                          items:
                              ['เด็ก', 'วัยรุ่น', 'ผู้ใหญ่'].map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (String? newtype) {
                            setState(() {
                              selectedGroup = newtype;
                              print('ประเภทคือ : $selectedGroup');
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: fetchHairstyles(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Something went wrong'));
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: Text("Loading"));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text("No hairstyles available"));
                        }

                        return ListView(
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;
                            return Card(
                              child: ListTile(
                                leading: Image.network(
                                  data['shop_img'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(data['haircut_name']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ราคา: ${data['price']} บาท'),
                                    Text('Time: ${data['time']} นาที'),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookingResults(
                                          barbershopid: widget.barbershopid,
                                          selectedTime: widget.selectedTime,
                                          barbershopname: widget.barbershopname,
                                          barberid: widget.barberid,
                                          barbername: widget.barbername,
                                          haircut: data['haircut_name'],
                                          price: data['price'],
                                          time: data['time'],
                                          haircutid: document.id,
                                          imgbarber: widget.imgbarber,
                                          selectedGroup: selectedGroup,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('เลือก'),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
