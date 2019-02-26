import 'package:my_school_life_prototype/font_data.dart';
import 'package:my_school_life_prototype/home_page.dart';
import 'package:my_school_life_prototype/theme_check.dart';
import 'request_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'subject.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class AddSubject extends StatefulWidget {

  AddSubject({Key key, this.subject, this.fontData}) : super(key: key);

  final FontData fontData;
  final Subject subject;

  @override
  _AddSubjectState createState() => _AddSubjectState();
}

class _AddSubjectState extends State<AddSubject> {

  RequestManager requestManager = RequestManager.singleton;

  final subjectController = new TextEditingController();
  FocusNode subjectFocusNode;
  Color currentColor;

  bool submitting = false;

  @override
  void initState() {
    subjectFocusNode = new FocusNode();

    if (widget.subject != null) {
      currentColor = Color(int.tryParse(widget.subject.colour));
      subjectController.text = widget.subject.name;
    }

    super.initState();
  }

  ValueChanged<Color> onColorChanged;

  changeColorAndPopout(Color color) => setState(() {
    currentColor = color;
    Navigator.of(context).pop();
  });

  bool isFileEdited() {
      if (widget.subject == null) {
        if (subjectController.text == "") {
          return false;
        }
        else {
          return true;
        }
      }
      else {
        if (subjectController.text != widget.subject.name || currentColor != Color(int.tryParse(widget.subject.colour))) {
          return true;
        }
        else {
          return false;
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {

          if(await exitCheck() == null){
            Navigator.pop(context, true);
          }
          else{
            Navigator.pop(context, false);
          }
        },
        child: Stack(
          children: <Widget>[
            Scaffold(
              resizeToAvoidBottomPadding: false,
              appBar: new AppBar(
                title: widget.subject == null ? new Text("Add a New Subject", style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font),) : new Text(widget.subject.name),
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.home),
                      iconSize: 30.0,
                      onPressed: () async {

                        if(await exitCheck() == null){
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false);
                        }
                      }
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    new Card(
                        margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        elevation: 3.0,
                        child: new Column(
                          children: <Widget>[
                            new Container(
                              margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                controller: subjectController,
                                onFieldSubmitted: (String value) {
                                  setState(() {
                                    FocusScope.of(context).requestFocus(new FocusNode());
                                  });
                                },
                                style: TextStyle(
                                    color: widget.fontData.color,
                                    fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size,
                                    fontFamily: widget.fontData.font
                                ),
                                decoration: InputDecoration(
                                    hintText: "Subject Name",
                                    labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).accentColor),
                                    border: UnderlineInputBorder()
                                ),
                              ),
                            ),
                            SizedBox(height: 20.0),
                            new Container(
                                margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                child: ButtonTheme(
                                  height: 50.0,
                                  child: RaisedButton(
                                    elevation: 3.0,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Center(
                                            child: Container(
                                                height: MediaQuery.of(context).size.height*0.8,
                                                width: MediaQuery.of(context).size.width*0.985,
                                                child: Card(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: <Widget>[
                                                      Text('Select a Colour for the Font', style: TextStyle(fontSize: 20.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontFamily: widget.fontData.font, color: widget.fontData.color, fontWeight: FontWeight.bold)),
                                                      Container(
                                                        width: MediaQuery.of(context).size.width,
                                                        height: MediaQuery.of(context).size.height * 0.65,
                                                        child: Swiper(
                                                          viewportFraction: 0.99999,
                                                          scale: 0.9,
                                                          pagination: new SwiperPagination(
                                                            builder: SwiperPagination.dots,
                                                          ),
                                                          scrollDirection: Axis.horizontal,
                                                          control: SwiperControl(color: Theme.of(context).accentColor),
                                                          itemCount: 2,
                                                          itemBuilder: (BuildContext context, int index){
                                                            if (index == 0) {
                                                              return Column(
                                                                children: <Widget>[
                                                                  Text("Basic Colours", style: TextStyle(fontSize: 20.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontFamily: widget.fontData.font, color: widget.fontData.color)),
                                                                  new SizedBox(height: 20.0,),
                                                                  SingleChildScrollView(
                                                                      child: Container(
                                                                        height: MediaQuery.of(context).size.height * 0.50,
                                                                        child: BlockPicker(
                                                                          pickerColor: currentColor != null ? currentColor : Theme.of(context).accentColor,
                                                                          onColorChanged: changeColorAndPopout,
                                                                        ),
                                                                      )
                                                                  )
                                                                ],
                                                              );
                                                            }
                                                            else {
                                                              return Column(
                                                                children: <Widget>[
                                                                  Text("Colourblind Friendly Colours", style: TextStyle(fontSize: 20.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontFamily: widget.fontData.font, color: widget.fontData.color)),
                                                                  new SizedBox(height: 20.0,),
                                                                  SingleChildScrollView(
                                                                    child: BlockPicker(
                                                                      availableColors: ThemeCheck.colorBlindFriendlyColours(),
                                                                      pickerColor: currentColor != null ? currentColor : Theme.of(context).accentColor,
                                                                      onColorChanged: changeColorAndPopout,
                                                                    ),
                                                                  )
                                                                ],
                                                              );
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                            ),
                                          );},
                                      );},
                                    child: Align(alignment: Alignment.centerLeft, child: Text('Select Font Colour', style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontFamily: widget.fontData.font))),
                                    color: currentColor != null ? currentColor : Theme.of(context).accentColor,

                                    textColor: ThemeCheck.colorCheck(currentColor != null ? currentColor : Theme.of(context).accentColor) ? Colors.white : Colors.black,
                                  ),
                                )
                            ),
                            SizedBox(height: 20.0),
                          ],
                        )
                    ),
                    SizedBox(height: 10.0),
                    new Container(
                        margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        child: ButtonTheme(
                          height: 50.0*ThemeCheck.orientatedScaleFactor(context),
                          child: RaisedButton(
                            elevation: 3.0,
                            onPressed: showAreYouSureDialog,
                            child: Align(alignment: Alignment.centerLeft, child: Text('Submit', style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontFamily: widget.fontData.font,))),
                            color: Theme.of(context).errorColor,

                            textColor: ThemeCheck.colorCheck(Theme.of(context).errorColor) ? Colors.white : Colors.black,
                          ),
                        )
                    )
                  ],
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
          ],
        )
    );
  }

  void showAreYouSureDialog() {

    AlertDialog areYouSure = new AlertDialog(
      content: new Text("Do you want to ADD this Subject to your Subject Hub?", style: TextStyle(fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("NO", style: TextStyle(fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font, fontWeight: FontWeight.bold,),)),
        new FlatButton(onPressed: () async {
          if (subjectController.text == "") {
            Navigator.pop(context);
            showYouMustHaveFileNameDialog();
            return false;
          }
          else {
            submit(true);
            Navigator.pop(context);
            await addSubject();
            submit(false);
            Navigator.pop(context);
            return true;
          }
        }, child: new Text("YES", style: TextStyle(fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  Future<bool> exitCheck() async{
    if (isFileEdited()) {
      AlertDialog areYouSure = new AlertDialog(
        content: new Text("Do you want to SAVE this Subject?", style: TextStyle(fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font),),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO", style: TextStyle(fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font, fontWeight: FontWeight.bold,),)),
          new FlatButton(onPressed: () async {
            if (subjectController.text == "") {
              showYouMustHaveFileNameDialog();
              return false;
            }
            else {
              submit(true);
              Navigator.pop(context);
              await addSubject();
              submit(false);
              Navigator.pop(context);
              return true;
            }
          }, child: new Text("YES", style: TextStyle(fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font, fontWeight: FontWeight.bold,),)),
        ],
      );

      return showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
    }
    else {
      return true;
    }
  }

  void showYouMustHaveFileNameDialog() {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text("You must have a Subject Name", style: TextStyle(fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  void addSubject() async {
    //create map of subject data
    Map map = {
      "id": widget.subject == null ? null : widget.subject.id,
      "name": subjectController.text,
      "colour": currentColor != null ? currentColor.value.toString() : Theme.of(context).accentColor.value.toString(),
      "oldTitle": widget.subject == null ? null : widget.subject.name,
    };

    var response = await requestManager.putSubject(map);

    //if null, then the request was a success, retrieve the information
    if (response !=  "success"){
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        content: new Text("An error has occured please try again"),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context); submit(false);}, child: new Text("OK"))
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
    }
  }

  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }
}
