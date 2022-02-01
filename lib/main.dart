// // ignore_for_file: deprecated_member_use, unnecessary_new

// import 'package:flutter/material.dart';
// import 'package:sms_retriever/sms_retriever.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   String _smsCode = "";
//   bool isListening = false;

//   getCode(String sms) {
//     // ignore: unnecessary_null_comparison
//     if (sms != null) {
//       final intRegex = RegExp(r'\d+', multiLine: true);
//       final code = intRegex.allMatches(sms).first.group(0);
//       return code;
//     }
//     return "NO SMS";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Sms retriever example app'),
//           backgroundColor: isListening ? Colors.green : Colors.amber,
//         ),
//         body: new Center(
//           child: new Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               FutureBuilder(
//                 builder: (context, data) {
//                   return Text('SIGNATURE: ${data.data}');
//                 },
//                 future: SmsRetriever.getAppSignature(),
//               ),
//               Text('SMS CODE: $_smsCode \n'),
//               const Text(
//                   'Press the button below to start\nlistening for an incoming SMS'),
//               new RaisedButton(
//                 onPressed: () async {
//                   isListening = true;
//                   setState(() {});
//                   String smsCode = await SmsRetriever.startListening();
//                   _smsCode = getCode(smsCode);
//                   isListening = false;
//                   setState(() {});
//                   SmsRetriever.stopListening();
//                 },
//                 child: Text(isListening ? "STOP" : "START"),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ignore: prefer_final_fields
  String _message = "";
  final telephony = Telephony.instance;
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body ?? "Error reading message body.";
    });
  }

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SMS Listener App'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text("Latest received SMS: $_message")),
            TextButton(
                onPressed: () async {
                  await telephony.openDialer("123413453");
                },
                child: const Text('Open Dialer'))
          ],
        ),
      ),
    );
  }
}
