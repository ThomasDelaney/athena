import 'package:Athena/utilities/request_manager.dart';
import 'package:flutter/material.dart';
import 'package:Athena/design/athena_icon_data.dart';
import 'package:Athena/design/font_data.dart';
import 'package:Athena/subjects/homework_page.dart';
import 'package:Athena/subjects/materials.dart';
import 'package:Athena/subjects/progress.dart';
import 'package:Athena/subjects/test_results.dart';
import 'package:Athena/subjects/subject.dart';
import 'package:Athena/subjects/add_subject.dart';
import 'virtual_hardback.dart';
import 'package:Athena/subjects/subject_hub.dart';
import 'package:Athena/utilities/theme_check.dart';

//Class to build a subject tile used in the subject hub
class SubjectHubTile extends StatelessWidget {

  SubjectHubTile({Key key, this.subject, this.state, this.fontData, this.iconData, this.cardColour, this.themeColour, this.backgroundColour}) : super(key: key);

  final SubjectHubState state;

  final Subject subject;

  final FontData fontData;
  final AthenaIconData iconData;
  final Color cardColour;
  final Color themeColour;
  final Color backgroundColour;

  final RequestManager requestManager = RequestManager.singleton;

  final smallTileSize = 60.0;
  final hardbackTileSize = 108.5;

  //method to build the tile
  @override
  Widget build(BuildContext context) {
    return new Card(
      margin: EdgeInsets.fromLTRB(20.0*ThemeCheck.orientatedScaleFactor(context), 10.0*ThemeCheck.orientatedScaleFactor(context), 20.0*ThemeCheck.orientatedScaleFactor(context), 10.0*ThemeCheck.orientatedScaleFactor(context)),
      elevation: 3.0,
      color: Color(int.tryParse(subject.colour)),
      child: new Container(
        margin: EdgeInsets.fromLTRB(10.0*ThemeCheck.orientatedScaleFactor(context), 10.0*ThemeCheck.orientatedScaleFactor(context), 10.0*ThemeCheck.orientatedScaleFactor(context), 10.0*ThemeCheck.orientatedScaleFactor(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
              child: Wrap(
                runAlignment: WrapAlignment.spaceBetween,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    subject.name,
                    style: TextStyle(
                        fontSize: 32.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontData.font,
                        color: ThemeCheck.colorCheck(Color(int.tryParse(subject.colour))),
                        fontWeight: FontWeight.bold
                    )
                  ),
                  new Row (
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.edit),
                          iconSize: 30.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                          color: ThemeCheck.colorCheck(Color(int.tryParse(subject.colour))),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddSubject(
                                  subject: subject,
                                  fontData: fontData,
                                  iconData: iconData,
                                  backgroundColour: backgroundColour,
                                  cardColour: cardColour,
                                  themeColour: themeColour
                              ))
                          ).whenComplete(() {
                            state.retrieveData();
                            state.recorder.assignParent(state);
                          })
                      ),
                      IconButton(
                          icon: Icon(Icons.delete),
                          iconSize: 30.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                          color: ThemeCheck.colorCheck(Color(int.tryParse(subject.colour))),
                          onPressed: () => state.deleteSubjectDialog(subject.id, subject.name)
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0*ThemeCheck.orientatedScaleFactor(context),),
            Wrap(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (context) => Materials(subject: subject,))).whenComplete(() {
                            state.retrieveData();
                            state.recorder.assignParent(state);
                          }),
                      child: Card(
                          color: cardColour,
                          elevation: 3.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 7*ThemeCheck.orientatedScaleFactor(context)*fontData.size, vertical: 24*ThemeCheck.orientatedScaleFactor(context)*fontData.size),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(Icons.business_center, size: 26*ThemeCheck.orientatedScaleFactor(context)*iconData.size, color: iconData.color),
                                SizedBox(width: 7.5*ThemeCheck.orientatedScaleFactor(context)),
                                Text("Materials", style: TextStyle(fontSize: 18*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, fontWeight: FontWeight.bold, color: fontData.color)),
                              ],
                            ),
                          )
                      ),
                    ),
                    GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Progress(subject: subject,))).whenComplete(() {
                          state.retrieveData();
                          state.recorder.assignParent(state);
                        }),
                        child: Card(
                            elevation: 3.0,
                            color: cardColour,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 7*ThemeCheck.orientatedScaleFactor(context)*fontData.size, vertical: 24*ThemeCheck.orientatedScaleFactor(context)*fontData.size),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Icon(Icons.insert_chart, size: 26*ThemeCheck.orientatedScaleFactor(context)*iconData.size, color: iconData.color),
                                  SizedBox(width: 7.5*ThemeCheck.orientatedScaleFactor(context)),
                                  Text("Progress", style: TextStyle(fontSize: 18*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, fontWeight: FontWeight.bold, color: fontData.color)),
                                ],
                              ),
                            )
                        )
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TestResults(subject: subject,))).whenComplete(() {
                        state.retrieveData();
                        state.recorder.assignParent(state);
                      }),
                      child: Card(
                          elevation: 3.0,
                          color: cardColour,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 7*ThemeCheck.orientatedScaleFactor(context)*fontData.size, vertical: 24*ThemeCheck.orientatedScaleFactor(context)*fontData.size),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(Icons.school, size: 26*ThemeCheck.orientatedScaleFactor(context)*iconData.size, color: iconData.color),
                                SizedBox(width: 7.5*ThemeCheck.orientatedScaleFactor(context)),
                                Text("Test Results", style: TextStyle(fontSize: 18*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, fontWeight: FontWeight.bold, color: fontData.color)),
                              ],
                            ),
                          )
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomeworkPage(subject: subject,))).whenComplete(() {
                        state.retrieveData();
                        state.recorder.assignParent(state);
                      }),
                      child: Container(
                        child: Card(
                            elevation: 3.0,
                            color: cardColour,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 7*ThemeCheck.orientatedScaleFactor(context)*fontData.size, vertical: 24*ThemeCheck.orientatedScaleFactor(context)*fontData.size),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Icon(Icons.library_books, size: 26*ThemeCheck.orientatedScaleFactor(context)*iconData.size, color: iconData.color),
                                  SizedBox(width: 7.5*ThemeCheck.orientatedScaleFactor(context)),
                                  Text("Homework", style: TextStyle(fontSize: 18*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, fontWeight: FontWeight.bold, color: fontData.color)),
                                ],
                              ),
                            )
                        ),
                      ),
                    ),
                  ],
                ),
                new GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VirtualHardback(subject: subject,))).whenComplete(() {
                      state.retrieveData();
                      state.recorder.assignParent(state);
                    }),
                    child: Container(
                      child: Card(
                        elevation: 3.0,
                          color: cardColour,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 7*ThemeCheck.orientatedScaleFactor(context)*fontData.size, vertical: 24*ThemeCheck.orientatedScaleFactor(context)*fontData.size),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.folder_open, size: 26*ThemeCheck.orientatedScaleFactor(context)*iconData.size, color: iconData.color),
                              SizedBox(width: 7.5*ThemeCheck.orientatedScaleFactor(context)),
                              Text("Hardback", style: TextStyle(fontSize: 18*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, fontWeight: FontWeight.bold, color: fontData.color)),
                            ],
                          ),
                        )
                      ),
                    )
                  ),
              ],
            ),
          ],
        )
      ),
    );
  }
}
