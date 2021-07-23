import 'dart:async';

class EditLocationValidators  {
  StreamTransformer addressLine1StreamTransformer=StreamTransformer<String, String>.fromHandlers(
      handleData: (String addressLine1, EventSink<String> eventSink) {
        if(addressLine1.length>2)  {
          eventSink.add(addressLine1);
        } else  {
          eventSink.addError('Address Line 1 should contain at least 3 Characters');
        }
      }
  );
  StreamTransformer addressLine2StreamTransformer=StreamTransformer<String, String>.fromHandlers(
      handleData: (String addressLine2, EventSink<String> eventSink) {
        if(addressLine2.length>2)  {
          eventSink.add(addressLine2);
        } else  {
          eventSink.addError('Address Line 2 should contain at least 3 Characters');
        }
      }
  );
}