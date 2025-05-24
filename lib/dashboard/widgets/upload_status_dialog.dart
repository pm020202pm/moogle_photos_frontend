import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../upload_provider.dart';

class UploadStatusDialog extends StatelessWidget {
  const UploadStatusDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UploadProvider>(
        builder: (BuildContext context, uploadProvider, Widget? child) {
          double boxHeight = uploadProvider.files.length>5? 300: 50+(uploadProvider.files.length)*50;
          return uploadProvider.isUploading?
          Material(
            color: Colors.transparent,
            child: Container(
                height: boxHeight,
                width: 350,
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFFf8fafd),
                        borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,

                        children: [
                          const SizedBox(width: 16),
                          Text("${uploadProvider.currentUploadIndex} uploads complete", style: TextStyle(color: Color(0xFF1f1f1f), fontSize: 16, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFF1f1f1f)),
                            onPressed: () {
                              // Handle close button
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: uploadProvider.files.length,
                        itemBuilder: (context, index) {
                          String fileName = uploadProvider.files[index].path.split('\\').last;
                          String status = index>uploadProvider.currentUploadIndex? 'pending' : index<uploadProvider.currentUploadIndex? 'uploaded': 'uploading';
                          return ListTile(
                            leading: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Image.file(uploadProvider.files[index], width: 20, height: 20, fit: BoxFit.cover)),
                            title: Text(fileName),
                            trailing: (status=='pending')? Icon(Icons.cancel): (status=='uploaded')? Icon(Icons.cloud_done, color: Color(0xFF34a853),): SizedBox(width:18, height:18, child: CircularProgressIndicator(strokeWidth: 3,)),
                            onTap: () {
                              // Handle tap
                            },
                          );
                        },
                      ),
                    ),
                  ],
                )
            ),
          ): SizedBox.shrink();
        }
    );
  }
}
