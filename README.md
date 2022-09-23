# Pixels

Pixels is a minimalistic pixel editor for Flutter. It also comes with a couple
of handy widgets for displaying and manipulating pixel images.

![Pixels screenshot](https://github.com/serverpod/pixels/raw/main/screenshot.png)

## Usage

```dart
class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = PixelImageController(
    palette: const PixelPalette.rPlace(),
    width: 64,
    height: 64,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: PixelEditor(
          controller: _controller,
        ),
      ),
    );
  }
}
```

## Additional information

This project is sponsored by [Serverpod](https://serverpod.dev) - the missing
server for Flutter.
