import 'dart:io'; // for File

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery/Models/file_model.dart';
import 'package:image_gallery/Utils/design_helper.dart';
import 'package:video_player/video_player.dart';

class FullVideo extends StatefulWidget {
  final List<VideoModel> videoList;
  final bool playButton;
  const FullVideo({Key? key, required this.videoList, required this.playButton})
      : super(key: key);

  @override
  State<FullVideo> createState() => _FullVideoState();
}

class _FullVideoState extends State<FullVideo> {
  late final List<VideoPlayerController> _controller = [];
  @override
  void initState() {
    super.initState();
    converPathToVideoFile();
    prepareController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void prepareController() {
    for (int i = 0; i < _controller.length; i++) {
      _controller[i].addListener(() {
        setState(() {});
      });
      _controller[i].setLooping(false);
      _controller[i].initialize().then((_) => setState(() {}));
      _controller[i].pause();
    }
  }

  void converPathToVideoFile() async {
    File file;
    for (int i = 0; i < widget.videoList.length; i++) {
      file = File(widget.videoList[i].filePath);
      _controller.add(VideoPlayerController.file(file));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Video gallery"),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(
          child: SizedBox(
            height: double.infinity,
            child: CarouselSlider.builder(
              itemCount: widget.videoList.length,
              itemBuilder: (context, i, realIndex) => Container(
                padding: const EdgeInsets.all(10),
                child: AspectRatio(
                  aspectRatio: _controller[i].value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      SizedBox(
                          height: _controller[i].value.size.height,
                          width: _controller[i].value.size.width,
                          child: VideoPlayer(_controller[i])),
                      DesignHelper().playButton(_controller[i], true)
                    ],
                  ),
                ),
              ),
              options: CarouselOptions(
                  aspectRatio: 0.7,
                  autoPlay: false,
                  onPageChanged: (index, reason) {
                    _controller[index].value.isPlaying
                        ? _controller[index].pause()
                        : _controller[index].play();
                  },
                  reverse: false),
            ),
          ),
        ));
  }
}
