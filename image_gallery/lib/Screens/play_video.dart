import 'dart:io'; // for File

import 'package:flutter/material.dart';
import 'package:image_gallery/Models/file_model.dart';
import 'package:image_gallery/Screens/full_video%20screen.dart';
import 'package:image_gallery/Utils/design_helper.dart';
import 'package:video_player/video_player.dart';

class PlayVideo extends StatefulWidget {
  final String filePath;
  final bool playButton;
  final List<VideoModel> videos;

  const PlayVideo(
      {Key? key,
      required this.filePath,
      required this.playButton,
      required this.videos})
      : super(key: key);

  @override
  State<PlayVideo> createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    converPathToVideoFile();
    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(false);
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
    _controller.pause();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  dynamic converPathToVideoFile() async {
    var file = File(widget.filePath);
    _controller = VideoPlayerController.file(file);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      padding: const EdgeInsets.all(10),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            SizedBox(
                height: _controller.value.size.height,
                width: _controller.value.size.width,
                child: VideoPlayer(_controller)),
            DesignHelper().playButton(_controller, true)
          ],
        ),
      ),
    ));
  }
}
