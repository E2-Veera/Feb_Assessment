import 'dart:convert';

List<VideoModel> filesFromJson(String str) =>
    List<VideoModel>.from(json.decode(str).map((x) => VideoModel.fromJson(x)));

String filesToJson(List<VideoModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VideoModel {
  int fileID;
  String filePath;
  String fileType;
  String fileExtension;

  VideoModel({
    required this.fileID,
    required this.filePath,
    required this.fileType,
    required this.fileExtension,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
      fileID: json["file_id"],
      filePath: json["file_path"],
      fileType: json["file_type"],
      fileExtension: json["file_extension"]);

  Map<String, dynamic> toJson() => {
        "file_id": fileID,
        "file_path": filePath,
        "file_type": fileType,
        "file_extension": fileExtension
      };
}
