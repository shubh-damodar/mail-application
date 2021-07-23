import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
class FeaturePermissions {
  Future<bool> checkPermission(PermissionGroup permissionGroupRequested) async {
      PermissionStatus permissionStatus = await PermissionHandler()
          .checkPermissionStatus(permissionGroupRequested);

      if (permissionStatus != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissionsMap =
        await PermissionHandler()
            .requestPermissions([PermissionGroup.storage]);
        //print('~~~ 1st permissionStatus: ${permissionsMap[permissionGroupRequested]}');
        if (permissionsMap[permissionGroupRequested] == PermissionStatus.granted) {
          //print('~~~ 2nd permissionStatus: ${permissionsMap[permissionGroupRequested]}');
          return true;
        }
      } else {
        return true;
      }
    }

  Future<String> findLocalPath() async {
    final externalStorageDirectory= await getExternalStorageDirectory();
    return externalStorageDirectory.path;
  }
}