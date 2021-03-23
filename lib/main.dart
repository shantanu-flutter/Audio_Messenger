import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
          primaryColor: new Color(0xff075E54),
          accentColor: new Color(0xff25D366)),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  bool isRecording = false;
  bool isAudioPlaying = false;
  bool isVerticallySwiped = false;
  List<Message> audioRecordings = [];
  Message recordingMessage ;
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  AnimationController animation;
  Animation<double> _fadeInFadeOut;
  final String _mPath = 'flutter_sound_example.aac';
  @override
  void initState() {
    // TODO: implement initState
    if(_mPlayer!=null) _mPlayer.openAudioSession().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
    animation = AnimationController(vsync: this, duration: Duration(milliseconds: 500),);
    _fadeInFadeOut = Tween<double>(begin: 0.0, end: 0.8).animate(animation);

    animation.addStatusListener((status){
      if(status == AnimationStatus.completed){
        animation.reverse();
      }
      else if(status == AnimationStatus.dismissed){
        animation.forward();
      }
    });
    //animation.forward();
  }

  @override
  void dispose() {
    if(_mPlayer!=null) _mPlayer.closeAudioSession();

    _mPlayer = null;

    if(_mRecorder!=null) _mRecorder.closeAudioSession();
    _mRecorder = null;
    super.dispose();
  }


  Future<void> openTheRecorder() async {

      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    if(_mRecorder!=null){
      await _mRecorder.openAudioSession();
    }

    _mRecorderIsInited = true;
  }

  // ----------------------  Here is the code for recording and playback -------

  void record() {//Start Recording at perticular Index of List
    if(_mRecorder!=null ){
      recordingMessage = new Message(
        audioPath: 'Sound${DateTime.now().millisecondsSinceEpoch}',
        recordingTime: DateTime.now()
      );
      print(_mPath);
      _mRecorder
          .startRecorder(
        toFile: _mPath,
        //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
      )
          .then((value) {
            print("Record started ");
        setState(() {});
      });
    }else{
      print("retruning from record()");
    }

  }

  void stopRecorder() async {//Stop the Recording
    await _mRecorder.stopRecorder().then((value) {
      print("Audio Recorded");

    });
  }

  void play(int index) {    //Play  the recorded sound at AudioList Index
    if(isAudioPlaying)return;//to not play if already playing
    if(_mRecorder==null||_mPlayer==null) {
     print("play() first if returning");

    }
    //path = _mPath;
    print("path  is  ${_mPath}");
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder.isStopped &&
        _mPlayer.isStopped);
    _mPlayer
        .startPlayer(
        fromURI: _mPath,
        //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
        whenFinished: () {
          audioRecordings[index].isPlaying = false;
          isAudioPlaying = false;
          print("Yhan se pta chala finish");
          setState(() {});
        })
        .then((value) {
      setState(() {});
    });
  }

  void stopPlayer() {//Stop player
    isAudioPlaying = false;
    if(_mPlayer!=null){
      _mPlayer.stopPlayer().then((value) {
      });
    }

  }

