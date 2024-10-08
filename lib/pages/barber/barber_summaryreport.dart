import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BarberSummaryReport extends StatefulWidget {
  const BarberSummaryReport({super.key});

  @override
  State<BarberSummaryReport> createState() => _BarberSummaryReportState();
}

class _BarberSummaryReportState extends State<BarberSummaryReport> {
  List<BarberDateChartData> chartData = [];

  Future<void> _barbersummaryreportData() async {
    List<String> lastSevenDays = [];

    for (int i = 7; i > 0; i--) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      String formattedDate = DateFormat.yMMMMd().format(date);
      lastSevenDays.add(formattedDate);
    }

    try {
      for (String checkdate in lastSevenDays) {
        // print(checkdate);
        var bookedDateSnapshot = await FirebaseFirestore.instance
            .collection("Bookings")
            .where("barber_id",
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where("status", isEqualTo: "booked")
            .where("bookingDate", isEqualTo: checkdate)
            .get();
        print("booked: $checkdate : ${bookedDateSnapshot.size}");

        var cancelledDateSnapshot = await FirebaseFirestore.instance
            .collection("Bookings")
            .where("barber_id",
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where("status", isEqualTo: "cancelled")
            .where("bookingDate", isEqualTo: checkdate)
            .get();
        print("cancelled: $checkdate : ${cancelledDateSnapshot.size}");

        var doneDateSnapshot = await FirebaseFirestore.instance
            .collection("Bookings")
            .where("barber_id",
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where("status", isEqualTo: "done")
            .where("bookingDate", isEqualTo: checkdate)
            .get();
        print("done: $checkdate : ${doneDateSnapshot.size}");

        DateFormat englishFormat = DateFormat('MMMM d, yyyy');
        DateTime date = englishFormat.parse(checkdate);

        DateFormat thaiFormat = DateFormat.yMMMMd('th');
        String formattedDate = thaiFormat.format(date);
        int buddhistYear = date.year + 543;

        formattedDate =
            formattedDate.replaceFirst('${date.year}', '$buddhistYear');

        setState(() {
          chartData.add(BarberDateChartData(
              formattedDate,
              bookedDateSnapshot.size,
              cancelledDateSnapshot.size,
              doneDateSnapshot.size));
        });
      }
    } catch (e) {
      print('Error fetching bookings: $e');
    }
  }

  @override
  void initState() {
    _barbersummaryreportData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายงานการจอง'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text("สรุปการจองในแต่ละวันสำหรับช่าง ${widget.barberid}"),
            // for (var entry in bookingDay.entries)
            //   Text("${entry.key}: ${entry.value} การจอง")

            Container(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelRotation: -90,
                ),
                title: ChartTitle(text: 'สรุปการจองในแต่ละวันสำหรับช่าง '),
                legend: Legend(isVisible: true),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<BarberDateChartData, String>>[
                  LineSeries<BarberDateChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (BarberDateChartData data, _) =>
                        data.bookingDate,
                    yValueMapper: (BarberDateChartData data, _) =>
                        data.bookingCount,
                    color: Colors.blue[200],
                    name: 'จอง',
                    dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.auto),
                  ),
                  LineSeries<BarberDateChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (BarberDateChartData data, _) =>
                        data.bookingDate,
                    yValueMapper: (BarberDateChartData data, _) =>
                        data.doneCount,
                    color: Colors.green[200],
                    name: 'สำเร็จ',
                    dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.auto),
                  ),
                  LineSeries<BarberDateChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (BarberDateChartData data, _) =>
                        data.bookingDate,
                    yValueMapper: (BarberDateChartData data, _) =>
                        data.cancelledCount,
                    color: Colors.red[200],
                    name: 'ยกเลิก',
                    dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.auto),
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

class BarberDateChartData {
  final String bookingDate;
  final int bookingCount;
  final int cancelledCount;
  final int doneCount;

  BarberDateChartData(
      this.bookingDate, this.bookingCount, this.cancelledCount, this.doneCount);
}
