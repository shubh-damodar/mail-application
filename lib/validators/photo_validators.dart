import 'dart:async';
import 'dart:io';

mixin PhotoValidators {
  StreamTransformer profileImagePhotoFileStreamTransformer=StreamTransformer<File, File>.fromHandlers(
      handleData: (File profileImageFile, EventSink<File> eventSink)  {
        if(profileImageFile!=null)  {
          eventSink.add(profileImageFile);
        }
      }
  );
  StreamTransformer bannerImagePhotoFileStreamTransformer=StreamTransformer<File, File>.fromHandlers(
      handleData: (File bannerImageFile, EventSink<File> eventSink)  {
        if(bannerImageFile!=null)  {
          eventSink.add(bannerImageFile);
        }
      }
  );
}
