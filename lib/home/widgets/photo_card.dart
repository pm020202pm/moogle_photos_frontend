import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drive_file_model.dart';
import '../../full_image_viewer_page/full_image_page.dart';
import '../providers/drive_file_provider.dart';
class PhotoCard extends StatefulWidget {
  const PhotoCard({super.key, required this.file});
  final DriveFile file;
  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<DriveFileProvider>(context, listen: false);
    bool isSelected = fileProvider.selectedFileIds.contains(widget.file.id);
    bool isSelectionActive = fileProvider.selectedFileIds.isNotEmpty;
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        InkWell(
          onTap: () {
              if(!isSelected && !isSelectionActive) {
                int index = fileProvider.allFiles.indexOf(widget.file);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImageViewer(initialIndex: index),
                  ),
                );
              }
            if(fileProvider.selectedFileIds.isNotEmpty) {
              fileProvider.toggleSelection(widget.file.id);
            }
          },
          onLongPress: () => fileProvider.toggleSelection(widget.file.id),
          child: Container(
            color: Color(0xFFe9eef6),
            child: Container(
              margin: EdgeInsets.all(isSelected ? 14 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isSelected? 8:0),
                image: widget.file.thumbnailLink != null
                    ? DecorationImage(
                  image: NetworkImage(widget.file.thumbnailLink!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: widget.file.thumbnailLink == null
                  ? const Center(child: Icon(Icons.insert_drive_file, size: 30))
                  : null,
            ),
          ),
        ),
        if (isSelected)
          Padding(
            padding: const EdgeInsets.all(6),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color:Colors.white, width: 14, height: 14,
                ),
                Icon(Icons.check_circle, size: 24, color: Color(0xFF0b57d0)),
              ],
            ),
          ),
      ],
    );
  }
}
