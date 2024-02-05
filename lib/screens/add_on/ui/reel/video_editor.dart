import 'dart:io';

// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min/return_code.dart';
import 'package:flutter/services.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/ui/VideoEditor/crop_page.dart';
import 'package:foap/screens/add_on/ui/VideoEditor/export_result.dart';
import 'package:foap/screens/add_on/ui/VideoEditor/export_service.dart';

import 'package:flutter/material.dart';
import 'package:foap/screens/picked_video_editor.dart';
import 'package:foap/screens/post/add_post_screen.dart';
import 'package:foap/util/constant_util.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tapioca/tapioca.dart';
import 'package:video_compress/video_compress.dart';

import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:tapioca/src/video_editor.dart' as ve;

import '../../../../ffmpeg_flutter/flutter_ffmpeg.dart';
import '../../../picked_image_editor.dart';



class VideoEditor extends StatefulWidget {
  final File reel;
  final int? audioId;
  final double? audioStartTime;
  final double? audioEndTime;
  final int? clubId;
  final int? competitionId;

  const VideoEditor({
    Key? key, required this.reel,
    this.audioId,
    this.audioStartTime,
    this.audioEndTime,
    this.competitionId,
    this.clubId
  }) : super(key: key);


  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;
  VideoPlayerController? controllers;

  late final VideoEditorController _controller = VideoEditorController.file(
    widget.reel,
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(seconds: 10),
  );

  @override
  void initState() {
    super.initState();
    _controller
        .initialize(aspectRatio: 9 / 16)
        .then((_) => setState(() {}))
        .catchError((error) {
      // handle minumum duration bigger than video duration error
      Navigator.pop(context);
    }, test: (e) => e is VideoMinDurationError);
  }

