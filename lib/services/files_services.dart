import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import '../const.dart';
import 'package:http/http.dart' as http;
import '../home/models/drive_file_model.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

class FileServices {
  static Future<DriveFilesResponse> fetchDriveFiles({String? folderId, String? pageToken, String? modifiedAfter, int pageSize = 30, required String refreshToken}) async {
    final queryParams = <String, String>{
      if (folderId != null) 'folderId': folderId,
      if (pageToken != null) 'pageToken': pageToken,
      if (modifiedAfter != null) 'modifiedAfter': modifiedAfter,
      'pageSize': pageSize.toString(),
      'refreshToken' : refreshToken,
    };

    final uri = Uri.parse('$baseUrl/list-files').replace(queryParameters: queryParams);

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final files = (data['files'] as List)
          .map((json) => DriveFile.fromJson(json))
          .toList();
      final nextPageToken = data['nextPageToken'] as String?;
      return DriveFilesResponse(files: files, nextPageToken: nextPageToken);
    } else {
      throw Exception('Failed to load files');
    }
  }

  static Future<bool> deleteFileFromDrive(String accessToken, String fileId) async {
    final response = await http.delete(
        Uri.parse('https://www.googleapis.com/drive/v3/files/$fileId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        }
    );
    if (response.statusCode == 204) {
      debugPrint('✅ File deleted successfully.');
      return true;
    } else {
      debugPrint('❌ Failed to delete file: ${response.statusCode}');
      debugPrint(response.body);
      return false;
    }
  }

  static Future<String?> createDriveFolder(String accessToken, String folderName) async {
    final uri = Uri.parse('https://www.googleapis.com/drive/v3/files');
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'name': folderName,
      'mimeType': 'application/vnd.google-apps.folder',
    });

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      final folder = jsonDecode(response.body);
      return folder['id'];
    } else {
      print('❌ Failed to create folder: ${response.statusCode} - ${response.body}');
    }
    return null;
  }

  static Future<void> shareFolderWithEditor({required String folderId, required String gmailAddress, required String accessToken}) async {
    final uri = Uri.parse('https://www.googleapis.com/drive/v3/files/$folderId/permissions');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "role": "writer",
        "type": "user",
        "emailAddress": gmailAddress,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Folder shared successfully with $gmailAddress');
    } else {
      print('❌ Failed to share folder: ${response.statusCode}');
      print(response.body);
    }
  }



  static Future<int?> getDriveStorageQuota(String accessToken) async {
    final uri = Uri.parse('https://www.googleapis.com/drive/v3/about?fields=storageQuota');
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final quota = data['storageQuota'];
      return int.parse(quota['limit']) - int.parse(quota['usage']);
    } else {
      debugPrint('❌ Failed to fetch storage info: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  static Future<DriveFile?> uploadFile(File file, String accessToken, String folderId) async {
    final fileName = p.basename(file.path);
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    print('Uploading file: $fileName, MIME type: $mimeType');
    final fileBytes = await file.readAsBytes();
    final fileSize = fileBytes.length;

    final sessionUrl = await initiateResumableSession(accessToken, fileName, mimeType, fileSize, folderId);

    if (sessionUrl != null) {
      DriveFile? file= await uploadFileChunks(sessionUrl, fileBytes, mimeType);
      return file;
    }
    return null;
  }

  static Future<DriveFile?> uploadFileChunks(String uploadUrl, List<int> fileBytes, String mimeType) async {
    final response = await http.put(
      Uri.parse(uploadUrl),
      headers: {
        'Content-Type': mimeType,
        'Content-Length': '${fileBytes.length}',
        'Content-Range': 'bytes 0-${fileBytes.length - 1}/${fileBytes.length}',
      },
      body: fileBytes,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      DriveFile driveFile = DriveFile.fromJson(data);
      return driveFile;
    } else {
      debugPrint('❌ Upload failed: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  static Future<String?> initiateResumableSession(String accessToken, String fileName, String mimeType, int fileSize, String folderId) async {

    final response = await http.post(
        Uri.parse('https://www.googleapis.com/upload/drive/v3/files?uploadType=resumable&fields=id,name,size,parents,modifiedTime, createdTime, mimeType, thumbnailLink, owners(emailAddress)'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json; charset=UTF-8',
          'X-Upload-Content-Type': mimeType,
          'X-Upload-Content-Length': '$fileSize',
        },
        body: jsonEncode({
          'name': fileName,
          'parents': [folderId]
        })
    );

    if (response.statusCode == 200) {
      return response.headers['location'];
    } else {
      print('Failed to initiate resumable upload: ${response.body}');
      return null;
    }
  }
}

class DriveFilesResponse {
  final List<DriveFile> files;
  final String? nextPageToken;
  DriveFilesResponse({required this.files, this.nextPageToken});
}