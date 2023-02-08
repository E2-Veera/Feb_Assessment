// ignore_for_file: prefer_const_constructors

import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_gallery/Models/file_model.dart';
import 'package:image_gallery/Screens/full_video%20screen.dart';
import 'package:image_gallery/Screens/play_video.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  final String _path = "";
  List<String?> _paths = [];
  final FileType _pickingType = FileType.video;
  List<String?> filePaths = [];
  List<VideoModel> fileModelList = [];
  int variableSet = 0;
  ScrollController? _scrollController;
  double? width;
  double? height;

  void openFileExplorer() async {
    filePaths.clear();
    FilePickerResult? result;
    result = await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: true,
        onFileLoading: (FilePickerStatus status) async {
          EasyLoading.show(
            status: 'Please wait...',
            maskType: EasyLoadingMaskType.black,
            dismissOnTap: false,
          );
        });

    if (result != null) {
      _paths = result.paths.map((path) => path).toList();
    } else {
      // User canceled the picker
    }

    if (!mounted) return;

    if (_paths.isNotEmpty || _path.isNotEmpty) {
      if (_paths.isNotEmpty) {
        filePaths.addAll(_paths);
      } else {
        filePaths.add(_path);
      }

      for (int i = 0; i < filePaths.length; i++) {
        VideoModel fileModel = VideoModel(
            fileID: 0, filePath: "", fileType: "", fileExtension: "");

        String mimeStr;
        List<String> fileType;
        mimeStr = lookupMimeType(filePaths[i].toString())!;

        fileType = mimeStr.split('/');
        fileModel.fileID = i;
        fileModel.filePath = filePaths[i]!;
        fileModel.fileType = fileType[0];
        fileModel.fileExtension = fileType[1];
        fileModelList.add(fileModel);
      }
    }
    EasyLoading.dismiss();
    if (mounted) {
      setState(() {});
    }
  }

  void checkPermissonAndOpenFileView() async {
    if (await Permission.storage.request().isGranted) {
      openFileExplorer();
    } else if (await Permission.storage.request().isDenied) {
      /// User deniw=ed the permission
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text('Storage Permission'),
                content: const Text(
                    'This app needs Storage access for upload pictures who being interviewed'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  TextButton(
                    onPressed: () => openAppSettings(),
                    child: const Text('Settings'),
                  ),
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey[100],
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Video gallery'),
          actions: [
            IconButton(
                onPressed: () {
                  checkPermissonAndOpenFileView();
                },
                icon: const Icon(Icons.video_collection))
          ],
        ),
        body: fileModelList.isNotEmpty
            ? Center(
                child: DragAndDropGridView(
                  controller: _scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 4.5,
                  ),
                  padding: const EdgeInsets.all(20),
                  itemBuilder: (context, index) => Card(
                    elevation: 2,
                    child: LayoutBuilder(
                      builder: (context, constrains) {
                        if (variableSet == 0) {
                          height = constrains.maxHeight;
                          width = constrains.maxWidth;
                          variableSet++;
                        }
                        return GestureDetector(
                          onTap: () {
                            showFullVideoPage(
                                fileModelList[index].filePath, true);
                          },
                          child: GridTile(
                              child: SizedBox(
                            height: 40,
                            child: Stack(children: [
                              // Text(fileModelList[index].filePath),
                              PlayVideo(
                                  filePath: fileModelList[index].filePath,
                                  playButton: true,
                                  videos: fileModelList),
                              Container(
                                height: 40,
                                width: double.infinity,
                                color: Colors.black,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 148.0),
                                  child: IconButton(
                                      onPressed: () {
                                        List<VideoModel> tempList = [];
                                        if (fileModelList.isNotEmpty) {
                                          tempList.addAll(fileModelList);
                                          tempList.removeAt(index);
                                          fileModelList.clear();
                                        }
                                        if (tempList.isNotEmpty &&
                                            fileModelList.isEmpty) {
                                          fileModelList.addAll(tempList);
                                        }
                                        if (mounted) {
                                          setState(() {
                                            // Your state change code goes here
                                          });
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      )),
                                ),
                              )
                            ]),
                          )),
                        );
                      },
                    ),
                  ),
                  itemCount: fileModelList.length,
                  onWillAccept: (oldIndex, newIndex) => true,
                  onReorder: (oldIndex, newIndex) {
                    final temp = fileModelList[oldIndex];
                    fileModelList[oldIndex] = fileModelList[newIndex];
                    fileModelList[newIndex] = temp;
                    if (mounted) {
                      setState(() {
                        // Your state change code goes here
                      });
                    }
                  },
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "No Video file picked",
                      style: TextStyle(fontSize: 20, color: Colors.blueGrey),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(18.0),
                    child: ElevatedButton(
                        onPressed: () {
                          checkPermissonAndOpenFileView();
                        },
                        child: Text("Choose Videos")),
                  )
                ],
              ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.black,
            child: Icon(Icons.clear_all),
            onPressed: () {
              fileModelList.clear();
              if (mounted) {
                setState(() {});
              }
            },
          ),
        ));
  }

  showFullVideoPage(String path, bool flag) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => FullVideo(
              videoList: fileModelList,
              playButton: flag,
            )));
  }
}
