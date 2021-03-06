import 'package:Athena/design/background_settings.dart';
import 'package:Athena/design/card_settings.dart';
import 'package:Athena/design/dyslexia_friendly_settings.dart';
import 'package:Athena/timetables/add_timeslot.dart';
import 'package:Athena/timetables/timetable_slot.dart';
import 'package:Athena/utilities/recording_manager.dart';
import 'package:Athena/utilities/request_manager.dart';
import 'package:Athena/utilities/sign_out.dart';
import 'package:Athena/design/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:Athena/design/athena_icon_data.dart';
import 'package:Athena/design/font_data.dart';
import 'package:Athena/design/font_settings.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/design/icon_settings.dart';
import 'package:Athena/subjects/materials.dart';
import 'package:Athena/subjects/subject.dart';
import 'package:Athena/tags/tag_manager.dart';
import 'package:Athena/utilities/theme_check.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Widget that displays the users timetable information
class TimetablePage extends StatefulWidget 
{
  TimetablePage({Key key, this.initialDay}) : super(key: key);

  //initial day, will be the current day if not accessed via voice command, where day could be specified
  final String initialDay;
  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {

  RequestManager requestManager = RequestManager.singleton;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  //list of weekdays
  List<String> weekdays = const <String>["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];

  bool slotsLoaded = false;

  bool submitting = false;

  //map is "weekday", list of timeslot objects for that weekday
  Map<String, List<TimetableSlot>> timeslots = new Map<String, List<TimetableSlot>>();

  FontData fontData;
  bool fontLoaded = false;

  bool iconLoaded = false;
  AthenaIconData iconData;

  bool cardColourLoaded = false;
  bool backgroundColourLoaded = false;
  bool themeColourLoaded = false;

  Color themeColour;
  Color backgroundColour;
  Color cardColour;

  void getFontData() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (this.mounted) {
      this.setState(() {
        fontLoaded = true;
        fontData = new FontData(
            prefs.getString("font"), Color(prefs.getInt("fontColour")),
            prefs.getDouble("fontSize"));
      });
    }
  }

  void getCardColour() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (this.mounted) {
      this.setState(() {
        cardColourLoaded = true;
        cardColour = Color(prefs.getInt("cardColour"));
      });
    }
  }

