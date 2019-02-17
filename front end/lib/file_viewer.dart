import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:my_school_life_prototype/request_manager.dart';
import 'package:my_school_life_prototype/theme_check.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'video_manager.dart';
import 'audio_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'filetype_manager.dart';
import 'subject_file.dart';
import 'tag.dart';
import 'subject.dart';

//Widget that displays an interactive file list
class FileViewer extends StatefulWidget
{
  FileViewer({Key key, this.list, this.i, this.subject, this.fromTagMap}) : super(key: key);

  //list of file URLS
  final List<SubjectFile> list;

  final Map<Subject, SubjectFile> fromTagMap;

  final Subject subject;

  //current selected index (passed in from page in which it was invoked)
  final int i;

  @override
  _FileViewerState createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer>
{

  RequestManager requestManager = RequestManager.singleton;

  bool submitting = false;

  bool tagChanged = false;

  String currentTag;
  String previousTag;

  int currentIndex;

  String currentID;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {

    if(widget.fromTagMap == null){
      previousTag = widget.list[widget.i].tag;
      currentID = widget.list[widget.i].id;
    }
    else {
      previousTag = widget.fromTagMap.values.elementAt(widget.i).tag;
      currentID = widget.fromTagMap.values.elementAt(widget.i).id;
    }

    currentIndex = widget.i;
    currentTag = previousTag;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
        children: <Widget>[
          Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
                backgroundColor: Colors.black,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.local_offer),
                    iconSize: 30.0,
                    color: ThemeCheck.colorCheck(Theme.of(context).backgroundColor) ? Theme.of(context).accentColor : Colors.white,
                    onPressed: () => showTagDialog(false, null),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    iconSize: 30.0,
                    color: ThemeCheck.colorCheck(Theme.of(context).backgroundColor) ? Theme.of(context).accentColor : Colors.white,
                    onPressed: deleteFileDialog,
                  ),
                ]
            ),
            backgroundColor: Colors.black,
            //hero animation for moving smoothly from the page in which the image was selected, to the file viewer
            //the tag allows both pages to know where to return to when the user presses the back button
            body: new Center(
              child: Hero(tag: "fileAt"+widget.i.toString(),
                //swiper widget allows to swipe between a list
                child: new Swiper(
                  itemBuilder: (BuildContext context, int index){

                    //photo view allows for zooming in and out of images
                    return FileTypeManger.getFileTypeFromURL(
                        widget.fromTagMap == null ? widget.list[index].url : widget.fromTagMap.values.elementAt(index).url) == "image" ?
                        new PhotoView(
                          maxScale: PhotoViewComputedScale.contained * 2.0,
                          minScale: (PhotoViewComputedScale.contained) * 0.5,
                          //get a cached network image from the current URL in the list, this will ensure the image URL does not need to be loaded every time
                          imageProvider: new CachedNetworkImageProvider(widget.fromTagMap == null ? widget.list[index].url : widget.fromTagMap.values.elementAt(index).url)
                        )
                      : FileTypeManger.getFileTypeFromURL(
                        widget.fromTagMap == null ? widget.list[index].url : widget.fromTagMap.values.elementAt(index).url) == "video" ?
                        new VideoManager(
                            controller: new VideoPlayerController.network(widget.fromTagMap == null ? widget.list[index].url : widget.fromTagMap.values.elementAt(index).url)
                        )
                      : FileTypeManger.getFileTypeFromURL(
                        widget.fromTagMap == null ? widget.list[index].url : widget.fromTagMap.values.elementAt(index).url) == "audio" ?
                        new AudioManager(
                          subjectFile: widget.fromTagMap == null ? widget.list[index] : widget.fromTagMap.values.elementAt(index),
                          audioPlayer: new AudioPlayer(),
                        ) : new Container();
                  },
                  itemCount: widget.fromTagMap == null ? widget.list.length : widget.fromTagMap.length,
                  pagination: new SwiperPagination(
                    builder: MediaQuery.of(context).orientation == Orientation.portrait && FileTypeManger.getFileTypeFromURL(
                        widget.fromTagMap == null ? widget.list[currentIndex].url : widget.fromTagMap.values.elementAt(currentIndex).url) == "video" ? SwiperPagination.dots : SwiperPagination.rect
                  ),
                  control: new SwiperControl(color: Colors.white70),
                  //start the wiper on the index of the image selected
                  index: currentIndex,
                  onIndexChanged: (int index) => updateInfo(
                      widget.fromTagMap == null ? widget.list[index].id : widget.fromTagMap.values.elementAt(index).id,
                      index,
                      widget.fromTagMap == null ? widget.list[index].tag : widget.fromTagMap.values.elementAt(index).tag),
                ),
              ),
            )
          ),
          submitting ? new Stack(
            alignment: Alignment.center,
            children: <Widget>[
              new Container(
                  margin: MediaQuery.of(context).padding,
                  child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,))
            ],
          ): new Container()
        ]
    );
  }

  void updateInfo(String newID, int newIndex, String newTag){
    if(this.mounted) {
      setState(() {
        currentID = newID;
        previousTag = newTag;

        if (!tagChanged) {
          currentTag = previousTag;
        }

        currentIndex = newIndex;
      });
    }
  }

  void showTagDialog(bool fromWithin, List<String> currentTags) async {

    List<String> tagValues;

    if(!fromWithin) {
      submit(true);

      List<Tag> tags = await requestManager.getTags();

      submit(false);

      tagValues = tags.map((tag) => tag.tag).toList();

      tagValues.add("No Tag");
    }
    else {
      tagValues = currentTags;
    }

    AlertDialog tagDialog = new AlertDialog(
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Text("Current Tag is: ", style: TextStyle(fontSize: 20.0)),
              new Text(previousTag, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            ],
          ),
          new SizedBox(height: 20.0,),
          new DropdownButton<String>(
            //initial value
            value: currentTag,
            hint: new Text("Choose a Tag", style: TextStyle(fontSize: 20.0)),
            items: tagValues.map((String tag) {
              return new DropdownMenuItem<String>(
                value: tag,
                child: new Text(tag,  style: TextStyle(fontSize: 20.0)),
              );
            }).toList(),
            //when the font is changed in the dropdown, change the current font state
            onChanged: (String val){
              if (this.mounted) {
                setState(() {
                  tagChanged = true;
                  currentTag = val;
                  Navigator.pop(context);
                  showTagDialog(true, tagValues);
                });
              }
            },
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("Close", style: TextStyle(fontSize: 18.0),)),
        new FlatButton(onPressed: () async {
          submit(true);
          Navigator.pop(context);
          await addTagToFile();
          submit(false);
        }, child: new Text("Add Tag", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => tagDialog);
  }

  void addTagToFile() async {

    Map map = {"id": currentID, "tag": currentTag, "subjectID": widget.fromTagMap == null ? widget.subject.id : widget.fromTagMap.keys.elementAt(currentIndex).id};

    var response = await requestManager.putTagOnFile(map);

    //if null, then the request was a success, retrieve the information
    if (response ==  "success"){
      setState(() {
        widget.fromTagMap == null ? widget.list[currentIndex].tag = currentTag : widget.fromTagMap.values.elementAt(currentIndex).tag = currentTag;
        tagChanged = false;
        previousTag = currentTag;
      });
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Tag Added!')));
    }
    //else the response ['response']  is not null, then print the error message
    else{
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        content: new Text("An error occured please try again"),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context); submit(false);}, child: new Text("OK"))
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
    }
  }

  void deleteFileDialog() {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text("Do you want to DELETE this File?", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("NO", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
        new FlatButton(onPressed: () async {
          submit(true);
          Navigator.pop(context);
          await deleteFile();
        }, child: new Text("YES", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  void deleteFile() async {
    var response = await requestManager.deleteFile(
        widget.fromTagMap == null ? widget.list[currentIndex].id : widget.fromTagMap.values.elementAt(currentIndex).id,
        widget.fromTagMap == null ? widget.subject.id : widget.fromTagMap.keys.elementAt(currentIndex).id,
        widget.fromTagMap == null ? widget.list[currentIndex].fileName : widget.fromTagMap.values.elementAt(currentIndex).fileName,
    );

    //if null, then the request was a success, retrieve the information
    if (response ==  "success"){
      super.dispose();
      Navigator.pop(context, true);
    }
    //else the response ['response']  is not null, then print the error message
    else{
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        content: new Text("An error has occured, please try again"),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context); /*submit(false);*/}, child: new Text("OK"))
        ],
      );

      showDialog(context: context, barrierDismissible: true, builder: (_) => responseDialog);
    }
  }

  void submit(bool state)
  {
    if (this.mounted){
      setState(() {
        submitting = state;
      });
    }
  }
}
