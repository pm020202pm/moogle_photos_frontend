import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/drive_file_model.dart';
import '../widgets/photo_card.dart';
import '../providers/drive_file_provider.dart';
class PhotosTabDesktop extends StatefulWidget {
  const PhotosTabDesktop({super.key});
  @override
  State<PhotosTabDesktop> createState() => _PhotosTabDesktopState();
}

class _PhotosTabDesktopState extends State<PhotosTabDesktop> {

  final ScrollController _scrollController = ScrollController();
  late DriveFileProvider _fileProvider;

  @override
  void initState() {
    super.initState();
    _fileProvider = Provider.of<DriveFileProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fileProvider.loadFilesFromDrive(isInitialLoad: true);
    });
    _scrollController.addListener(_scroll);
  }

  void _scroll(){
    final fileProvider = Provider.of<DriveFileProvider>(context, listen: false);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !fileProvider.isAllFilesLoading && fileProvider.nextPageToken != null) {
      _fileProvider.loadFilesFromDrive(isInitialLoad: false);
    }
  }


  Map<String, List<DriveFile>> _groupByDate(List<DriveFile> files) {
    final Map<String, List<DriveFile>> grouped = {};
    for (var file in files) {
      final title = _getSectionTitle(file.modifiedTime);

      grouped.putIfAbsent(title, () => []).add(file);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final px1200 = size.width <1200;
    final px600 = size.width <600;
    return Consumer<DriveFileProvider>(
      builder: (BuildContext context, fileProvider, Widget? child) {
        final groupedFiles = _groupByDate(fileProvider.allFiles);
        return Container(
          margin: EdgeInsets.only(right: px600? 0:15),
          padding: EdgeInsets.symmetric(horizontal: px600? 0:8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(px600? 0:16),
              topRight: Radius.circular(px600? 0:16),
            ),
          ),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              if (fileProvider.allFiles.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('No photos found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),)),
                )
              else
                ...groupedFiles.entries.map((entry) {
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 16, 16, 8),
                        child: Text(entry.key,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(horizontal: px600? 0:8),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: entry.value.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: px600?4: px1200? 5:6,
                          crossAxisSpacing: px600? 2:4,
                          mainAxisSpacing: px600? 2:4,
                        ),
                        itemBuilder: (context, index) {
                          final file = entry.value[index];
                          return AnimatedOpacity(
                            opacity: 1.0,
                            duration: Duration(milliseconds: 400 + index * 30),
                            child: PhotoCard(file: file),
                          );
                        },
                      )
                    ]),
                  );
                }),

            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}


String _getSectionTitle(DateTime date) {
  final now = DateTime.now();
  if (DateUtils.isSameDay(date, now)) return 'Today';
  if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) return 'Yesterday';
  final diff = now.difference(date).inDays;
  if (diff < 7) return DateFormat('EEEE').format(date);
  return DateFormat('EEE, MMM d yyyy').format(date);
}

