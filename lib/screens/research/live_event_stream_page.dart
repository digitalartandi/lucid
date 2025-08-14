import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../apple_ui/widgets/large_nav_scaffold.dart';
import '../../apple_ui/widgets/section_list.dart';

class LiveEventStreamPage extends StatefulWidget {
  const LiveEventStreamPage({super.key});
  @override State<LiveEventStreamPage> createState()=> _LiveEventStreamPageState();
}

class _LiveEventStreamPageState extends State<LiveEventStreamPage> {
  final urlCtrl = TextEditingController(text: 'ws://127.0.0.1:8765/lucid');
  WebSocketChannel? ch;
  final lines = <String>[];
  StreamSubscription? sub;

  void _connect() {
    _disconnect();
    try {
      ch = IOWebSocketChannel.connect(Uri.parse(urlCtrl.text.trim()));
      sub = ch!.stream.listen((msg){
        setState(()=> lines.insert(0, msg.toString()));
      }, onError: (e){
        setState(()=> lines.insert(0, 'ERR: $e'));
      }, onDone: (){
        setState(()=> lines.insert(0, 'DISCONNECTED'));
      });
      setState(()=> lines.insert(0, 'CONNECTED'));
    } catch (e) {
      setState(()=> lines.insert(0, 'ERR: $e'));
    }
  }

  void _disconnect() {
    sub?.cancel(); sub=null;
    ch?.sink.close(); ch=null;
  }

  @override
  void dispose() { _disconnect(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return LargeNavScaffold(title: 'Live‑Event‑Stream', child: Column(children: [
      Section(children: [
        RowItem(title: const Text('WebSocket URL'), subtitle: Text(urlCtrl.text),
          onTap: () async {
            await showCupertinoDialog(context: context, builder: (ctx)=> CupertinoAlertDialog(
              title: const Text('WebSocket URL'),
              content: CupertinoTextField(controller: urlCtrl, placeholder: 'ws://host:port/path'),
              actions: [
                CupertinoDialogAction(onPressed: ()=> Navigator.pop(ctx), child: const Text('Abbrechen')),
                CupertinoDialogAction(isDefaultAction: true, onPressed: ()=> Navigator.pop(ctx), child: const Text('OK')),
              ],
            ));
            setState((){});
          }),
        RowItem(title: const Text('Verbinden'), subtitle: const Text('Startet Live‑Stream'), onTap: _connect),
        RowItem(title: const Text('Trennen'), onTap: _disconnect),
      ]),
      Section(header: 'Events (neu → oben)', children: [
        for (final s in lines.take(30)) RowItem(title: Text(s)),
      ]),
    ]));
  }
}
