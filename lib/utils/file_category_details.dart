
class FileCategoryDetails {
  String formatBytes(int bytes) {

    if(bytes < 1024) return (bytes).toString() + " bytes";
    else if(bytes < 1048576) return(bytes / 1024).toStringAsFixed(2) + " KB";
    else if(bytes < 1073741824) return(bytes / 1048576).toStringAsFixed(2) + " MB";
    else return(bytes / 1073741824).toStringAsFixed(2) + " GB";
  }
}