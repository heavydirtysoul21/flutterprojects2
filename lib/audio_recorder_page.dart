import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:path/path.dart' as p;

// Files used by this package
import 'audio_play_bar.dart';
import 'save_dialog.dart';
import 'package:path_provider/path_provider.dart';


class AudioRecorderPage extends StatefulWidget {
  AudioRecorderPage({Key key}) : super(key: key);

  @override
  AudioRecorderPageState createState() {
    return new AudioRecorderPageState();
  }
}

class AudioRecorderPageState extends State<AudioRecorderPage> {
  // The AudioRecorderPageState holds info based on
  // whether the app is currently
  // FIXME! Disable TabController when recording

  Recording _recording;
  bool _isRecording = false;
  bool _doQuerySave = false; //Activates save or delete buttons


  // Note: The following variables are not state variables.
  String tempFilename = "Recording"; //Filename without path or extension
  File defaultAudioFile;



  stopRecording() async {
    // Await return of Recording object
    var recording = await AudioRecorder.stop();
    bool isRecording = await AudioRecorder.isRecording;

    //final storage = SharedAudioContext.of(context).storage;
    //Directory docDir = await storage.docDir;
    Directory docDir = await getApplicationDocumentsDirectory();

    setState(() {
      //Tells flutter to rerun the build method
      _isRecording = isRecording;
      _doQuerySave = true;
      defaultAudioFile = File(p.join(docDir.path, this.tempFilename+'.m4a'));
    });
  }



