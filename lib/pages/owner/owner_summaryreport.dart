import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SummaryReproState extends StatefulWidget {
  const SummaryReproState({super.key});

  @override
  State<SummaryReproState> createState() => _SummaryReproStateState();
}

class _SummaryReproStateState extends State<SummaryReproState> {
  int bookedCount = 0;
  int cancelledCount = 0;
  int doneCount = 0;
  bool isLoading = true;

  List<BarberChartData> chartData = [];

  Future<void> _summaryreportData() async {
    try {
      // Fetch the bookings for the specific user
      var bookingBookedSnapshot = await FirebaseFirestore.instance
          .collection("Bookings")
          .where("barbershop_id",
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where("status", isEqualTo: "booked") // Filter by userId
          .get();

      var bookingCancelledSnapshot = await FirebaseFirestore.instance
          .collection("Bookings")
          .where("barbershop_id",
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where("status", isEqualTo: "cancelled") // Filter by userId
          .get();

      var bookingDoneSnapshot = await FirebaseFirestore.instance
          .collection("Bookings")
          .where("barbershop_id",
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where("status", isEqualTo: "done") // Filter by userId
          .get();

      print(bookingBookedSnapshot.size);
      print(bookingCancelledSnapshot.size);
      print(bookingDoneSnapshot.size);
      setState(() {
        bookedCount = bookingBookedSnapshot.size;
        cancelledCount = bookingCancelledSnapshot.size;
        doneCount = bookingDoneSnapshot.size;
      });

      // กราฟแท่ง
      var barberInShopSnapshot = await FirebaseFirestore.instance
          .collection("Barbers")
          .where("barbershop_id",
              isEqualTo:
                  FirebaseAuth.instance.currentUser!.uid) // Filter by userId
          .get();

      List<DocumentSnapshot> barbers = barberInShopSnapshot.docs;
      print("---------------");
      print(barbers.length);

      barbers.map(
        (doc) async {
          var barberdata = doc.data() as Map<String, dynamic>;
          print(barberdata['barber_id']);
          print(barberdata['name']);

          var bookedBarberSnapshot = await FirebaseFirestore.instance
              .collection("Bookings")
              .where("barber_id", isEqualTo: barberdata['barber_id'])
              .where("status", isEqualTo: "booked")
              .count()
              .get();
          print("${barberdata['name']} : ${bookedBarberSnapshot.count}");

          var cancelledBarberSnapshot = await FirebaseFirestore.instance
              .collection("Bookings")
              .where("barber_id", isEqualTo: barberdata['barber_id'])
              .where("status", isEqualTo: "cancelled")
              .count()
              .get();
          print("-------------");
          print("${barberdata['name']} : ${cancelledBarberSnapshot.count}");

          var doneBarberSnapshot = await FirebaseFirestore.instance
              .collection("Bookings")
              .where("barber_id", isEqualTo: barberdata['barber_id'])
              .where("status", isEqualTo: "done")
              .count()
              .get();
          print("*********");
          print("${barberdata['name']} : ${doneBarberSnapshot.count}");

          setState(() {
            chartData.add(BarberChartData(
                barberdata['name'],
                bookedBarberSnapshot.count!,
                cancelledBarberSnapshot.count!,
                doneBarberSnapshot.count!));
          });
        },
      ).toList();

      setState(() {
        isLoading = false;
      });

      print(isLoading);

      // List<DocumentSnapshot> bookings = bookingBookedSnapshot.docs;

      // ----------------
    } catch (e) {
      print('Error fetching bookings: $e');
    }
  }

  @override
  void initState() {
    _summaryreportData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              //       children: [
              //         Text("$bookedCount"),
              //         Text("$cancelledCount"),
              //         Text("$doneCount"),
              //         Text("$isLoading"),
              //           body: isLoading
              // ? Center(child: CircularProgressIndicator())
              // : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // การ์ดสำหรับการจอง
                    Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "จอง",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "$bookedCount",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "ครั้ง",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // การ์ดสำหรับการยกเลิก

                    // การ์ดสำหรับการสำเร็จ
                    Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "สำเร็จ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "$doneCount",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "ครั้ง",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "ยกเลิก",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "$cancelledCount",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "ครั้ง",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    title:
                        ChartTitle(text: 'สถิติการจอง สำเร็จ และยกเลิกต่อวัน'),
                    legend: Legend(isVisible: true),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries<BarberChartData, String>>[
                      ColumnSeries<BarberChartData, String>(
                        dataSource: chartData,
                        xValueMapper: (BarberChartData data, _) =>
                            data.barbername,
                        yValueMapper: (BarberChartData data, _) =>
                            data.bookingCount,
                        color: Colors.blue[200],
                        name: 'จอง',
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      ),
                      ColumnSeries<BarberChartData, String>(
                        dataSource: chartData,
                        xValueMapper: (BarberChartData data, _) =>
                            data.barbername,
                        yValueMapper: (BarberChartData data, _) =>
                            data.doneCount,
                        color: Colors.green[300],
                        name: 'สำเร็จ',
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      ),
                      ColumnSeries<BarberChartData, String>(
                        dataSource: chartData,
                        xValueMapper: (BarberChartData data, _) =>
                            data.barbername,
                        yValueMapper: (BarberChartData data, _) =>
                            data.cancelledCount,
                        color: Colors.red[300],
                        name: 'ยกเลิก',
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class BarberChartData {
  final String barbername;
  final int bookingCount;
  final int cancelledCount;
  final int doneCount;

  BarberChartData(
      this.barbername, this.bookingCount, this.cancelledCount, this.doneCount);
}
