import 'package:barberapp/pages/cutomer/choosebarber.dart';
import 'package:flutter/material.dart';

class TimeSlot extends StatefulWidget {
  const TimeSlot({
    super.key,
    required this.barbershopname,
    required this.barbershopid,
  });

  final String barbershopname;
  final String barbershopid;

  @override
  State<TimeSlot> createState() => _TimeSlotState();
}

class _TimeSlotState extends State<TimeSlot> {
  TimeOfDay startTime = const TimeOfDay(hour: 1, minute: 0); // เวลาเริ่มต้น
  TimeOfDay endTime = const TimeOfDay(hour: 23, minute: 0); // เวลาสิ้นสุด
  List<String> timeSlots = [];

  @override
  void initState() {
    super.initState();
    generateTimeSlots(); // สร้างช่วงเวลา 30 นาที
  }

  // ฟังก์ชันสร้างช่วงเวลา 30 นาทีระหว่าง startTime และ endTime
  void generateTimeSlots() {
    TimeOfDay currentTime = startTime;
    timeSlots = []; // เคลียร์รายการก่อนสร้างใหม่

    while (currentTime.hour < endTime.hour ||
        (currentTime.hour == endTime.hour && currentTime.minute < endTime.minute)) {
      final endTimeSlot = addMinutes(currentTime, 30);
      // แสดงเวลาในรูปแบบ 24 ชั่วโมง
      final formattedStartTime = "${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}";
      final formattedEndTime = "${endTimeSlot.hour.toString().padLeft(2, '0')}:${endTimeSlot.minute.toString().padLeft(2, '0')}";
      timeSlots.add("$formattedStartTime - $formattedEndTime น.");
      currentTime = endTimeSlot; // เพิ่มทีละ 30 นาที
    }
    setState(() {});
  }

  // ฟังก์ชันเพิ่มเวลาเป็นนาที
  TimeOfDay addMinutes(TimeOfDay time, int minutes) {
    final now = DateTime.now();
    final currentTime = DateTime(
        now.year, now.month, now.day, time.hour, time.minute);
    final newTime = currentTime.add(Duration(minutes: minutes));

    return TimeOfDay(hour: newTime.hour, minute: newTime.minute);
  }

  // ฟังก์ชันเช็คว่าช่วงเวลานี้ว่างหรือไม่
  bool _isTimeSlotAvailable(String timeSlot) {
    final timeParts = timeSlot.split(' - ');
    final startTime = _parseTime(timeParts[0]);

    // เช็คเวลาปัจจุบัน
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final startDateTime = DateTime(
        today.year, today.month, today.day, startTime.hour, startTime.minute);

    return now.isBefore(startDateTime); // จะกลับมาเป็น true เฉพาะถ้ายังไม่ถึงเวลา
  }

  // ฟังก์ชันแปลงเวลาที่เป็น string ให้เป็น TimeOfDay
  TimeOfDay _parseTime(String time) {
    try {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      // Return a default value or throw an error as per your requirements
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกเวลา'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(widget.barbershopid),
            Text(widget.barbershopname),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  return TimeSlotCard(
                    time: timeSlots[index],
                    isAvailable: _isTimeSlotAvailable(timeSlots[index]),
                    onMorePressed: () => _onTimeSlotSelected(timeSlots[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันเลือกเวลาโดยตรง
  void _onTimeSlotSelected(String selectedTime) {
    // นำผู้ใช้ไปยังหน้าถัดไปโดยไม่ต้องยืนยัน
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChooseBarber(
          barbershopname: widget.barbershopname,
          barbershopid: widget.barbershopid,
          selectedTime: selectedTime,
        ),
      ),
    );
  }
}

// การ์ดแสดงข้อมูลช่วงเวลา
class TimeSlotCard extends StatelessWidget {
  final String time;
  final bool isAvailable;
  final VoidCallback onMorePressed;

  const TimeSlotCard({
    super.key,
    required this.time,
    required this.isAvailable,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: isAvailable ? Colors.grey[300] : Colors.grey[400],
      elevation: 5,
      child: ListTile(
        title: Text(
          time,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: GestureDetector(
          onTap: isAvailable ? onMorePressed : null,
          child: Icon(
            Icons.check,
            color: isAvailable ? Colors.green : Colors.grey[200],
          ),
        ),
      ),
    );
  }
}