  @override
  void dispose() async {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    // ExportService.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );
///OLD VIDEO FILTER -NOT USEFUL
  // void applyFilterToVideo(String path, String oPath) async {
  //   final String inputPath = path; // Replace with the actual input video path
  //   final String outputPath = oPath; // Replace with the desired output video path
  //   print("inputPath : $inputPath && outputPath : $outputPath");
  //
  //   // var arguments = [
  //   //   '-i', 'input.mp4',           // Input video file
  //   //   '-vf', 'eq=brightness=1.5', // Apply a brightness filter
  //   //   'output.mp4',               // Output video file
  //   // ];
  //   // FFmpegKit.execute('-i $inputPath -vf "eq=brightness=1.5" $outputPath').then((session) async {
  //   //   final returnCode = await session.getReturnCode();
  //   //
  //   //   if (ReturnCode.isSuccess(returnCode)) {
  //   //     print('this is success ');
  //   //     // SUCCESS
  //   //
  //   //   } else if (ReturnCode.isCancel(returnCode)) {
  //   //     print('this is cancel ');
  //   //     // CANCEL
  //   //
  //   //   } else {
  //   //     print('this is failed ');
  //   //     // ERROR
  //   //
  //   //   }
  //   // });
  //   // FFmpegKit.execute(arguments).then((result) {
  //   //   if (result.) {
  //   //     print('this is success');
  //   //     // Video processing successful
  //   //   } else {
  //   //     // Handle errors
  //   //     print('Error: ${result.getErrorMessage()}');
  //   //   }
  //   // });
  //
  //
  //   print("applyFilterToVideo got invoked");
  //   final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  //   print("object created of flutterFFmpeg");
  //
  //   // final String inputPath = path; // Replace with the actual input video path
  //   // final String outputPath = oPath; // Replace with the desired output video path
  //   print("inputPath : $inputPath && outputPath : $outputPath");
  //
  //   final int rc = await _flutterFFmpeg.execute(
  //     '-i $inputPath -vf "format=gray" $outputPath',
  //   );
  //
  //   print("rc : $rc");
  //
  //   if (rc == 0) {
  //     print('Filter applied successfully.');
  //     final bool? success = await GallerySaver.saveVideo(path);
  //     print(success.toString());
  //     Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(path)));
  //   } else {
  //     print('Error applying filter: $rc');
  //   }
  // }
  // void _exportVideo() async {
  //   _exportingProgress.value = 0;
  //   _isExporting.value = true;
  //
  //   final config = VideoFFmpegVideoEditorConfig(
  //     _controller,
  //     isFiltersEnabled: true,
  //     // format: VideoExportFormat.mp4,
  //     // commandBuilder: (config, videoPath, outputPath) {
  //     //   final List<String> filters = config.getExportFilters();
  //     //   filters.add('hflip'); // add horizontal flip
  //     //
  //     //   return '-i $videoPath ${config.filtersCmd(filters)} -preset ultrafast $outputPath';
  //     // },
  //     // format: VideoExportFormat.gif,
  //     // commandBuilder: (config, videoPath, outputPath) {
  //     //   final List<String> filters = config.getExportFilters();
  //     //   filters.add('hflip'); // add horizontal flip
  //
  //     //   return '-i $videoPath ${config.filtersCmd(filters)} -preset ultrafast $outputPath';
  //     // },
  //   );
  //
  //   await ExportService.runFFmpegCommand(
  //     await config.getExecuteConfig(),
  //     onProgress: (stats) {
  //       _exportingProgress.value = config.getFFmpegProgress(stats.getTime());
  //     },
  //     onError: (e, s) => _showErrorSnackBar("Error on export video :("),
  //     onCompleted: (file) async {
  //       var tempDir = await getTemporaryDirectory();
  //       final path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}result.mp4';
  //       _isExporting.value = false;
  //       if (!mounted) return;
  //
  //       Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(file.path) ));
  //       // applyFilterToVideo(file.path, path);
  //
  //       // Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerWithFilter(videoPath: file.path,) ));
  //
  //
  //
  //       /// tapoica
  //       // final tapiocaBalls = [
  //       //   TapiocaBall.filter(Filters.pink, 0.2),
  //       //   // TapiocaBall.imageOverlay(imageBitmap, 300, 300),
  //       //   TapiocaBall.textOverlay(
  //       //       "text", 100, 10, 100, Color(0xffffc0cb)),
  //       // ];
  //       // print("will start path : $path && file path : ${file.path}");
  //       // final cup = Cup(Content(file.path), tapiocaBalls);
  //       // print("cup got assigned");
  //
  //
  //       // cup.suckUp(path).then((_) {
  //       //   print("finish processing cup");
  //       //   GallerySaver.saveVideo(path).then((bool? success) {
  //       //     print("gallery saver saved");
  //       //     print(success.toString());
  //       //   });
  //       //   Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(path) ));
  //       // }).catchError((e) {
  //       //   print('Got error: $e');
  //       // });
  //       // try {
  //       //   print("before suckUp method got invoked");
  //         var e = cup.suckUp(path);
  //         print("finish processing cup e : $e");
  //         if(e != null) {
  //           print("e is not null : ${e.toString()}");
  //           final bool? success = await GallerySaver.saveVideo(path);
  //           print(success.toString());
  //           Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(file.path)));
  //         } else {
  //           print("e is null");
  //         }
  //       // } catch (e) {
  //       //   print('Got error: $e');
  //       // }
  //       //
  //       // cup.suckUp(path).then((_) async {
  //       //   print("finished");
  //       //   // setState(() {
  //       //   //   processPercentage = 0;
  //       //   // });
  //       //   // print(path);
  //       //   GallerySaver.saveVideo(path).then((bool? success) {
  //       //     print(success.toString());
  //       //   });
  //       //   // final currentState = navigatorKey.currentState;
  //       //   // if (currentState != null) {
  //       //     Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(path) ));
  //       //     // Navigator.push(
  //       //     //   MaterialPageRoute(builder: (context) =>
  //       //     //       VideoScreen(path)),
  //       //     // );
  //       //   // }
  //       //
  //       //   // setState(() {
  //       //   //   isLoading = false;
  //       //   // });
  //       // }).catchError((e) {
  //       //   print('Got error: $e');
  //       // });
  //       // showDialog(
  //       //   context: context,
  //       //   builder: (_) => VideoResultPopup(video: file),
  //       // );
  //     },
  //   );
  // }
  ///OLD VIDEO FILTER


  void _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;
    // applyColorFilter(_controller.file.path.toString());
    // await applyColorFilter(_controller.file.path.toString(), 'filtered_video.mp4');
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => VideoPlayerScreen(videoPath: 'filtered_video.mp4'),
    //   ),
    // );
    final config = VideoFFmpegVideoEditorConfig(
      _controller,
      isFiltersEnabled: true,
      format: VideoExportFormat.mp4,
      // commandBuilder: (config, videoPath, outputPath) {
      //   final List<String> filters = config.getExportFilters();
      //   filters.add('hflip'); // add horizontal flip
      //
      //   return '-i $videoPath ${config.filtersCmd(filters)} -preset ultrafast $outputPath';
      // },
    );

    // submitReel(config);
///EXPORT VIDEO
    await ExportService.runFFmpegCommand(
      await config.getExecuteConfig(),
      onProgress: (stats) {
        _exportingProgress.value = config.getFFmpegProgress(stats.getTime());
      },
      onError: (e, s) { _showErrorSnackBar("Error on export video :(");
        print('this is error $e');
      },
      onCompleted: (file) async{
        print("working --------->>>>");
        _isExporting.value = false;
        if (!mounted) return;
        EasyLoading.show(status: LocalizationString.loading);
        Uint8List? thumbnail = await VideoThumbnail.thumbnailData(
          video: file.path,
          //config.controller.file.path.toString(),
          //widget.reel.path,
          //widget.reel.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 400,
          // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
          quality: 25,
        );
        print('this is thumbnail**** $thumbnail');
        // showDialog(
        //   context: context,
        //   builder: (_) => VideoResultPopup(video: widget.reel),
        // );
        MediaInfo? mediaInfo = await VideoCompress.compressVideo(
          file.path,
          // config.controller.file.path,
          // _controller.file.path,
          // widget.reel.path,
          quality: VideoQuality.DefaultQuality,
          deleteOrigin: false, // It's false by default
        );

        EasyLoading.dismiss();
        Media media = Media();
        media.id = randomId();
        media.file = File(file.path);
        media.thumbnail = thumbnail;
        // media.size = mediaInfo.filesize!;
        media.creationTime = DateTime.now();
        media.title = null;
        media.mediaType = GalleryMediaType.video;
        // if(media.fileSize! > 50 ) {
          Get.to(() =>
              AddPostScreen(
                items: [media],
                isReel: true,
                audioId: widget.audioId,
                audioStartTime: widget.audioStartTime,
                audioEndTime: widget.audioEndTime,
                clubId: widget.clubId,
                competitionId: widget.competitionId,
              ));
        // }else{
        //   Get.to(() =>
        //       AddPostScreen(
        //         items: [media],
        //         isReel: true,
        //         audioId: widget.audioId,
        //         audioStartTime: widget.audioStartTime,
        //         audioEndTime: widget.audioEndTime,
        //       ));
        // }

        // showDialog(
        //   context: context,
        //   builder: (_) => VideoResultPopup(video: file),
        // );
      },
    );
  }

