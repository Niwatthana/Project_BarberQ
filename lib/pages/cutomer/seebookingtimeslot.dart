import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SeeBookingTimeSlot extends StatefulWidget {
  const SeeBookingTimeSlot({
    super.key,
    required this.barbershopname,
    required this.barbershopid,
    required this.barbershopopen_hour,
    required this.barbershopopen_minute,
    required this.barbershopclose_hour,
    required this.barbershopclose_minute,
    required this.barber_id,
  });

  final String barbershopname;
  final String barbershopid;
  final String barbershopopen_hour;
  final String barbershopopen_minute;
  final String barbershopclose_hour;
  final String barbershopclose_minute;
  final String barber_id;

  @override
  State<SeeBookingTimeSlot> createState() => _SeeBookingTimeSlotState();
}

class _SeeBookingTimeSlotState extends State<SeeBookingTimeSlot> {
  TimeOfDay startTime = const TimeOfDay(hour: 1, minute: 0); // เวลาเริ่มต้น
  TimeOfDay endTime = const TimeOfDay(hour: 23, minute: 0); // เวลาสิ้นสุด
  List<Map<String, dynamic>> timeSlots = [];
  List<String> bookedSlots = [];

  @override
  void initState() {
    super.initState();
    fetchBarbershopTimes(); // ดึงเวลาจาก Firestore
  }

  Future<void> fetchBarbershopTimes() async {
    try {
      // ดึงเวลาที่ถูกจองแล้วจาก Firestore
      await fetchBookings();

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
        print(
            "Barbershop hours fetched: ${startTime.format(context)} - ${endTime.format(context)}");

        generateTimeSlots(); // สร้างช่วงเวลาหลังจากดึงข้อมูล
      } else {
        print("Barbershop document does not exist.");
      }
    } catch (e) {
      print("Error fetching barbershop times: $e");
    }
  }

  // ฟังก์ชันสร้างช่วงเวลา 30 นาทีระหว่าง startTime และ endTime
  void generateTimeSlots() {
    TimeOfDay currentTime = startTime;
    timeSlots = [];

    // Get the current DateTime
    DateTime now = DateTime.now();
    final currentDateTime =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);

    while (currentTime.hour < endTime.hour ||
        (currentTime.hour == endTime.hour &&
            currentTime.minute < endTime.minute)) {
      final endTimeSlot = addMinutes(currentTime, 30);
      final formattedStartTime =
          "${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}";
      final formattedEndTime =
          "${endTimeSlot.hour.toString().padLeft(2, '0')}:${endTimeSlot.minute.toString().padLeft(2, '0')}";

      String timeSlot = "$formattedStartTime - $formattedEndTime";

      // Convert TimeOfDay to DateTime to compare with currentDateTime
      final slotDateTime = DateTime(
          now.year, now.month, now.day, currentTime.hour, currentTime.minute);

      // ตรวจสอบว่าเวลาไหนถูกจองแล้วหรือไม่
      bool isBooked = bookedSlots.contains(formattedStartTime);

      // Check if the time slot is in the past
      bool isPast = slotDateTime.isBefore(currentDateTime);

      // Check if the time slot is less than 15 minutes away
      bool isLessThan15Minutes = false;
      if (!isPast) {
        final timeDifference =
            slotDateTime.difference(currentDateTime).inMinutes;
        if (timeDifference <= 15) {
          isLessThan15Minutes = true;
        }
      }

      // เพิ่ม map เข้าไปใน timeSlots
      timeSlots.add({
        "time": timeSlot,
        "isBooked": isBooked ||
            isPast ||
            isLessThan15Minutes, // Mark as booked if past time, already booked, or within 15 minutes
        "isLessThan15Minutes":
            isLessThan15Minutes, // เพิ่ม flag สำหรับเวลา 15 นาที
      });

      print(
          "Time slot created: $timeSlot, isBooked: ${isBooked || isPast}, isLessThan15Minutes: $isLessThan15Minutes");

      currentTime = endTimeSlot; // ขยับไปช่วงถัดไป
    }
    setState(() {}); // Refresh UI
  }

  // ฟังก์ชันเพิ่มเวลาเป็นนาที
  TimeOfDay addMinutes(TimeOfDay time, int minutes) {
    final now = DateTime.now();
    final currentTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final newTime = currentTime.add(Duration(minutes: minutes));

    return TimeOfDay(hour: newTime.hour, minute: newTime.minute);
  }

  Future<void> fetchBookings() async {
    try {
      // Get the current date
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));

      QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
          .collection('Bookings')
          .where('barber_id', isEqualTo: widget.barber_id)
          .where('status', isEqualTo: 'booked')
          .where('startTime', isGreaterThanOrEqualTo: startOfDay)
          .where('startTime', isLessThan: endOfDay)
          .get();

      bookedSlots.clear(); // Clear previous data

      if (bookingSnapshot.docs.isNotEmpty) {
        for (var doc in bookingSnapshot.docs) {
          // Get the start time
          Timestamp startTimeTimestamp = doc['startTime'] as Timestamp;
          String bookedStartTime =
              "${startTimeTimestamp.toDate().hour.toString().padLeft(2, '0')}:${startTimeTimestamp.toDate().minute.toString().padLeft(2, '0')}";
          bookedSlots.add(bookedStartTime); // Store start time in HH:mm format
          print("Booked time added: $bookedStartTime");
        }
        print("Total booked slots: ${bookedSlots.length}");
        setState(() {}); // Refresh UI
      } else {
        print("No bookings found for this barber.");
      }
    } catch (e) {
      print("Error fetching bookings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ดูเวลา'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text(widget.barbershopid),
            // Text(widget.barbershopname),
            // Text(widget.barber_id),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  return TimeSlotCard(
                    time: timeSlots[index]['time'],
                    isAvailable: !timeSlots[index]
                        ['isBooked'], // ถ้าถูกจองแล้วจะไม่ว่าง
                    isBooked: timeSlots[index]['isBooked'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// การ์ดแสดงข้อมูลช่วงเวลา
class TimeSlotCard extends StatelessWidget {
  final String time;
  final bool isAvailable;
  final bool isBooked;

  const TimeSlotCard({
    super.key,
    required this.time,
    required this.isAvailable,
    required this.isBooked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: isBooked
          ? Colors.red[400]
          : (isAvailable ? Colors.green[400] : Colors.grey[400]),
      elevation: 5,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // จัดให้ไปทางขวา
          children: [
            Text(
              time,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black), // เปลี่ยนสีข้อความให้เห็นชัด
            ),
            Text(
              isBooked ? 'ไม่ว่าง' : 'ว่าง',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black), // สีข้อความให้สอดคล้องกับสีการ์ด
            ),
          ],
        ),
      ),
    );
  }
}
