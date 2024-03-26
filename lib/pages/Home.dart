import 'dart:async';

import 'package:com.srec.venueverse/components/Colors.dart';
import 'package:com.srec.venueverse/components/Date.dart';
import 'package:com.srec.venueverse/pages/About.dart';
import 'package:com.srec.venueverse/pages/Labs.dart';
import 'package:com.srec.venueverse/pages/Login.dart';
import 'package:com.srec.venueverse/pages/Privateaccess.dart';
import 'package:com.srec.venueverse/pages/Report.dart';
import 'package:com.srec.venueverse/pages/RequestStatus.dart';
import 'package:com.srec.venueverse/pages/Seminarhall.dart';
import 'package:com.srec.venueverse/pages/Userdetails.dart';
import 'package:com.srec.venueverse/pages/ViewRequests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.srec.venueverse/pages/revertpastrequest.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';
import 'package:google_sign_in/google_sign_in.dart';

// var dateindex = 0;

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
  int dateindexselect = 0;
  List Room = [];
  List Appdata = [];

  final _advancedDrawerController = AdvancedDrawerController();
  @override
  DateTime now = DateTime.now();
  bool _isadmin = false;
  final _auth = FirebaseAuth.instance;
    DateTime cur_date = DateTime.now();

  bool _ismaintance = false;
  void initState() {
    var a = DateFormat('yyyy-MM-dd').format(now);
    Getprebookdata(fordate: a);
    checkadmin();
    getDocumentDetails("dLZjByE0J7D8xpp2Cxa7");
    _controller = ScrollController();

    super.initState();
  }

  void checkadmin() {
    try {
      if (userdet['isadmin'] == true || userdet['SA'] == true) {
        setState(() {
          _isadmin = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getDocumentDetails(String docID) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      setState(() {
        _isloading = true;
      });
      DocumentSnapshot docSnapshot =
          await firestore.collection('deptlist').doc(docID).get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _isloading = false;
          _ismaintance = data['update'];
          print(_ismaintance);
        });
      } else {
        setState(() {
          _isloading = false;
        });
        print('Document does not exist');
      }
    } catch (e) {
      setState(() {
        _isloading = true;
      });
      print('Error retrieving document: $e');
    }
  }

  Future<void> Getprebookdata({fordate}) async {
    print(fordate);
    setState(() {
      _isloading = true;
    });

    CollectionReference _cat = _firestore.collection("request");
    Query query = _cat
        .where("isapproved", isEqualTo: "Approved")
        .where('dor', isEqualTo: fordate);
    QuerySnapshot querySnapshot = await query.get();

    final _docData = querySnapshot.docs.map((doc) => doc.data()).toList();
    List<Map<String, dynamic>> uniqueList = [];
    Set<String> uniqueRids = {};
    print(uniqueRids);
    for (var item in _docData) {
      if (item != null && item is Map<String, dynamic>) {
        if (!uniqueRids.contains(item['rid'])) {
          uniqueRids.add(item['rid']);
          uniqueList.add(item);
        }
      }
    }

    setState(() {
      Appdata = uniqueList;
      print(uniqueList);
      _isloading = false;
    });
  }

  int selectedDateIndex = 0;
  late ScrollController _controller;

  int daysRemainingInCurrentMonth() {
    DateTime now = DateTime.now();
    DateTime firstDayOfNextMonth = DateTime(now.year, now.month + 1, 1);
    DateTime lastDayOfCurrentMonth =
        firstDayOfNextMonth.subtract(Duration(days: 1));
    return lastDayOfCurrentMonth.day - now.day + 300;
  }

  void swipeToNextDate() {
    if (selectedDateIndex < daysRemainingInCurrentMonth() - 1) {
      setState(() {
        selectedDateIndex++;
      });
      Getprebookdata(fordate: Getformateddate(dateindex: selectedDateIndex));
      final centerOffset = (80 * selectedDateIndex) -
          (_controller.position.viewportDimension / 2);

      _controller.animateTo(
        centerOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void swipeToPreviousDate() {
    if (selectedDateIndex > 0) {
      setState(() {
        selectedDateIndex--;
      });
      Getprebookdata(fordate: Getformateddate(dateindex: selectedDateIndex));

      final centerOffset = (80 * selectedDateIndex) -
          (_controller.position.viewportDimension / 2);

      _controller.animateTo(
        centerOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Widget daterefactor() {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 10),
          Text(
            "${cur_date.monthName} ${cur_date.year}",
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
                            Getprebookdata(
                                fordate: Getformateddate(dateindex: index));
                            setState(() {
                              selectedDateIndex = index;
                              dateindexselect = index;
                              cur_date = currentDate;
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
                                  currentDate.monthName.substring(0, 3),
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

  @override
  List<String> valuesDataUrls = [
    "https://srecspark.org/themes/images/home/home-11.jpg",
    "https://www.darshan.ac.in/U01/Page/51---08-06-2021-10-58-50.png"
  ];
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
            actions: [
              IconButton(
                  onPressed: () async {
                    await _auth.signOut().then((value) async {
                      await GoogleSignIn().signOut().then((value) {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => Login()));
                      });
                    });
                  },
                  icon: Icon(Icons.login_outlined))
            ],
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
                              child: daterefactor(),
                            ),
                          ),
                          _isloading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Appcolor.secondgreen,
                                  ),
                                )
                              : Column(
                                  children: [
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
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
                                    Appdata.length != 0
                                        ? Text(
                                            'Booked Venues',
                                            style: GoogleFonts.ysabeau(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                            ),
                                          )
                                        : Container(),
                                    Appdata.length != 0
                                        ? SizedBox(
                                            height: 20,
                                          )
                                        : Container(),
                                    Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: Appdata.map((e) {
                                          return Bookedvenuerefactor(
                                            date: e['dor'],
                                            rid: e['rid'],
                                            height: height,
                                            width: width,
                                            name: e['RN'],
                                          );
                                        }).toList())
                                  ],
                                )
                          // Uncomment this if you want to display the date:
                          // Text(
                          //   '${date != null ? "${date!.day}-${date!.month}-${date!.year}" : "No selection yet."}',
                          //   style: Theme.of(context).textTheme.headlineMedium,
                          // ),
                          ,
                          _ismaintance ? MaintenanceTextCarousel() : Container()
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
                _isadmin
                    ? ListTile(
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
                      )
                    : Container(),
                _isadmin
                    ? ListTile(
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
                      )
                    : Container(),
                _isadmin
                    ? ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rotate,
                              child: ReportPage(),
                              alignment: Alignment.topCenter,
                              isIos: true,
                              duration: Duration(milliseconds: 500),
                            ),
                          );
                        },
                        leading: Icon(Icons.file_copy),
                        title: Text('Report'),
                      )
                    : Container(),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rotate,
                        child: Aboutpage(),
                        alignment: Alignment.topCenter,
                        isIos: true,
                        duration: Duration(milliseconds: 500),
                      ),
                    );
                  },
                  leading: Icon(Icons.info),
                  title: Text('About'),
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

  String Getformateddate({dateindex}) {
    DateTime dateTime = DateTime.now().add(Duration(days: dateindex));
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDate;
  }

  void _onSeminarHallPressed() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rotate,
        child: Seminarhall(
            Selectdate: Getformateddate(dateindex: dateindexselect)),
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
        child: Labs(Selectdate: Getformateddate(dateindex: dateindexselect)),
        alignment: Alignment.topCenter,
        isIos: true,
        duration: Duration(milliseconds: 500),
      ),
    );
  }
}

