import 'request_manager.dart';
import 'package:flutter/material.dart';
import 'recording_manager.dart';
import 'add_tag.dart';
import 'font_settings.dart';
import 'tag.dart';

class TagManager extends StatefulWidget {

  TagManager({Key key}) : super(key: key);

  @override
  _TagManagerState createState() => _TagManagerState();
}

class _TagManagerState extends State<TagManager> {

  RequestManager requestManager = RequestManager.singleton;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  List<Tag> tagList = new List<Tag>();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool tagsLoaded = false;
  bool submitting = false;
  String font = "";

  @override
  void initState() {
    retrieveData();
    super.initState();
  }

  void retrieveData() {
    tagsLoaded = false;
    tagList.clear();
    getTags();
  }

  @override
  Widget build(BuildContext context) {

    ListView tList;

    if (tagList.length == 0 && tagsLoaded) {
      tList = new ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          new Container(
              margin: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: new SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                child: new Card(
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text("Add Tags By Using the", textAlign: TextAlign.center, style: TextStyle(fontFamily: font, fontSize: 24.0), ),
                        new SizedBox(height: 10.0,),
                        new Icon(Icons.add_circle, size: 40.0, color: Colors.grey,),
                      ]
                  ),
                ),
              )
          ),
        ],
      );
    }
    else {
      tList = ListView.builder(
        itemCount: tagList.length,
        itemBuilder: (context, position) {
          return GestureDetector(
              onLongPress: () => {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 10.0),
                  Card(
                    margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    elevation: 3.0,
                    child: new ListTile(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddTag(tag: tagList[position],))).whenComplete(retrieveData),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                        leading: Container(
                          padding: EdgeInsets.only(right: 12.0),
                          decoration: new BoxDecoration(
                              border: new Border(right: new BorderSide(width: 1.0, color: Colors.white24))
                          ),
                          child: Icon(Icons.local_offer, color: Colors.redAccent, size: 32.0,),
                        ),
                        title: Text(
                          tagList[position].tag,
                          style: TextStyle(fontSize: 24.0, fontFamily: font),
                        ),
                        trailing: GestureDetector(
                            child: Icon(Icons.delete, size: 32.0, color: Color.fromRGBO(70, 68, 71, 1)),
                            onTap: () => deleteTagDialog(tagList[position])
                        ),
                      )
                  )
                ],
              )
          );
        },
      );
    }

    return Stack(
      children: <Widget>[
        Scaffold(
            key: _scaffoldKey,
            //drawer for the settings, can be accessed by swiping inwards from the right hand side of the screen or by pressing the settings icon
            endDrawer: new Drawer(
              child: ListView(
                //Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  //drawer header
                  DrawerHeader(
                    child: Text('Settings',
                        style: TextStyle(fontSize: 25.0, fontFamily: font)),
                    decoration: BoxDecoration(
                      color: Colors.red,
                    ),
                  ),
                  //fonts option
                  ListTile(
                    leading: Icon(Icons.font_download),
                    title: Text('Fonts',
                        style: TextStyle(fontSize: 20.0, fontFamily: font)),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => FontSettings()));
                    },
                  ),
                  //sign out option
                  ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Sign Out',
                        style: TextStyle(fontSize: 20.0, fontFamily: font)),
                    onTap: () {
                      //signOut();
                    },
                  ),
                ],
              ),
            ),
            appBar: new AppBar(
              title: new Text("Tags", style: TextStyle(fontFamily: font),),
              //if recording then just display an X icon in the app bar, which when pressed will stop the recorder
              actions: recorder.recording ? <Widget>[
                // action button
                IconButton(
                  icon: Icon(Icons.close),
                  iconSize: 30.0,
                  onPressed: () {
                    setState(() {
                      recorder.cancelRecording();
                    });
                  },
                ),
              ] : <Widget>[
                IconButton(
                  icon: Icon(Icons.add_circle),
                  iconSize: 30.0,
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddTag()))
                      .whenComplete(retrieveData),
                ),
                // else display the mic button and settings button
                IconButton(
                  icon: Icon(Icons.mic),
                  iconSize: 30.0,
                  onPressed: () {
                    setState(() {
                      recorder.recordAudio(context);
                    });
                  },
                ),
                Builder(
                  builder: (context) =>
                      IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      ),
                ),
              ],
            ),
            body: new Stack(
              children: <Widget>[
                new Center(
                  child: tagsLoaded ? tList : new SizedBox(width: 50.0,
                      height: 50.0,
                      child: new CircularProgressIndicator(strokeWidth: 5.0,)),
                ),
                new Container(
                    child: recorder.recording ?
                    new Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        new Container(
                            child: new ModalBarrier(
                              color: Colors.black54, dismissible: false,)),
                        recorder.drawRecordingCard(context)
                      ],) : new Container()
                ),
              ],
            )

        ),
        submitting ? new Stack(
          alignment: Alignment.center,
          children: <Widget>[
            new Container(
                child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,))
          ],
        )
            : new Container()
      ],
    );
  }

  void getTags() async {
    List<Tag> reqTags = await requestManager.getTags();
    this.setState(() {
      tagList = reqTags;
      tagsLoaded = true;
    });
  }

  void deleteTag(Tag tag) async {
    var response = await requestManager.deleteTag(tag);

    //if null, then the request was a success, retrieve the information
    if (response == "success") {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Tag Deleted!')));
      retrieveData();
    }
    //else the response ['response']  is not null, then print the error message
    else {
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        content: new Text("An error has occured please try again"),
        actions: <Widget>[
          new FlatButton(onPressed: () {
            Navigator.pop(context); /*submit(false);*/
          }, child: new Text("OK"))
        ],
      );

      showDialog(context: context,
          barrierDismissible: true,
          builder: (_) => responseDialog);
    }
  }

  void deleteTagDialog(Tag tag) {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text(
        "Do you want to DELETE this TAG? All files with this Tag will have no Tag", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () {
          Navigator.pop(context);
        }, child: new Text("NO", style: TextStyle(
          fontSize: 18.0, fontWeight: FontWeight.bold,),)),
        new FlatButton(onPressed: () async {
          Navigator.pop(context);
          submit(true);
          await deleteTag(tag);
          submit(false);
        },
            child: new Text("YES",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context,
        barrierDismissible: false,
        builder: (_) => areYouSure);
  }

  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }
}
