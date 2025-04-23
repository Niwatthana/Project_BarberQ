import 'package:barberapp/pages/cutomer/choosebarber.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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
  bool isLoading = true; // ข้อ 2: Loading State
  bool hasError = false; // ข้อ 8: Error Handling

  final Color primaryColor = Color(0xFF1B4B4B);
  final Color accentColor = Colors.redAccent;

  @override
  void initState() {
    super.initState();
    fetchBarbershopTimes().then((_) => setState(() => isLoading = false));
  }

  Future<void> fetchBarbershopTimes() async {
    try {
      DocumentSnapshot barbershopDoc = await FirebaseFirestore.instance
          .collection('BarberShops')
          .doc(widget.barbershopid)
          .get();

      if (barbershopDoc.exists) {
        setState(() {
          startTime = TimeOfDay(
            hour: int.parse(barbershopDoc['open_hour']),
            minute: int.parse(barbershopDoc['open_minute']),
          );
          endTime = TimeOfDay(
            hour: int.parse(barbershopDoc['close_hour']),
            minute: int.parse(barbershopDoc['close_minute']),
          );
        });
        generateTimeSlots();
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  // ฟังก์ชันสร้างช่วงเวลา 30 นาทีระหว่าง startTime และ endTime
  void generateTimeSlots() {
    TimeOfDay currentTime = startTime;
    timeSlots = []; // เคลียร์รายการก่อนสร้างใหม่

    while (currentTime.hour < endTime.hour ||
        (currentTime.hour == endTime.hour &&
            currentTime.minute < endTime.minute)) {
      final endTimeSlot = addMinutes(currentTime, 30);
      final formattedStartTime =
          "${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}";
      final formattedEndTime =
          "${endTimeSlot.hour.toString().padLeft(2, '0')}:${endTimeSlot.minute.toString().padLeft(2, '0')}";
      timeSlots.add("$formattedStartTime - $formattedEndTime น.");
      currentTime = endTimeSlot; // เพิ่มทีละ 30 นาที
    }
    setState(() {});
  }

  // ฟังก์ชันเพิ่มเวลาเป็นนาที
  TimeOfDay addMinutes(TimeOfDay time, int minutes) {
    final now = DateTime.now();
    final currentTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final newTime = currentTime.add(Duration(minutes: minutes));
    return TimeOfDay(hour: newTime.hour, minute: newTime.minute);
  }

  // ฟังก์ชันเช็คว่าช่วงเวลานี้ว่างหรือไม่
  bool _isTimeSlotAvailable(String timeSlot) {
    final timeParts = timeSlot.split(' - ');
    final startTime = _parseTime(timeParts[0]);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final startDateTime = DateTime(
        today.year, today.month, today.day, startTime.hour, startTime.minute);

    return now
        .isBefore(startDateTime); // จะกลับมาเป็น true เฉพาะถ้ายังไม่ถึงเวลา
  }

  // ฟังก์ชันแปลงเวลาที่เป็น string ให้เป็น TimeOfDay
  TimeOfDay _parseTime(String time) {
    try {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  void _onTimeSlotSelected(String selectedTime) {
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
          child: Column(
            children: [
              // ข้อ 10: Custom AppBar (แทน PopupMenuButton ด้วย Back Button)
              AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text('เลือกเวลา',
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
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                              color: accentColor)) // ข้อ 2: Loading
                      : hasError
                          ? Center(
                              child: Text('ไม่สามารถโหลดข้อมูลได้',
                                  style: TextStyle(
                                      color: Colors
                                          .black87))) // ข้อ 8: Error Handling
                          : AnimationLimiter(
                              // ข้อ 11: Animation
                              child: ListView.builder(
                                itemCount: timeSlots.length,
                                itemBuilder: (context, index) {
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: TimeSlotCard(
                                          time: timeSlots[index],
                                          isAvailable: _isTimeSlotAvailable(
                                              timeSlots[index]),
                                          onMorePressed: () =>
                                              _onTimeSlotSelected(
                                                  timeSlots[index]),
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
          borderRadius: BorderRadius.circular(15)), // ข้อ 3: Card Design
      elevation: 5,
      child: InkWell(
        onTap: isAvailable ? onMorePressed : null,
        splashColor: isAvailable
            ? Colors.redAccent.withOpacity(0.3)
            : null, // ข้อ 7: Feedback
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 16,
                  color: isAvailable
                      ? Colors.black87
                      : Colors.grey[600], // ข้อ 4: Typography
                ),
              ),
              Icon(
                Icons.check,
                color: isAvailable ? Colors.green : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
