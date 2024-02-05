import 'package:chewie/chewie.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foap/components/custom_texts.dart';
import 'package:foap/helper/enum.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/helper/localization_strings.dart';
import 'package:foap/screens/add_on/ui/reel/reel_edit_screen.dart';
import 'package:foap/screens/chat/media.dart';
import 'package:foap/screens/post/add_post_screen.dart';
import 'package:foap/theme/theme_icon.dart';
import 'package:foap/util/app_config_constants.dart';
import 'package:foap/util/constant_util.dart';
import 'package:get/get.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class PreviewReelsScreen extends StatefulWidget {
  final File reel;
  final int? audioId;
  final double? audioStartTime;
  final double? audioEndTime;

  const PreviewReelsScreen(
      {Key? key,
        required this.reel,
        this.audioId,
        this.audioStartTime,
        this.audioEndTime})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PreviewReelsState();
  }
}

class _PreviewReelsState extends State<PreviewReelsScreen> {
  ChewieController? chewieController;
  VideoPlayerController? videoPlayerController;
  final double height = 60;
   late final VideoEditorController controller
   = VideoEditorController.file(
    widget.reel,
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(seconds: 10),
  );

  @override
  void initState() {
    controller.video.play();
    videoPlayerController = VideoPlayerController.file(widget.reel);
    videoPlayerController!.initialize().then((value) {
      if (!mounted) {
        return;
      }
      chewieController = ChewieController(
        aspectRatio: videoPlayerController!.value.aspectRatio,
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: true,
        showControls: false,
        showOptions: false,
      );
      // controller = VideoEditorController.file(
      //   widget.reel,
      //   minDuration: const Duration(seconds: 1),
      //   maxDuration: const Duration(minutes: 10),
      // );
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    chewieController!.dispose();
    videoPlayerController!.dispose();
    chewieController?.pause();
  }

  String formatter(Duration duration) => [
    duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
    duration.inSeconds.remainder(60).toString().padLeft(2, '0')
  ].join(":");

  List<Widget> trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          controller,
          controller.video,
        ]),
        builder: (_, __) {
          final int duration = controller.videoDuration.inSeconds;
          final double pos = controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              AnimatedOpacity(
                opacity: controller.isTrimming ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(controller.startTrim)),
                  const SizedBox(width: 10),
                  Text(formatter(controller.endTrim)),
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
          controller: controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            controller: controller,
            padding: const EdgeInsets.only(top: 10),
          ),
        ),
      )
    ];
  }

  Widget coverSelection() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: CoverSelection(
            controller: controller,
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          // alignment: Alignment.topCenter,
          // fit: StackFit.loose,
            children: [
              const SizedBox(
                height: 50,
              ),
              // chewieController == null
              //     ? Container()
              //     : SizedBox(
              //   height: 400,
              //   // (MediaQuery.of(context).size.width - 32) /
              //   //     videoPlayerController!.value.aspectRatio,
              //   child: Chewie(
              //     controller: chewieController!,
              //   ),
              // ).round(20),
              controller == null
                  ? Container()
                  : SizedBox(
                height: 400,
                // height: (MediaQuery.of(context).size.width - 32) /
                //           videoPlayerController!.value.aspectRatio,
                child: Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: TabBarView(
                      physics:
                      const NeverScrollableScrollPhysics(),
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CropGridViewer.preview(
                                controller: controller),
                            chewieController == null
                                ? Container()
                                : SizedBox(
                              height: 400,
                              // (MediaQuery.of(context).size.width - 32) /
                              //     videoPlayerController!.value.aspectRatio,
                              child: Chewie(
                                controller: chewieController!,
                              ),
                            ).round(20),
                            // AnimatedBuilder(
                            //   animation: controller.video,
                            //   builder: (_, __) => AnimatedOpacity(
                            //     opacity:
                            //     controller.isPlaying ? 0 : 1,
                            //     duration: kThemeAnimationDuration,
                            //     child: GestureDetector(
                            //       onTap: () {
                            //         controller.video.play;
                            //         controller.video.videoPlayerOptions!.allowBackgroundPlayback;
                            //       },
                            //       child: Container(
                            //         width: 40,
                            //         height: 40,
                            //         decoration:
                            //         const BoxDecoration(
                            //           color: Colors.white,
                            //           shape: BoxShape.circle,
                            //         ),
                            //         child: const Icon(
                            //           Icons.play_arrow,
                            //           color: Colors.black,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        CoverViewer(controller: controller)
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 5,
              ),
              // Row(
              //   children: [
              //     Container(
              //       height: 20,
              //       margin: const EdgeInsets.only(top: 10),
              //       child: Column(
              //         children: [
              //           TabBar(
              //             tabs: [
              //               Row(
              //                   mainAxisAlignment:
              //                   MainAxisAlignment.center,
              //                   children: const [
              //                     Padding(
              //                         padding: EdgeInsets.all(5),
              //                         child: Icon(
              //                             Icons.content_cut)),
              //                     Text('Trim')
              //                   ]),
              //               Row(
              //                 mainAxisAlignment:
              //                 MainAxisAlignment.center,
              //                 children: const [
              //                   Padding(
              //                       padding: EdgeInsets.all(5),
              //                       child:
              //                       Icon(Icons.video_label)),
              //                   Text('Cover')
              //                 ],
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ThemeIconWidget(
                    ThemeIcon.backArrow,
                    size: 25,
                  ).circular.ripple(() {
                    Get.back();
                  }),
                  // editOptions(),
                  const VerticalDivider(endIndent: 22, indent: 22),
                  Expanded(
                    child: IconButton(
                      onPressed: () {
                        controller.rotate90Degrees(RotateDirection.left);
                      },
                      icon: const Icon(Icons.rotate_left),
                      tooltip: 'Rotate anti-clockwise',
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () =>
                          controller.rotate90Degrees(RotateDirection.right),
                      icon: const Icon(Icons.rotate_right),
                      tooltip: 'Rotate clockwise',
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => CropPage(controller: controller),
                        ),
                      ),
                      icon: const Icon(Icons.crop),
                      tooltip: 'Open crop screen',
                    ),
                  ),
                  const VerticalDivider(endIndent: 22, indent: 22),
                  // Expanded(
                  //   child: PopupMenuButton(
                  //     tooltip: 'Open export menu',
                  //     icon: const Icon(Icons.save),
                  //     itemBuilder: (context) => [
                  //       PopupMenuItem(
                  //         onTap: _exportCover,
                  //         child: const Text('Export cover'),
                  //       ),
                  //       PopupMenuItem(
                  //         onTap: _exportVideo,
                  //         child: const Text('Export video'),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Container(
                      color: AppColorConstants.themeColor,
                      child: Text(
                        LocalizationString.next,
                        style: TextStyle(
                            fontSize: FontSizes.b2,),
                      ).setPadding(left: 16, right: 16, bottom: 8, top: 8))
                      .circular
                      .ripple(() {
                    submitReel();
                  }),
                ],
              ),
              const SizedBox(
                height: 20,
              )
            ]).hP16,
      ),
    );
  }

  submitReel() async {
    EasyLoading.show(status: LocalizationString.loading);
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: widget.reel.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 400,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    MediaInfo? mediaInfo = await VideoCompress.compressVideo(
      widget.reel.path,
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
    ));
  }
}
