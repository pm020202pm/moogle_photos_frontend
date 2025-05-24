import 'package:Photos/Login/services/login_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../Login/providers/auth_provider.dart';
import '../home/providers/drive_file_provider.dart';

class NextImageIntent extends Intent {
  const NextImageIntent();
}

class PrevImageIntent extends Intent {
  const PrevImageIntent();
}


class FullScreenImageViewer extends StatefulWidget {
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _controller;
  int currentIndex = 0;
  Map<String, Uint8List?> imageCache = {};

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
    currentIndex = widget.initialIndex;
    _controller.addListener(() {
      final newIndex = _controller.page?.round();
      if (newIndex != null && newIndex != currentIndex) {
        setState(() {
          currentIndex = newIndex;
          cleanUpImageCache(); // Clear unneeded cache entries
        });
      }
    });
  }

  void cleanUpImageCache() {
    final keepIds = <String>{};
    final fileProvider = Provider.of<DriveFileProvider>(context, listen: false);
    final allFiles = fileProvider.allFiles;

    if (currentIndex > 0) {
      keepIds.add(allFiles[currentIndex - 1].id);
    }

    keepIds.add(allFiles[currentIndex].id);

    if (currentIndex < allFiles.length - 1) {
      keepIds.add(allFiles[currentIndex + 1].id);
    }

    imageCache.removeWhere((key, _) => !keepIds.contains(key));
  }

  Future<Uint8List?> fetchImageBytes(String fileId) async {
    if (imageCache.containsKey(fileId)) {
      return imageCache[fileId];
    }
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String accessToken = authProvider.accessTokensList[0];
    if (accessToken.isEmpty) return null;
    final url = 'https://www.googleapis.com/drive/v3/files/$fileId?alt=media';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      imageCache[fileId] = response.bodyBytes;
      return response.bodyBytes;
    } else {
      print('Error fetching image $fileId: ${response.statusCode}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<DriveFileProvider>(context);
    final allFiles = fileProvider.allFiles;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          FocusableActionDetector(
            autofocus: true,
            shortcuts: {
              LogicalKeySet(LogicalKeyboardKey.arrowRight): const NextImageIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowLeft): const PrevImageIntent(),
            },
            actions: {
              NextImageIntent: CallbackAction<NextImageIntent>(
                onInvoke: (intent) {
                  if (_controller.page! < allFiles.length - 1) {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                  return null;
                },
              ),
              PrevImageIntent: CallbackAction<PrevImageIntent>(
                onInvoke: (intent) {
                  if (_controller.page! > 0) {
                    _controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                  return null;
                },
              ),
            },
            child: PageView.builder(
              controller: _controller,
              itemCount: allFiles.length,
              itemBuilder: (context, index) {
                final fileId = allFiles[index].id;

                return FutureBuilder<Uint8List?>(
                  future: fetchImageBytes(fileId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                      // Preload the next image
                      if (index + 1 < allFiles.length) {
                        final nextFileId = allFiles[index + 1].id;
                        if (!imageCache.containsKey(nextFileId)) {
                          fetchImageBytes(nextFileId); // Preload in background
                        }
                      }

                      return InteractiveViewer(
                        child: Image.memory(snapshot.data!, fit: BoxFit.contain),
                      );
                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            size.width > size.height
                                ? Image.network(allFiles[index].thumbnailLink!, fit: BoxFit.cover, height: size.height)
                                : Image.network(allFiles[index].thumbnailLink!, fit: BoxFit.cover, width: size.width),
                            const CircularProgressIndicator(),
                          ],
                        ),
                      );
                    } else {
                      return const Center(child: Text("Failed to load image"));
                    }
                  },
                );

              },
            ),
          ),
          Opacity(
            opacity: 0.8,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.grey.withOpacity(0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white,),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.info_outline_rounded, color: Colors.white,),
                    onPressed: () {
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white,),
                    onPressed: () {

                    },
                  ),

                ],
              ),
            ),
          )
        ],
      ),
    );
  }

}

