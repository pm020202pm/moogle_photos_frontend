import 'package:Photos/dashboard/widgets/profile_button.dart';
import 'package:Photos/services/files_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/drive_file_model.dart';
import '../../dashboard/widgets/bottom_action_bar.dart';
import '../widgets/photo_card.dart';
import '../../dashboard/widgets/upload_icon.dart';
import '../providers/drive_file_provider.dart';

class DriveFilesPage extends StatefulWidget {
  const DriveFilesPage({super.key, required this.folderId});
  final String folderId;

  @override
  State<DriveFilesPage> createState() => _DriveFilesPageState();
}

class _DriveFilesPageState extends State<DriveFilesPage> {
  String? _nextPageToken;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  bool _showAppBar = true;
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialFiles();

    _scrollController.addListener(() {
      final currentOffset = _scrollController.offset;
      if (currentOffset > _lastOffset + 10 && _showAppBar) {
        setState(() => _showAppBar = false);
      } else if (currentOffset < _lastOffset - 10 && !_showAppBar) {
        setState(() => _showAppBar = true);
      }
      _lastOffset = currentOffset;

      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading && _nextPageToken != null) {
        _loadMoreFiles();
      }
    });
  }

  void _loadInitialFiles() async {
    setState(() => _isLoading = true);
    final response = await FileServices.fetchDriveFiles(folderId: widget.folderId, refreshToken: '');
    final fileProvider = Provider.of<DriveFileProvider>(context, listen: false);
    setState(() {
      fileProvider.setFiles(response.files);
      // _allFiles = response.files;
      _nextPageToken = response.nextPageToken;
      _isLoading = false;
    });
  }

  void _loadMoreFiles() async {
    if (_nextPageToken == null) return;
    setState(() => _isLoading = true);
    final response = await FileServices.fetchDriveFiles(folderId: widget.folderId, pageToken: _nextPageToken, refreshToken: '');
    final fileProvider = Provider.of<DriveFileProvider>(context, listen: false);
    setState(() {
      fileProvider.addMoreFiles(response.files);
      // _allFiles.addAll(response.files);
      _nextPageToken = response.nextPageToken;
      _isLoading = false;
    });
  }

  String _getSectionTitle(DateTime date) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(date, now)) return 'Today';
    if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) return 'Yesterday';
    final diff = now.difference(date).inDays;
    if (diff < 7) return DateFormat('EEEE').format(date);
    return DateFormat('EEE, MMM d').format(date);
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
    final fileProvider = Provider.of<DriveFileProvider>(context);
    final groupedFiles = _groupByDate(fileProvider.allFiles);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 300),
                  offset: _showAppBar ? Offset.zero : const Offset(0, -1),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _showAppBar ? 1.0 : 0.0,
                    child: Container(
                      padding: const EdgeInsets.only(top: 32),
                      color: Colors.grey.shade50,
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text('Google Photos',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _loadInitialFiles,
                          ),
                          IconButton(onPressed: () async {
                          }, icon: Icon(Icons.logout)),
                          UploadIcon(),
                          ProfileButton(),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (fileProvider.allFiles.isEmpty && _isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                ...groupedFiles.entries.map((entry) {
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(entry.key,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: entry.value.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
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
              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: fileProvider.selectedFileIds.isNotEmpty
          ? BottomActionBar()
          : null,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