  void getBackgroundColour() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (this.mounted) {
      this.setState(() {
        backgroundColourLoaded = true;
        backgroundColour = Color(prefs.getInt("backgroundColour"));
      });
    }
  }

  void getThemeColour() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (this.mounted) {
      this.setState(() {
        themeColourLoaded = true;
        themeColour = Color(prefs.getInt("themeColour"));
      });
    }
  }

  void getIconData() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (this.mounted) {
      this.setState(() {
        iconLoaded = true;
        iconData = new AthenaIconData(
            Color(prefs.getInt("iconColour")),
            prefs.getDouble("iconSize"));
      });
    }
  }

  //method to get all timeslots
  void getTimeslots() async {
    Map<String, List<TimetableSlot>> reqTimeslots = await requestManager.getTimeslots();

    this.setState(() {
      timeslots = reqTimeslots;
      slotsLoaded = true;
    });
  }

  void retrieveData() async {
    iconLoaded = false;
    slotsLoaded = false;
    fontLoaded = false;
    timeslots.clear();

    getBackgroundColour();
    getThemeColour();
    getCardColour();

    cardColourLoaded = false;
    backgroundColourLoaded = false;
    themeColourLoaded = false;

    getIconData();
    getTimeslots();
    getFontData();
  }

  @override
  void initState() {
    recorder.assignParent(this);
    retrieveData();
    super.initState();
  }

  @override
  void didUpdateWidget(TimetablePage oldWidget) {
    recorder.assignParent(this);
    super.didUpdateWidget(oldWidget);
  }

  //method to build the timetable page
  @override
  Widget build(BuildContext context)
  {
    return Container(
      color: themeColour,
      //tab controller widget allows you to tab between the different days
      child: DefaultTabController(
        //start the user on the initial day
        initialIndex: weekdays.indexOf(widget.initialDay),
        length: weekdays.length,
        child: Stack(
          children: <Widget>[
            Scaffold(
                key: _scaffoldKey,
                backgroundColor: backgroundColourLoaded ? backgroundColour : Colors.white,
                endDrawer: fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && slotsLoaded ?
                new SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: new Drawer(
                    child: new Container(
                      color: cardColour,
                      child: ListView(
                        //Remove any padding from the ListView.
                        padding: EdgeInsets.zero,
                        children: <Widget>[
                          //drawer header
                          DrawerHeader(
                            child: Text('Settings', style: TextStyle(fontSize: 25.0*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontLoaded ? fontData.font : "", color: themeColourLoaded ? ThemeCheck.colorCheck(themeColour) : Colors.white)),
                            decoration: BoxDecoration(
                              color: themeColour,
                            ),
                          ),
                          //fonts option
                          ListTile(
                            leading: Icon(
                              Icons.font_download,
                              size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                              color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                            ),
                            title: Text(
                                'Fonts',
                                style: TextStyle(
                                  fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                                  fontFamily: fontLoaded ? fontData.font : "",
                                  color: fontLoaded ? fontData.color : Colors.black,
                                )
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => FontSettings())).whenComplete((){
                                Navigator.pop(context);
                                retrieveData();
                                recorder.assignParent(this);
                              });
                            },
                          ),
                          new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                          ListTile(
                            leading: Icon(
                              Icons.insert_emoticon,
                              size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 24.0,
                              color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                            ),
                            title: Text(
                                'Icons',
                                style: TextStyle(
                                  fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                                  fontFamily: fontLoaded ? fontData.font : "",
                                  color: fontLoaded ? fontData.color : Colors.black,
                                )
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => IconSettings())).whenComplete((){
                                Navigator.pop(context);
                                retrieveData();
                                recorder.assignParent(this);
                              });
                            },
                          ),
                          new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                          ListTile(
                            leading: Icon(
                              Icons.color_lens,
                              size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                              color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                            ),
                            title: Text(
                                'Theme Colour',
                                style: TextStyle(
                                  fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                                  fontFamily: fontLoaded ? fontData.font : "",
                                  color: fontLoaded ? fontData.color : Colors.black,
                                )
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ThemeSettings(
                                backgroundColour: backgroundColourLoaded ? backgroundColour : Colors.white,
                                cardColour: cardColourLoaded ? cardColour : Colors.white,
                                fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0),
                                iconData: iconLoaded ? iconData : new AthenaIconData(Colors.black, 24.0),
                              ))).whenComplete((){
                                Navigator.pop(context);
                                retrieveData();
                                recorder.assignParent(this);
                              });
                            },
                          ),
                          new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                          ListTile(
                            leading: Icon(
                              Icons.format_paint,
                              size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                              color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                            ),
                            title: Text(
                                'Background Colour',
                                style: TextStyle(
                                  fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                                  fontFamily: fontLoaded ? fontData.font : "",
                                  color: fontLoaded ? fontData.color : Colors.black,
                                )
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => BackgroundSettings(
                                cardColour: cardColourLoaded ? cardColour : Colors.white,
                                fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0),
                                themeColour: themeColourLoaded ? themeColour : Colors.white,
                                iconData: iconLoaded ? iconData : new AthenaIconData(Colors.black, 24.0),
                              ))).whenComplete((){
                                Navigator.pop(context);
                                retrieveData();
                                recorder.assignParent(this);
                              });
                            },
                          ),
                          new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                          ListTile(
                            leading: Icon(
                              Icons.colorize,
                              size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                              color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                            ),
                            title: Text(
                                'Card Colour',
                                style: TextStyle(
                                  fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                                  fontFamily: fontLoaded ? fontData.font : "",
                                  color: fontLoaded ? fontData.color : Colors.black,
                                )
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CardSettings(
                                fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0),
                                themeColour: themeColourLoaded ? themeColour : Colors.white,
                                backgroundColour: backgroundColourLoaded ? backgroundColour : Colors.white,
                                iconData: iconLoaded ? iconData : new AthenaIconData(Colors.black, 24.0),
                              ))).whenComplete((){
                                Navigator.pop(context);
                                retrieveData();
                                recorder.assignParent(this);
                              });
                            },
                          ),
                          new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                          ListTile(
                            leading: Icon(
                              Icons.invert_colors,
                              size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                              color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                            ),
                            title: Text(
                                'Dyslexia Friendly Mode',
                                style: TextStyle(
                                  fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                                  fontFamily: fontLoaded ? fontData.font : "",
                                  color: fontLoaded ? fontData.color : Colors.black,
                                )
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DyslexiaFriendlySettings())).whenComplete((){
                                Navigator.pop(context);
                                retrieveData();
                                recorder.assignParent(this);
                              });
                            },
                          ),
                          new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                          ListTile(
                            leading: Icon(
                              Icons.local_offer,
                              size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 24.0,
                              color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                            ),
                            title: Text(
                                'Tags',
                                style: TextStyle(
                                  fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                                  fontFamily: fontLoaded ? fontData.font : "",
                                  color: fontLoaded ? fontData.color : Colors.black,
                                )
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TagManager())).whenComplete((){
                                Navigator.pop(context);
                                retrieveData();
                                recorder.assignParent(this);
                              });
                            },
                          ),
                          new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                          //sign out option
                          ListTile(
                            leading: Icon(
                              Icons.exit_to_app,
                              size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 24.0,
                              color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),),
                            title: Text(
                                'Sign Out',
                                style: TextStyle(
                                  fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                                  fontFamily: fontLoaded ? fontData.font : "",
                                  color: fontLoaded ? fontData.color : Colors.black,
                                )
                            ),
                            onTap: () => SignOut.signOut(context, fontData, cardColour, themeColour),
                          ),
                        ],
                      ),
                    ),
                  ),
                ) : new Container(),
                appBar: AppBar(
                  iconTheme: IconThemeData(
                      color: themeColourLoaded ? ThemeCheck.colorCheck(themeColour) : Colors.white
                  ),
                  backgroundColor: themeColourLoaded ? themeColour : Color.fromRGBO(113, 180, 227, 1),
                  title: Text('Timetables', style: TextStyle(fontFamily: fontLoaded ? fontData.font : "", color: themeColourLoaded ? ThemeCheck.colorCheck(themeColour) : Colors.white)),
                  //tab bar implements the drawing and navigation between tabs
                  actions: recorder.recording ? <Widget>[
                    // action button
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          recorder.cancelRecording();
                        });
                      },
                    ),
                  ] : <Widget>[
                    // else display the mic button and settings button
                    fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && slotsLoaded ? IconButton(
                        icon: Icon(Icons.home),
                        onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false)
                    ) : new Container(),
                    fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && slotsLoaded ? IconButton(
                      icon: Icon(Icons.mic),
                      onPressed: () {
                        setState(() {
                          recorder.recordAudio();
                        });
                      },
                    ) : new Container(),
                    fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && slotsLoaded ? Builder(
                      builder: (context) =>
                          IconButton(
                            icon: Icon(Icons.settings),
                            onPressed: () => Scaffold.of(context).openEndDrawer(),
                          ),
                    ) : new Container(),
                  ],
                  bottom: TabBar(
                    indicatorWeight: 5*ThemeCheck.orientatedScaleFactor(context),
                    unselectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: fontLoaded ? fontData.font : ""
                    ),
                    indicatorColor: themeColourLoaded ? ThemeCheck.lightColorOfColor(themeColour) : ThemeCheck.colorCheck(Color.fromRGBO(113, 180, 227, 1)),
                    labelColor: themeColourLoaded ? ThemeCheck.colorCheck(themeColour) : ThemeCheck.colorCheck(Color.fromRGBO(113, 180, 227, 1)),
                    labelStyle: TextStyle(
                      fontSize: 16*ThemeCheck.orientatedScaleFactor(context),
                      fontWeight: FontWeight.bold,
                      color: ThemeCheck.colorCheck(themeColourLoaded ? ThemeCheck.lightColorOfColor(themeColour) : ThemeCheck.colorCheck(Color.fromRGBO(113, 180, 227, 1))),
                      fontFamily: fontLoaded ? fontData.font : ""
                    ),
                    isScrollable: true,
                    labelPadding: EdgeInsets.fromLTRB(12.5, 0.0, 12.5, 0.0),
                    tabs: weekdays.map((String day) {
                      return Tab(
                        text: day,
                      );
                    }).toList(),
                  ),
                ),
                //body of the tab
                body: new Stack(
                  children: <Widget>[
                    new Center(
                      child: TabBarView(
                        children: weekdays.map((String day) {
                          return Padding(
                              padding: slotsLoaded ? EdgeInsets.all(16.0) : EdgeInsets.zero,
                              child: slotsLoaded ? TimeslotCard(
                                  fontData: fontData,
                                  iconData: iconData,
                                  cardColour: cardColour,
                                  themeColour: themeColour,
                                  backgroundColour: backgroundColour,
                                  subjectList: timeslots[day],
                                  day: day,
                                  pageState: this
                              ) :
                              new Center(
                                child: new Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      new Container(
                                          margin: MediaQuery.of(context).viewInsets,
                                          child: new Stack(
                                              alignment: Alignment.center,
                                              children: <Widget>[
                                                new Container(
                                                  child: Image.asset("assets/icon/icon3.png", width: 200*ThemeCheck.orientatedScaleFactor(context), height: 200*ThemeCheck.orientatedScaleFactor(context),),
                                                ),
                                                new ModalBarrier(color: Colors.black54, dismissible: false,),
                                              ]
                                          )
                                      ),
                                      new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.white),))
                                    ]
                                ),
                              )
                          );
                        }).toList(),
                      ),
                    ),
                    new Container(
                        child: recorder.recording ?
                        new Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            new Container(
                                child: new ModalBarrier(
                                  color: Colors.black54, dismissible: false,)),
                            recorder.drawRecordingCard(context, fontData, cardColour, themeColour, iconData, backgroundColour)
                          ],) : new Container()
                    ),
                  ],
                )
            ),
            submitting ? new Stack(
              alignment: Alignment.center,
              children: <Widget>[
                new Container(
                    child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              ],
            ) : new Container()
          ],
        )
      ),
    );
  }

  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }
}