  startRecording() async {
    try {
      //final storage = SharedAudioContext.of(context).storage;
      //Directory docDir = await storage.docDir;
      Directory docDir = await getApplicationDocumentsDirectory();
      String newFilePath = p.join(docDir.path, this.tempFilename);
      File tempAudioFile = File(newFilePath+'.m4a');
      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text("Recording."),
                                     duration: Duration(milliseconds: 1400), ));
      if (await tempAudioFile.exists()){
        await tempAudioFile.delete();
      }
      if (await AudioRecorder.hasPermissions) {
        await AudioRecorder.start(
            path: newFilePath, audioOutputFormat: AudioOutputFormat.AAC);
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text("Error! Audio recorder lacks permissions.")));
      }
      bool isRecording = await AudioRecorder.isRecording;
      setState(() {
        //Tells flutter to rerun the build method
        _recording = new Recording(duration: new Duration(), path: newFilePath);
        _isRecording = isRecording;
        defaultAudioFile = tempAudioFile;
      });
    } catch (e) {
      print(e);
    }
  }

  _deleteCurrentFile() async {
    //Clear the default audio file and reset query save and recording buttons
    if (defaultAudioFile != null){
        setState(() {
        //Tells flutter to rerun the build method
        _isRecording = false;
        _doQuerySave = false;
        defaultAudioFile.delete();
      });
    }else{
      print ("Error! defaultAudioFile is $defaultAudioFile");
    } 
    Navigator.pop(context);
  
  }

  AlertDialog _deleteFileDialogBuilder(){
    return AlertDialog(
      title: Text("Delete current recording?"),
      actions: <Widget>[
          new FlatButton(
            child: const Text("YES"),
            onPressed: () => _deleteCurrentFile(), //
          ),
          new FlatButton(
            child: const Text("NO"),
            onPressed: () => Navigator.pop(context),
          )
        ]
    
    );

  }


  _showSaveDialog() async {
      // Note: SaveDialog should return a File or null when calling Navigator.pop()
      // Catch this return value and update the state of the ListTile if the File has been renamed
      File newFile = await showDialog(
            context: context,
            builder: (context) => SaveDialog(defaultAudioFile: defaultAudioFile,)
      );
    
    if( newFile != null){
      String basename = p.basename(newFile.path);
      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text("Saved file $basename"),
                                     duration: Duration(milliseconds: 1400), ));

      setState(() {
        //Reset the page, and get rid of the buttons
        _isRecording = false;
        _doQuerySave = false;
       });
    }
  }

  @override

  // TODO: do an async check of audio recorder state before building everything else
  Widget build(BuildContext context) {
    // Check if the AudioRecorder is currently recording before building the rest of the Page
    // If we do not check this,
     return FutureBuilder<bool>(
       future: AudioRecorder.isRecording,
       builder: audioCardBuilder    
     );
  }

  Widget audioCardBuilder (BuildContext context, AsyncSnapshot snapshot ) {
    switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Container();
          default:
            if (snapshot.hasError){
              return new Text('Error: ${snapshot.error}');
            }else{
              bool isRecording = snapshot.data;

              // Note since this is being called in build(), we do not call set setState to change
              // the value of _isRecording
              _isRecording = isRecording;

              return new Card(
                child: new Center(
                  // Center is a layout widget. It takes a single child and positions it
                  // in the middle of the parent.
                  child: new Column(
                    // horizontal).
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Spacer(flex:1),//70.0
                      Container( 
                        width: 120.0,
                        height: 120.0,
                        child:
                          CircularProgressIndicator(
                            strokeWidth: 14.0,
                            valueColor: _isRecording ? AlwaysStoppedAnimation<Color>(Colors.blue):AlwaysStoppedAnimation<Color>(Colors.blueGrey[50]),
                            value: _isRecording ? null : 100.0,
                      )),
                      Spacer(),//spacer 10
                       Container(height:20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                               _doQuerySave ? Text("Delete",textScaleFactor: 1.2,) : Container(),
                               Container(height:12.0),
                              new FloatingActionButton(
                                child: _doQuerySave ? new Icon(Icons.cancel) : null,
                                disabledElevation: 0.0,
                                backgroundColor:
                                    _doQuerySave ? Colors.blueAccent : Colors.transparent,
                                onPressed: _doQuerySave ? (() => showDialog(
                                  context: context,
                                  builder: (context) => _deleteFileDialogBuilder(),
                                )): null,
                                mini: true,
                              ),
                            ]
                          ),
                          Container(width: 38.0),
                          Column( children: [
                            _isRecording
                          ? new Text('Stop',textScaleFactor: 1.5)
                          : new Text('Record', textScaleFactor: 1.5),
                          Container(height:12.0),
                           new FloatingActionButton(
                            child: _isRecording
                                ? new Icon(Icons.stop, size: 36.0)
                                : new Icon(Icons.mic, size: 36.0),
                            disabledElevation: 0.0,
                            onPressed: _isRecording ? stopRecording : startRecording,
                          ),]),
                          Container(width: 38.0),
                          Column(
                            children:[
                              _doQuerySave ? Text("Save",textScaleFactor: 1.2,) : Container(),
                              Container(height:12.0),
                              FloatingActionButton(
                              child: _doQuerySave ? new Icon(Icons.check_circle) : Container(),
                              backgroundColor:
                                  _doQuerySave ? Colors.blueAccent : Colors.transparent,
                              disabledElevation:0.0,
                              mini: true,
                              onPressed: _doQuerySave ? _showSaveDialog : null, 
                          ),]),
                        ],
                      ),
                    Spacer(),
                  //   FloatingActionButton(
                  //   child: _doQuerySave
                  //       ? Icon(
                  //           Icons.play_arrow,
                  //           size: 36,
                  //         )
                  //       : Container(),
                  //   backgroundColor:
                  //       _doQuerySave ? Colors.blueAccent : Colors.transparent,
                  //   disabledElevation: 0.0,
                  //   mini: true,
                  //   onPressed: _doQuerySave
                  //       ? () {
                  //           showModalBottomSheet<void>(
                  //               context: context,
                  //               builder: (BuildContext context) {
                  //                 return AudioPlayBar(file: defaultAudioFile);
                  //               });
                  //         }
                  //       : null,
                  // ),
                    ],
                  ),
                ),
              );
            }
    }
}}
