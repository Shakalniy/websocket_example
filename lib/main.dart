import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'WebSocket Demo';
    return const MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebSocketChannel channel;
  final String uri = 'wss://ws-feed.pro.coinbase.com';
  final String noDataMessage = "No data";
  bool channelIsOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              alignment: Alignment.topCenter,
              child: StreamBuilder(
                stream: channel.stream,
                builder: (context, snapshot) {
                  return snapshot.hasData && channelIsOpen
                    ? CoinWidget(data: jsonDecode(snapshot.data) as Map<String, dynamic>)
                    : Text(
                      noDataMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20
                      ),
                    );
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              onPressed: closeChannel,
              child: const Icon(Icons.close),
            ),
            FloatingActionButton(
              onPressed: _sendMessage,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    channel = WebSocketChannel.connect(Uri.parse(uri));
    super.initState();
  }

  void _sendMessage() {
    channel = WebSocketChannel.connect(Uri.parse(uri));
    channel.sink.add(jsonEncode({
      "type": "subscribe",
      "channels": [{
        "name": "ticker",
        "product_ids": ["BTC-USD"]
      }]
    }));
    setState(() {
      channelIsOpen = true;
    });
  }

  void closeChannel() {
    channel.sink.close();
    setState(() {
      channelIsOpen = false;
    });
  }

  @override
  void dispose() {
    closeChannel();
    super.dispose();
  }
}


class CoinWidget extends StatelessWidget {
  const CoinWidget({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "${data["product_id"]}",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20
          ),
        ),
        Text(
          "${data["price"]}",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20
          ),
        )
      ],
    );
  }
}