//-------------------------------------------------UI-----------------------------


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),

      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          new Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0,0,0,70),
              child: ListView.builder(
                itemCount: audioRecordings.length,
                itemBuilder: (context, index) {

                  return  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Container(
                          decoration: BoxDecoration(
                            color: Color(0xffF0F4C3),
                            shape: BoxShape.rectangle,
                            border: Border.all(color: Colors.black38, width: 1,),
                            borderRadius: BorderRadius.all(Radius.circular(
                                6.0) //                 <--- border radius here
                            ),
                          ),
                          width:200,
                          height: 50.0,

                          child: Container(
                            height: 50.0,
                            width:200,
                            //color: Colors.amber,
                            child: new Row(

                              children: [
                                new CircleAvatar(
                                  radius: 25.0,
                                  child: new Text("S", style: TextStyle (color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0)),//Can be Profile Of user
                                  backgroundColor: Colors.grey,
                                ),

                                audioRecordings[index].isPlaying==false||audioRecordings[index].isPlaying==null?//Checking if this Index is ALready playing showin
                                new IconButton(
                                  onPressed: (){
                                    audioRecordings[index].isPlaying = true;
                                    play(index);
                                    setState(() {

                                    });
                                  },
                                  icon: new Icon(Icons.play_arrow),
                                ):new IconButton(
                                  icon: new Icon(Icons.stop),
                                  onPressed: (){
                                    audioRecordings[index].isPlaying = false;
                                    stopPlayer();
                                    setState(() {

                                    });
                                  },
                                ),
                              ],
                            ),
                          )),
                    ),
                  );



                }

              ),
            )
          )
          ,Padding(
            padding: const EdgeInsets.fromLTRB(0,0,5,5),//Padding for bottom and Right of Lowe Text Field
            child: new Row(
              children: [

                Flexible(
                  child: new Stack(
                    alignment: Alignment.center,
                    children: [
                       new TextField(//Lower Text Field
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        40.0), //                 <--- border radius here
                                  ),
                                  borderSide:BorderSide(
                                      width: 1.0,
                                      style: BorderStyle.solid,
                                      color: Color(0xffDDDDDD)) ),



                              // focusedBorder: InputBorder.none
                            )

                        ),

                      isRecording==true?Container(//Container For recordding MIC And Text
                        //color: Colors.green,
                       // width: MediaQuery.of(context).size.width-200,
                        child:Padding(
                              padding: const EdgeInsets.fromLTRB(20,0,20,0),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FadeTransition(
                                    opacity: _fadeInFadeOut,
                                    child: new Container(child: new Icon(Icons.mic, color: Colors.red,))),

                                isVerticallySwiped?
                                GestureDetector(
                                    onTap: ()async{
                                      isVerticallySwiped = false;
                                      isRecording = false;
                                      setState(() {

                                      });
                                      await stopRecorder();

                                      print("isRecording ${isRecording}  isVerticallySwiped ${isVerticallySwiped}");
                                    },
                                    child: Container(child: new Text("Cancel",style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),)))
                                :FadeTransition(
                                    opacity: _fadeInFadeOut,
                                    child: new Text("<< Swipe to Cancel"))
                                ],
                              ),
                            )


                      ):new SizedBox()//If not Recording show Noting
                      
                    ],
                  ),
                ),

                GestureDetector(//For Capturing Different Gestures of Record Button
                  onTap:() async {
                    //print("isRecording ${isRecording} isVerticallySwiped ${isVerticallySwiped}");

                    if(isRecording&&isVerticallySwiped){
                      isRecording =false;
                      isVerticallySwiped = false;

                      setState(() {
                        _mplaybackReady = true;
                        print("Adding Path ${recordingMessage.audioPath}");
                        audioRecordings.add(recordingMessage);
                        print(audioRecordings);
                        //audioRecordings.add(new Message(recordingTime: DateTime.now(), audioPath:_mPath));
                      });
                      stopRecorder();
                    }

                  } ,
                  onLongPressStart: ( LongPressStartDetails val) async {
                    print("Long Press start");
                    if(isVerticallySwiped==false){//Long Press is Done when its not already Recording
                      animation.forward();
                      setState(() {
                        isRecording=true;
                      });
                      record();
                      //print("Long press started");
                    }

                },

                  onLongPressEnd: ( val) async{
                    print("Long press ended");
                    if(isVerticallySwiped==false){// to Save the Recording when Loang Press Ends
                      print("Long Press end");
                       stopRecorder();
                      isRecording =false;
                      setState(() {
                        _mplaybackReady = true;
                        print("Adding Path ${recordingMessage.audioPath}");
                        audioRecordings.add(recordingMessage);
                        print(audioRecordings);
                        //audioRecordings.add(new Message(recordingTime: DateTime.now(), audioPath:_mPath));
                      });
                    }


                  },
                  onVerticalDragStart: (dragStartDetails)async {//For Locking the Recording in Vertical Drag
                    print("Vertical Drag Start");
                    if(isRecording==false){
                      animation.forward();
                        isRecording=true;
                      record();
                      print("Long press started");
                    }
                      isVerticallySwiped = true;

                    print("Is Vertically Swiped ${isVerticallySwiped}");
                    setState(() {

                    });
                  },
                  onVerticalDragEnd: (ver){//No Implimentation Needed
                    print("Vertical Drag end");
                  },


                  onHorizontalDragEnd: (val) async {//On Horizontal Drag END the Recording

                    if(isVerticallySwiped==false){//Only End while Vertiacally not Locked
                      stopRecorder();
                      //Delete FROm FIlE
                      isRecording =false;
                      setState(() {
                        _mplaybackReady = true;
                        print("Adding Path ${recordingMessage.audioPath}");
                      });
                    }

                  },


                  child: new Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: isRecording==true&&isVerticallySwiped==true?//if Vertically Locked and Recording
                    new IconButton(
                        icon: new Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                        )
                    :new IconButton(
                        icon: new Icon(
                          Icons.mic,
                          color: Colors.white,
                        ),
                        onPressed: null),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      //borderRadius: BorderRadius.circular(20.0),
                      color: isRecording?Colors.amber:Theme.of(context).primaryColor,
                    ),
                  ),
                )

              ],
            ),
          ),
          // isRecording?Positioned(
          //     bottom: 20.0,
          //     //left: 0.0,
          //     right: 100.0,
          //
          //     child: new Text("Hellooooooo")):new SizedBox(),
          //
          // isRecording?Positioned(
          //     bottom: 200.0,
          //     //left: 0.0,
          //     right: 0,
          //
          //     child: new Text("Ye Upar")):new SizedBox()


          
        ],
      ), 
      
      
      
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Message{
  String audioPath;
  DateTime recordingTime;
  bool isPlaying;

  Message({this.audioPath, this.recordingTime, this.isPlaying});

  @override
  String toString() {
    return 'Message{audioPath: $audioPath, recordingTime: $recordingTime}';
  }
}
