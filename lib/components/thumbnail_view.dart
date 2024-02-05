import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:foap/helper/imports/common_import.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../model/story_model.dart';
import 'package:path_provider/path_provider.dart';

class MediaThumbnailView extends StatefulWidget {
  final StoryMediaModel media;

  final double? size;
  final Color? borderColor;

  const MediaThumbnailView({
    Key? key,
    required this.media,
    this.size,
    this.borderColor,
  }) : super(key: key);

  @override
  State<MediaThumbnailView> createState() => _MediaThumbnailViewState();
}

class _MediaThumbnailViewState extends State<MediaThumbnailView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
            height: widget.size ?? 50,
            width: widget.size ?? 50,
            child: widget.media.type == 3
                ? // 1 for text, 2 for image, 3 for video
                FutureBuilder<ThumbnailResult>(
                    future: genThumbnail(widget.media.video!= null ?
                    widget.media.video.toString() : widget.media.image.toString()),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        final image = snapshot.data.image;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            image,
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.red,
                          child: Text(
                            "Error:\n${snapshot.error.toString()}",
                          ),
                        );
                      } else {
                        return const CircularProgressIndicator().p16;
                      }
                    },
                  )
                : CachedNetworkImage(
                    imageUrl: widget.media.image!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => SizedBox(
                        height: 20,
                        width: 20,
                        child: const CircularProgressIndicator().p16),
                    errorWidget: (context, url, error) => const SizedBox(
                        height: 20, width: 20, child: Icon(Icons.error)),
                  ).round(18).p(1))
        .borderWithRadius(
            value: 2,
            radius: 20,
            color: widget.borderColor ?? AppColorConstants.themeColor);
  }
}

Future<ThumbnailResult> genThumbnail(String path) async {
  //WidgetsFlutterBinding.ensureInitialized();
  Directory tempDirPath = await getTemporaryDirectory();
  Uint8List bytes;
  final Completer<ThumbnailResult> completer = Completer();
  final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: path,
      // headers: {
      //   "USERHEADER1": "user defined header1",
      //   "USERHEADER2": "user defined header2",
      // },
      thumbnailPath: tempDirPath.path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 50,
      maxWidth: 50,
      timeMs: 0,
      quality: 50);

  if (thumbnailPath != null) {
    final file = File(thumbnailPath);
    bytes = file.readAsBytesSync();

    int imageDataSize = bytes.length;

    final image = Image.memory(bytes);
    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(ThumbnailResult(
        image: image,
        dataSize: imageDataSize,
        height: info.image.height,
        width: info.image.width,
      ));
    }));
  }

  return completer.future;
}

class ThumbnailResult {
  final Image image;
  final int dataSize;
  final int height;
  final int width;

  const ThumbnailResult(
      {required this.image,
      required this.dataSize,
      required this.height,
      required this.width});
}
