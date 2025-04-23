import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barberapp/pages/cutomer/bookingresults.dart'; // นำเข้าหน้าการจอง

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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ข้อ 10: Custom AppBar (ไม่ใช้ PopupMenuButton)
                AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text('Choose Hairstyle', style: TextStyle(color: Colors.white, fontSize: 20)),
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
                  child: Container(
                    height: MediaQuery.of(context).size.height - 150,
                    padding: const EdgeInsets.only(top: 15),
                    decoration: BoxDecoration(
                      color: Colors.white, // ข้อ 3: Card Design (ปรับสีพื้นหลัง Container)
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
                                dropdownColor: Colors.white, // ปรับสีพื้นหลัง Dropdown
                                style: TextStyle(color: Colors.black87), // ข้อ 4: Typography (ปรับสีตัวอักษร)
                                items: ['เด็ก', 'วัยรุ่น', 'ผู้ใหญ่'].map((String type) {
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
                                icon: Icon(Icons.arrow_drop_down, color: accentColor), // ปรับสีไอคอน Dropdown
                                underline: Container(
                                  height: 2,
                                  color: primaryColor, // ปรับสีเส้นใต้ Dropdown
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: fetchHairstyles(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Center(child: Text('Something went wrong', style: TextStyle(color: Colors.black87))); // ข้อ 8: Error Handling (ปรับสี)
                              }

                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator(color: accentColor)); // ข้อ 2: Loading (ปรับสี)
                              }

                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return Center(child: Text("No hairstyles available", style: TextStyle(color: Colors.black87))); // ข้อ 8: Error Handling (ปรับสี)
                              }

                              return ListView(
                                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    elevation: 5,
                                    color: Colors.white, // ข้อ 3: Card Design (ปรับสีพื้นหลัง Card)
                                    child: ListTile(
                                      leading: Image.network(
                                        data['shop_img'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Icon(Icons.image, color: Colors.grey[600]), // ข้อ 5: Handle image error
                                      ),
                                      title: Text(data['haircut_name'],
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)), // ข้อ 4: Typography (ปรับสี)
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('ราคา: ${data['price']} บาท',
                                              style: TextStyle(fontSize: 14, color: Colors.grey[600])), // ข้อ 4: Typography (ปรับสี)
                                          Text('Time: ${data['time']} นาที',
                                              style: TextStyle(fontSize: 14, color: Colors.grey[600])), // ข้อ 4: Typography (ปรับสี)
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
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}