

class AttachedFile {
  String fileName, path, url, contentType;
  AttachedFile({this.fileName, this.path, this.url, this.contentType});

  Map<String, String> toJson()  {
    return {
      'fileName':fileName,
      'path':url,
      'contentType':contentType,
    };
  }
}