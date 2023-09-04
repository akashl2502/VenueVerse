import 'package:VenueVerse/components/Colors.dart';
import 'package:VenueVerse/pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DateCarousel extends StatefulWidget {
  @override
  _DateCarouselState createState() => _DateCarouselState();
}

class _DateCarouselState extends State<DateCarousel> {
  int selectedDateIndex = 0;
  late ScrollController _controller;

  int daysRemainingInCurrentMonth() {
    DateTime now = DateTime.now();
    DateTime firstDayOfNextMonth = DateTime(now.year, now.month + 1, 1);
    DateTime lastDayOfCurrentMonth =
        firstDayOfNextMonth.subtract(Duration(days: 1));
    return lastDayOfCurrentMonth.day - now.day + 10;
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  void swipeToNextDate() {
    if (selectedDateIndex < daysRemainingInCurrentMonth() - 1) {
      setState(() {
        selectedDateIndex++;
      });
      _controller.animateTo((80 * selectedDateIndex).toDouble(),
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  void swipeToPreviousDate() {
    if (selectedDateIndex > 0) {
      setState(() {
        selectedDateIndex--;
      });
      _controller.animateTo((80 * selectedDateIndex).toDouble(),
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 10),
          Text(
            "${DateTime.now().monthName} ${DateTime.now().year}",
            style:
                GoogleFonts.ysabeau(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              if (selectedDateIndex > 0)
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: swipeToPreviousDate,
                ),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ListView.builder(
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      itemCount: daysRemainingInCurrentMonth(),
                      itemBuilder: (context, index) {
                        DateTime currentDate =
                            DateTime.now().add(Duration(days: index));

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDateIndex = index;
                              dateindex = index;
                            });
                          },
                          child: Container(
                            width: 60,
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: selectedDateIndex == index
                                  ? Appcolor.secondgreen
                                  : Appcolor.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currentDate.weekdayName,
                                  style: GoogleFonts.ysabeau(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  currentDate.day.toString(),
                                  style: GoogleFonts.ysabeau(
                                    color: selectedDateIndex == index
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: selectedDateIndex < daysRemainingInCurrentMonth() - 1
                    ? swipeToNextDate
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension DateTimeExtensions on DateTime {
  String get monthName {
    switch (this.month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  String get weekdayName {
    switch (this.weekday) {
      case 1:
        return 'Mo';
      case 2:
        return 'Tu';
      case 3:
        return 'We';
      case 4:
        return 'Th';
      case 5:
        return 'Fr';
      case 6:
        return 'Sa';
      case 7:
        return 'Su';
      default:
        return '';
    }
  }
}
