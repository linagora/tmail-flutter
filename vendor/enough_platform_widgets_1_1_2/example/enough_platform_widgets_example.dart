import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      title: 'Platform App Example',
      material: (context, platform) => MaterialAppData(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text('Hello World'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  SelectablePlatformListTile(
                    title: Text('List Tile 1'),
                  ),
                  SelectablePlatformListTile(
                    title: Text('List Tile 2'),
                  ),
                  SelectablePlatformListTile(
                    title: Text('List Tile 3'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