class Bookedvenuerefactor extends StatelessWidget {
  const Bookedvenuerefactor(
      {super.key,
      required this.height,
      required this.width,
      required this.name,
      required this.date,
      required this.rid});
  final name;
  final double height;
  final double width;
  final rid;
  final date;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Reverpastviewrequest("widget.docid", date, rid, true)));
          },
          child: Container(
              height: height * 0.08,
              width: width * 1,
              decoration: BoxDecoration(
                color: Appcolor.grey,
                borderRadius: BorderRadius.circular(10.0),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.home,
                    color: Appcolor.firstgreen,
                  ),
                  Container(
                    width: width * 0.4,
                    child: Text(
                      name,
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
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
              )),
        ));
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

class MaintenanceTextCarousel extends StatefulWidget {
  @override
  _MaintenanceTextCarouselState createState() =>
      _MaintenanceTextCarouselState();
}

class _MaintenanceTextCarouselState extends State<MaintenanceTextCarousel> {
  final List<String> maintenanceMessages = [
    'App is under maintenance...',
    'Maintenance in progress...',
    'Please wait for a moment...',
    'Thank you for your patience...',
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % maintenanceMessages.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50.0,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(seconds: 1),
            curve: Curves.easeInOut,
            left: -(_currentIndex * MediaQuery.of(context).size.width),
            child: Row(
              children: maintenanceMessages.map((message) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Appcolor.secondgreen,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 2,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
