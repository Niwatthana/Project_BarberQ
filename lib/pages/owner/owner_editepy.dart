import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart'; // แทนที่ด้วยที่อยู่ของ QuickAlert

class EditEpy extends StatefulWidget {
  const EditEpy({super.key, required this.docid});

  final String docid;

  @override
  State<EditEpy> createState() => _EditEpyState();
}

class _EditEpyState extends State<EditEpy> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _telController = TextEditingController();

  final List<String> _haircut = [
    "สกินเฮด",
    "ทรงนักเรียน",
    "ทูบล็อก",
    "ทรงมัลเล็ต",
    "ทรงอันเดอร์คัต",
  ];
  List<String> haircut_checked = <String>[];

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    if (widget.docid.isNotEmpty) {
      getBarber();
    }
  }

  void getBarber() async {
    DocumentSnapshot<Map<String, dynamic>> barber =
        await firestore.collection("Barbers").doc(widget.docid).get();

    var data = barber.data();
    List<String> haircut = [];
    for (var hair in data!['haircut']) {
      haircut.add(hair);
    }
    setState(() {
      _nameController.text = data['name'];
      _telController.text = data['tel'];
      haircut_checked = haircut;
    });
  }

  void _editBarber() {
    FirebaseFirestore.instance.collection('Barbers').doc(widget.docid).update({
      'name': _nameController.text,
      'tel': _telController.text,
      'haircut': haircut_checked,
    }).then((value) {
      Navigator.pop(context);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "สำเร็จ!",
        text: 'แก้ไขข้อมูลช่างตัดผมสำเร็จ',
        confirmBtnText: 'ตกลง',
        confirmBtnColor: const Color.fromARGB(255, 28, 221, 14),
      );
    }).catchError((error) {
      print("เกิดข้อผิดพลาดในการแก้ไขช่างตัดผม: $error");
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'ผิดพลาด!',
        text: 'ไม่สามารถแก้ไขข้อมูลได้ กรุณาลองใหม่อีกครั้ง',
        confirmBtnText: 'ตกลง',
        confirmBtnColor: const Color.fromARGB(255, 255, 0, 0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'แก้ไขช่างตัดผม',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'ชื่อช่างตัดผม'),
          ),
          TextField(
            controller: _telController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'เบอร์โทรศัพท์'),
          ),
          const SizedBox(height: 16),
          const Text(
            'เลือกความสามารถ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          Wrap(
            spacing: 5.0,
            children: _haircut.map((hc) {
              return FilterChip(
                label: Text(hc),
                selected: haircut_checked.contains(hc),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      haircut_checked.add(hc);
                    } else {
                      haircut_checked.remove(hc);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('ยกเลิก'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  String name = _nameController.text.trim();
                  String tel = _telController.text.trim();
                  if (name.isNotEmpty && tel.isNotEmpty) {
                    _editBarber();
                  } else {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: 'ผิดพลาด!',
                      text: 'ไม่สามารถเพิ่มข้อมูลได้ กรุณาลองใหม่อีกครั้ง',
                      confirmBtnText: 'ตกลง',
                      confirmBtnColor: const Color.fromARGB(255, 255, 0, 0),
                    );
                  }
                },
                child: const Text('แก้ไข'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
