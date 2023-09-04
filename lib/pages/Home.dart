import 'package:VenueVerse/components/Colors.dart';
import 'package:VenueVerse/components/Date.dart';
import 'package:VenueVerse/pages/Labs.dart';
import 'package:VenueVerse/pages/Privateaccess.dart';
import 'package:VenueVerse/pages/RequestStatus.dart';
import 'package:VenueVerse/pages/Seminarhall.dart';
import 'package:VenueVerse/pages/ViewRequests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';

var dateindex = 0;

class Home extends StatefulWidget {
  const Home({required this.uid});
  final uid;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  DateTime? date;
  bool _isloading = true;
  List Room = [];
  final _advancedDrawerController = AdvancedDrawerController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    List<String> valuesDataUrls = [
      "https://srecspark.org/themes/images/home/home-11.jpg",
      "https://www.darshan.ac.in/U01/Page/51---08-06-2021-10-58-50.png"
    ];

    List<Widget> valuesWidget = [];
    for (int i = 0; i < valuesDataUrls.length; i++) {
      valuesWidget.add(
        InkWell(
          onTap: () {
            if (i == 0) {
              _onSeminarHallPressed();
            } else if (i == 1) {
              _onLabsPressed();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              image: DecorationImage(
                image: NetworkImage(valuesDataUrls[i]),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    i == 0 ? 'Seminar Hall' : (i == 1 ? 'Labs' : ''),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ysabeau(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 3.0,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AdvancedDrawer(
      backdrop: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Appcolor.firstgreen,
              Appcolor.secondgreen.withOpacity(0.5)
            ],
          ),
        ),
      ),
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: true,
      childDecoration: const BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Home",
              style: GoogleFonts.ysabeau(
                letterSpacing: 1.0,
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              onPressed: _handleMenuButtonPressed,
              icon: ValueListenableBuilder<AdvancedDrawerValue>(
                valueListenable: _advancedDrawerController,
                builder: (_, value, __) {
                  return AnimatedSwitcher(
                    duration: Duration(milliseconds: 250),
                    child: Icon(
                      value.visible ? Icons.clear : Icons.menu,
                      key: ValueKey<bool>(value.visible),
                    ),
                  );
                },
              ),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Appcolor.secondgreen,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          key: _scaffoldKey,
          body: SafeArea(
            child: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: viewportConstraints.maxHeight * 0.32,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DateCarousel(),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Check Available Venues',
                              style: GoogleFonts.ysabeau(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: valuesWidget.map((widget) {
                              return Container(
                                width: width * 0.4,
                                height: height * 0.15,
                                child: widget,
                              );
                            }).toList(),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            'Booked Venues',
                            style: GoogleFonts.ysabeau(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Container(
                                      height: height * 0.08,
                                      width: width * 1,
                                      decoration: BoxDecoration(
                                        color: Appcolor.grey,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Icon(
                                            Icons.home,
                                            color: Appcolor.firstgreen,
                                          ),
                                          Container(
                                            width: width * 0.4,
                                            child: Text(
                                              "IT Seminar Hall ",
                                              style: GoogleFonts.ysabeau(
                                                fontSize: 18,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            height: height * 0.04,
                                            width: width * 0.25,
                                            decoration: BoxDecoration(
                                              color: Appcolor.secondgreen,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.check,
                                                  size: 15,
                                                ),
                                                SizedBox(width: 5.0),
                                                Text(
                                                  "Booked",
                                                  style: GoogleFonts.ysabeau(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ))),
                            ],
                          )

                          // Uncomment this if you want to display the date:
                          // Text(
                          //   '${date != null ? "${date!.day}-${date!.month}-${date!.year}" : "No selection yet."}',
                          //   style: Theme.of(context).textTheme.headlineMedium,
                          // ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )),
      drawer: SafeArea(
        child: Container(
          child: ListTileTheme(
            textColor: Colors.white,
            iconColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 128.0,
                  height: 128.0,
                  margin: const EdgeInsets.only(
                    top: 24.0,
                    bottom: 64.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Image.network(
                    'https://yt3.googleusercontent.com/JcKgUmXA2doPrBee8CgGhnWWc6iZNFuyQk0MMzXUWnX_o6fmhediLHVvGZ419G7Kq-_8GQMn8m0=s900-c-k-c0x00ffffff-no-rj',
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rotate,
                        child: Home(uid: widget.uid),
                        alignment: Alignment.topCenter,
                        isIos: true,
                        duration: Duration(milliseconds: 500),
                      ),
                    );
                  },
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rotate,
                        child: Request(),
                        alignment: Alignment.topCenter,
                        isIos: true,
                        duration: Duration(milliseconds: 500),
                      ),
                    );
                  },
                  leading: Icon(Icons.check),
                  title: Text('Request Status'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rotate,
                        child: Viewrequests(),
                        alignment: Alignment.topCenter,
                        isIos: true,
                        duration: Duration(milliseconds: 500),
                      ),
                    );
                  },
                  leading: Icon(Icons.remove_red_eye),
                  title: Text('View Requests'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rotate,
                        child: Private(),
                        alignment: Alignment.topCenter,
                        isIos: true,
                        duration: Duration(milliseconds: 500),
                      ),
                    );
                  },
                  leading: Icon(Icons.settings),
                  title: Text('Private Access'),
                ),
                Spacer(),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 16.0,
                    ),
                    child: Text('Terms of Service | Privacy Policy'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }

  String Getformateddate() {
    DateTime dateTime = DateTime.now().add(Duration(days: dateindex));
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDate;
  }

  void _onSeminarHallPressed() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rotate,
        child: Seminarhall(Selectdate: Getformateddate()),
        alignment: Alignment.topCenter,
        isIos: true,
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  void _onLabsPressed() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rotate,
        child: Labs(Selectdate: Getformateddate()),
        alignment: Alignment.topCenter,
        isIos: true,
        duration: Duration(milliseconds: 500),
      ),
    );
  }
}
