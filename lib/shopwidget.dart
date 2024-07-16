import 'package:flutter/material.dart';

class ShopWidget extends StatefulWidget {
  const ShopWidget({super.key});

  @override
  State<ShopWidget> createState() => _ShopWidgetState();
}

class _ShopWidgetState extends State<ShopWidget> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      childAspectRatio: 0.68,
      // physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      shrinkWrap: true,
      children: [
        Container(
          padding: EdgeInsets.only(left: 15, right: 15, top: 10),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // children: [
                  //   Container(
                  //     padding: EdgeInsets.all(5),
                  //     decoration: BoxDecoration(
                  //       color: Color(0xFF4c53A5),
                  //       borderRadius: BorderRadius.circular(20),
                  //     ),
                  //   ),
                  // ],
                  ),
              InkWell(
                onTap: () {},
                child: Container(
                  margin: EdgeInsets.all(10),
                  // รูปการจอง ยังไม่ได้ใส่
                  child: Image.asset(
                    "imgbarber/jong.jpg",
                    height: 120,
                    width: 120,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