//widget for a day
class TimeslotCard extends StatelessWidget {
  const TimeslotCard({Key key, this.fontData, this.iconData, this.subjectList, this.day, this.pageState, this.themeColour, this.cardColour, this.backgroundColour}) : super(key: key);

  final FontData fontData;
  final AthenaIconData iconData;

  final Color cardColour;
  final Color backgroundColour;
  final Color themeColour;

  final List<TimetableSlot> subjectList;

  final _TimetablePageState pageState;

  final String day;

  //build a page for a day
  @override
  Widget build(BuildContext context) {

    if (subjectList == null) {
      return new Column(
        children: <Widget>[
          new SizedBox(height: 10.0),
          IconButton(
            alignment: Alignment.center,
            icon: Icon(Icons.add_circle),
            iconSize: 42.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
            color: iconData.color,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddTimeslot(
                day: day,
                iconData: iconData,
                fontData: fontData,
                backgroundColour: backgroundColour,
                themeColour: themeColour,
                cardColour: cardColour,
            ))).whenComplete(() => pageState.retrieveData()),
          )
        ],
      );
    }
    else {
      return Center(
      //build list of timeslot data
        child: ListView.builder(
          itemCount: subjectList.length,
          itemBuilder: (context, position) {
            return new Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddTimeslot(
                      day: day, currentTimeslot: subjectList[position],
                      lastTime: subjectList.length == 1 ? null : position == 0 ? "00:00" : subjectList[position-1].time,
                      fontData: fontData,
                      iconData: iconData,
                      backgroundColour: backgroundColour,
                      themeColour: themeColour,
                      cardColour: cardColour,
                    )
                  )).whenComplete(() => pageState.retrieveData()),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                        color: cardColour,
                        margin: new EdgeInsets.symmetric(vertical: 6.0),
                        elevation: 3.0,
                        //display a slot in a list tile
                        child: new Container(
                          padding: new EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: new Column(
                                    //alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        //subject time
                                        subjectList[position].time + periodOfDay(
                                            TimeOfDay(hour: int.tryParse(subjectList[position].time.split(':')[0]), minute: int.tryParse(subjectList[position].time.split(':')[1]))
                                        ),
                                        style: TextStyle(fontSize: 24*ThemeCheck.orientatedScaleFactor(context)*fontData.size, fontFamily: fontData.font, color: fontData.color, fontWeight: FontWeight.bold),
                                      ),
                                      new Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                              subjectList[position].subjectTitle,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size,
                                                  fontFamily: fontData.font,
                                                  color: Color(int.tryParse(subjectList[position].colour))
                                              )
                                          ),
                                          new SizedBox(height: 10.0),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Icon(Icons.location_on, color: iconData.color, size: 22*ThemeCheck.orientatedScaleFactor(context)*iconData.size,),
                                              SizedBox(width: 5.0*ThemeCheck.orientatedScaleFactor(context),),
                                              Flexible(
                                                  child: Text(
                                                    subjectList[position].room,
                                                    style: TextStyle(fontSize: 22.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size, fontFamily: fontData.font, color: fontData.color),
                                                  )
                                              ),
                                            ],
                                          ),
                                          new SizedBox(height: 10.0),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Icon(Icons.face, color: iconData.color, size: 22*ThemeCheck.orientatedScaleFactor(context)*iconData.size,),
                                              SizedBox(width: 5.0*ThemeCheck.orientatedScaleFactor(context),),
                                              Flexible(
                                                child: Text(
                                                  subjectList[position].teacher,
                                                  style: TextStyle(fontSize: 22.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size, fontFamily: fontData.font, color: fontData.color),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ]
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.business_center),
                                alignment: Alignment.center,
                                iconSize: 35*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                                color: iconData.color,
                                onPressed: ()
                                async {
                                  pageState.submit(true);
                                  Subject subject = await Subject.getSubjectByTitle(subjectList[position].subjectTitle);
                                  pageState.submit(false);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Materials(
                                      subject: subject,
                                  )));
                                },
                              ),
                            ],
                          )
                        )
                    ),
                  ),
                ),
                position == subjectList.length-1 ?
                new Column(
                  children: <Widget>[
                    new SizedBox(height: 10.0),
                    IconButton(
                      icon: Icon(Icons.add_circle),
                      alignment: Alignment.center,
                      color: iconData.color,
                      iconSize: 42.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
                        AddTimeslot(
                            day: day,
                            lastTime: subjectList[subjectList.length-1].time,
                            fontData: fontData,
                            iconData: iconData,
                            backgroundColour: backgroundColour,
                            themeColour: themeColour,
                            cardColour: cardColour,
                        ))).whenComplete(() => pageState.retrieveData()),
                    )
                  ],
               ) : new Container()
             ],
            );
          },
        )
      );
    }
  }

  //method to get the period of a day via a TimeOfDay object
  String periodOfDay(TimeOfDay timeOfDay) {
    if (timeOfDay.period == DayPeriod.am) {
      return "am";
    }
    else {
      return "pm";
    }
  }
}
