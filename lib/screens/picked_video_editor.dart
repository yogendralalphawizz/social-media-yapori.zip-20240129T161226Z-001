import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tapioca/tapioca.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:video_player/video_player.dart';


class VideoFilterScreen extends StatefulWidget {
  @override
  _VideoFilterScreenState createState() => _VideoFilterScreenState();
}

class _VideoFilterScreenState extends State<VideoFilterScreen> {
  final navigatorKey = GlobalKey<NavigatorState>();
  late XFile _video;
  bool isLoading = false;
  static const EventChannel _channel =
  const EventChannel('video_editor_progress');
  late StreamSubscription _streamSubscription;
  int processPercentage = 0;

  @override
  void initState() {
    super.initState();
    _enableEventReceiver();
  }

  @override
  void dispose() {
    super.dispose();
    _disableEventReceiver();
  }

  void _enableEventReceiver() {
    _streamSubscription = _channel.receiveBroadcastStream().listen(
            (dynamic event) {
          setState((){
            processPercentage = (event.toDouble()*100).round();
          });
        },
        onError: (dynamic error) {
          print('Received error: ${error.message}');
        },
        cancelOnError: true);
  }

  void _disableEventReceiver() {
    _streamSubscription.cancel();
  }
  _pickVideo() async {
    try {
      final ImagePicker _picker = ImagePicker();
      XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _video = video;
          isLoading = true;
        });
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: isLoading ? Column(mainAxisSize: MainAxisSize.min,children:[

              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text(processPercentage.toString() + "%", style: TextStyle(fontSize: 20),),
            ] ) : ElevatedButton(
              child: Text("Pick a video and Edit it"),
              onPressed: () async {
                print("clicked!");
                await _pickVideo();
                var tempDir = await getTemporaryDirectory();
                final path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}result.mp4';
                print(tempDir);
                // final imageBitmap =
                // (await rootBundle.load("assets/apple.png"))
                //     .buffer
                //     .asUint8List();
                try {
                  final tapiocaBalls = [
                    TapiocaBall.filter(Filters.pink, 0.2),
                    // TapiocaBall.imageOverlay(imageBitmap, 300, 300),
                    TapiocaBall.textOverlay(
                        "text", 100, 10, 100, Color(0xffffc0cb)),
                  ];
                  print("will start");
                  final cup = Cup(Content(_video.path), tapiocaBalls);
                  cup.suckUp(path).then((_) async {
                    print("finished");
                    setState(() {
                      processPercentage = 0;
                    });
                    print(path);
                    GallerySaver.saveVideo(path).then((bool? success) {
                      print(success.toString());
                    });
                    final currentState = navigatorKey.currentState;
                    if (currentState != null) {
                      currentState.push(
                        MaterialPageRoute(builder: (context) =>
                            VideoScreen(path)),
                      );
                    }

                    setState(() {
                      isLoading = false;
                    });
                  }).catchError((e) {
                    print('Got error: $e');
                  });
                } on PlatformException {
                  print("error!!!!");
                }
              },
            )),
      ),
    );
  }
}

class VideoScreen extends StatefulWidget {
  final String path;

  VideoScreen(this.path);

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoScreen> {



  late VideoPlayerController _controller;

  // FilterType filterType = FilterType.CONTRAST;


  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    // GpuVideoFlutterKz.startCodec(false, false,
    //     false, widget.path, filterType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child:
        // _controller.value.isInitialized
        //     ?
        Container(
          width: 300,
          height: 300,
          // aspectRatio: _controller.value.aspectRatio,
           child:  VideoPlayer(_controller),
        ),
            // : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (!_controller.value.isPlaying &&
                _controller.value.isInitialized &&
                (_controller.value.duration == _controller.value.position)) {
              _controller.initialize();
              _controller.play();
            } else {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class VideoFilterPainter extends CustomPainter {
  final VideoPlayerController controller;

  VideoFilterPainter({required this.controller});

  @override
  void paint(Canvas canvas, Size size) {
    if (controller.value.isInitialized) {
      final VideoPlayerController _controller = controller;
      final VideoPlayerValue _value = _controller.value;
      final double videoAspectRatio = _value.aspectRatio;
      final double screenAspectRatio = size.width / size.height;
      final double scaleFactor =
      videoAspectRatio / screenAspectRatio > 1 ? size.width / _value.size.width : size.height / _value.size.height;

      canvas.scale(scaleFactor, scaleFactor);
        // _controller.buildTexture(size);

      final Paint filterPaint = Paint(); // Apply your filter settings here
      // Example:
      filterPaint.colorFilter = ColorFilter.mode(Colors.red, BlendMode.overlay);

      canvas.saveLayer(null, filterPaint);
      canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), filterPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