  void _exportCover() async {
    final config = CoverFFmpegVideoEditorConfig(_controller);
    final execute = await config.getExecuteConfig();
    if (execute == null) {
      _showErrorSnackBar("Error on cover exportation initialization.");
      return;
    }
///ExportCover///
    // await ExportService.runFFmpegCommand(
    //   execute,
    //   onError: (e, s) => _showErrorSnackBar("Error on cover exportation :("),
    //   onCompleted: (cover) {
    //     if (!mounted) return;
    //
    //     showDialog(
    //       context: context,
    //       builder: (_) => CoverResultPopup(cover: cover),
    //     );
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _controller.initialized
            ? SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  topNavBar(),
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          Expanded(
                            child: TabBarView(
                              physics:
                              const NeverScrollableScrollPhysics(),
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CropGridViewer.preview(
                                        controller: _controller),
                                    AnimatedBuilder(
                                      animation: _controller.video,
                                      builder: (_, __) => AnimatedOpacity(
                                        opacity:
                                        _controller.isPlaying ? 0 : 1,
                                        duration: kThemeAnimationDuration,
                                        child: GestureDetector(
                                          onTap: _controller.video.play,
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration:
                                            const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.play_arrow,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                CoverViewer(controller: _controller)
                              ],
                            ),
                          ),
                          Container(
                            height: 200,
                            margin: const EdgeInsets.only(top: 10),
                            child: Column(
                              children: [
                                TabBar(
                                  tabs: [
                                    Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: const [
                                          Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Icon(
                                                  Icons.content_cut)),
                                          Text('Trim')
                                        ]),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: const [
                                        Padding(
                                            padding: EdgeInsets.all(5),
                                            child:
                                            Icon(Icons.video_label)),
                                        Text('Cover')
                                      ],
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: _trimSlider(),
                                      ),
                                      _coverSelection(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: _isExporting,
                            builder: (_, bool export, Widget? child) =>
                                AnimatedSize(
                                  duration: kThemeAnimationDuration,
                                  child: export ? child : null,
                                ),
                            child: AlertDialog(
                              title: ValueListenableBuilder(
                                valueListenable: _exportingProgress,
                                builder: (_, double value, __) => Text(
                                  "Exporting video ${(value * 100).ceil()}%",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
  submitReel(config) async {
    EasyLoading.show(status: LocalizationString.loading);
    Uint8List? thumbnail = await VideoThumbnail.thumbnailData(
      video: config,
      //widget.reel.path,
      //widget.reel.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 400,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );
    print('this is thumbnail**** $thumbnail');
    // showDialog(
    //   context: context,
    //   builder: (_) => VideoResultPopup(video: widget.reel),
    // );
    MediaInfo? mediaInfo = await VideoCompress.compressVideo(
      config,
       // _controller.file.path,
      // widget.reel.path,
      quality: VideoQuality.DefaultQuality,
      deleteOrigin: false, // It's false by default
    );

    EasyLoading.dismiss();
    Media media = Media();
    media.id = randomId();
    media.file = File(mediaInfo!.path!);
    media.thumbnail = thumbnail;
    media.size = null;
    media.creationTime = DateTime.now();
    media.title = null;
    media.mediaType = GalleryMediaType.video;

    Get.to(() => AddPostScreen(
      items: [media],
      isReel: true,
      audioId: widget.audioId,
      audioStartTime: widget.audioStartTime,
      audioEndTime: widget.audioEndTime,
      clubId: widget.clubId,
      competitionId: widget.competitionId,
    ));
  }

  Widget topNavBar() {
    return SafeArea(
      child: Container(
        color: const Color(0xFF1A1A1A),
            //.backgroundColor,
        height: height,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon:  Icon(Icons.arrow_back_ios,
                  color: AppColorConstants.whiteClr,),
                tooltip: 'Leave editor',
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.left),
                icon:  Icon(Icons.rotate_left,color: AppColorConstants.whiteClr,),
                tooltip: 'Rotate anti-clockwise',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.right),
                icon:  Icon(Icons.rotate_right, color: AppColorConstants.whiteClr,),
                tooltip: 'Rotate clockwise',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => CropPage(controller: _controller),
                  ),
                ),
                icon:  Icon(Icons.crop, color: AppColorConstants.whiteClr,),
                tooltip: 'Open crop screen',
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: PopupMenuButton(
                tooltip: 'Open export menu',
                icon:  Icon(Icons.check, color: AppColorConstants.whiteClr,),
                itemBuilder: (context) => [
                  // PopupMenuItem(
                  //   onTap: _exportCover,
                  //   child: const Text('Export cover'),
                  // ),
                  PopupMenuItem(
                    onTap: _exportVideo,
                    child: const Text('Post video'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
    duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
    duration.inSeconds.remainder(60).toString().padLeft(2, '0')
  ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _controller.video,
        ]),
        builder: (_, __) {
          final int duration = _controller.videoDuration.inSeconds;
          final double pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              AnimatedOpacity(
                opacity: _controller.isTrimming ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(_controller.startTrim)),
                  const SizedBox(width: 10),
                  Text(formatter(_controller.endTrim)),
                ]),
              ),
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            controller: _controller,
            padding: const EdgeInsets.only(top: 10),
          ),
        ),
      )
    ];
  }

  // Future<void> applyColorFilter(String inputPath, String outputPath) async {
  //   final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();
  //   final arguments = [
  //     '-i',
  //     inputPath,
  //     '-vf',
  //     'colorchannelmixer=rr=1:rb=0:ra=0:gr=0:gb=1:ga=0:br=0:bb=1:ba=0',
  //     outputPath,
  //   ];
  //
  //   await _ffmpeg.executeWithArguments(arguments);
  // }


  Widget _coverSelection() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: CoverSelection(
            controller: _controller,
            size: height + 10,
            quantity: 8,
            selectedCoverBuilder: (cover, size) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  cover,
                  Icon(
                    Icons.check_circle,
                    color: const CoverSelectionStyle().selectedBorderColor,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}



