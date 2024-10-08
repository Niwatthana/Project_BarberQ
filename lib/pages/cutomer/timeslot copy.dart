import 'package:barberapp/pages/cutomer/choosebarber.dart';
import 'package:flutter/material.dart';

class TimeSlot extends StatefulWidget {
  const TimeSlot(
      {super.key, required this.barbershopname, required this.barbershopid});

  final String barbershopname;
  final String barbershopid;

  @override
  State<TimeSlot> createState() => _TimeSlotState();
}

class _TimeSlotState extends State<TimeSlot> {
  final List<String> timeSlots = [
    '09:00 - 09:30 น.',
    '09:30 - 10:00 น.',
    '10:00 - 10:30 น.',
    '10:30 - 11:00 น.',
    '11:00 - 11:30 น.',
    '11:30 - 12:00 น.',
    '13:00 - 13:30 น.',
    '13:30 - 14:00 น.',
    '14:00 - 14:30 น.',
    '14:30 - 15:00 น.',
    '15:00 - 15:30 น.',
    '15:30 - 16:00 น.',
    '16:00 - 16:30 น.',
    '16:30 - 17:00 น.',
    '17:00 - 17:30 น.',
    '17:30 - 18:00 น.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกเวลา'),
        // backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(widget.barbershopid),
            Text(widget.barbershopname),
            ListView.builder(
              shrinkWrap: true,
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                return TimeSlotCard(
                  time: timeSlots[index],
                  onMorePressed: () {
                    // ส่งข้อมูลเวลาไปยังหน้าจอ TimeSlotDetails
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChooseBarber(
                            barbershopname: widget.barbershopname,
                            barbershopid: widget.barbershopid,
                            selectedTime: timeSlots[index]),
                        // ใช้หน้าจอ TimeSlotDetails
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TimeSlotCard extends StatelessWidget {
  final String time;
  final VoidCallback onMorePressed;

  const TimeSlotCard(
      {super.key, required this.time, required this.onMorePressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.grey[300],
      elevation: 5,
      child: ListTile(
        title: Text(
          time,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: GestureDetector(
          onTap: onMorePressed,
          child: Icon(
            Icons.check,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }
}

// class TimeSlotDetails extends StatefulWidget {
//   // เปลี่ยนชื่อคลาสนี้เพื่อไม่ให้ซ้ำกัน
//   final String selectedTime; // รับค่าเวลาที่ถูกเลือกมา

//   const TimeSlotDetails({super.key, required this.selectedTime});

//   @override
//   State<TimeSlotDetails> createState() => _TimeSlotDetailsState();
// }

// class _TimeSlotDetailsState extends State<TimeSlotDetails> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('รายละเอียดเวลา'),
//       ),
//       body: Center(
//         child: Text(
//           'คุณเลือกเวลา: ${widget.selectedTime}', // แสดงเวลาที่เลือก
//           style: const TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
// }
