import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

enum ChatMediaType { image, video, document, other }

class ChatAttachmentWidget extends StatelessWidget {
  final dynamic messageData;
  final bool isSender;

  const ChatAttachmentWidget({
    Key? key,
    required this.messageData,
    this.isSender = false,
  }) : super(key: key);

  /// Resolves any relative or absolute URL to a fully qualified URL
  static String resolveAttachmentUrl(dynamic attachment) {
    if (attachment == null) return '';
    if (attachment is String) {
      final str = attachment.trim();
      if (str.isEmpty) return '';
      if (str.startsWith('http://') || str.startsWith('https://')) return str;
      if (str.startsWith('/images/')) return '$url${str.substring(1)}';
      if (str.startsWith('images/')) return '$url$str';
      if (str.startsWith('/')) return '$url${str.substring(1)}';
      return '$assetURL$str';
    }
    if (attachment is Map) {
      final raw = attachment['download_url'] ??
          attachment['downloadUrl'] ??
          attachment['url'] ??
          attachment['file_url'] ??
          attachment['filePath'] ??
          attachment['filepath'] ??
          attachment['filename'];
      if (raw != null && raw.toString().trim().isNotEmpty) {
        return resolveAttachmentUrl(raw.toString().trim());
      }
    }
    return '';
  }

  /// Classifies attachment media type by mime_type or file extension
  static ChatMediaType detectMediaType(dynamic attachment) {
    String mime = '';
    String name = '';
    String urlStr = '';

    if (attachment is Map) {
      mime = (attachment['mime_type'] ?? '').toString().toLowerCase();
      name = (attachment['name'] ?? '').toString().toLowerCase();
      urlStr = (attachment['url'] ?? attachment['download_url'] ?? '').toString().toLowerCase();
    } else if (attachment is String) {
      urlStr = attachment.toLowerCase();
      name = attachment.split('/').last.toLowerCase();
    }

    if (mime.startsWith('image/') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.webp') ||
        name.endsWith('.gif') ||
        urlStr.endsWith('.jpg') ||
        urlStr.endsWith('.jpeg') ||
        urlStr.endsWith('.png') ||
        urlStr.endsWith('.webp')) {
      return ChatMediaType.image;
    }

    if (mime.startsWith('video/') ||
        name.endsWith('.mp4') ||
        name.endsWith('.mov') ||
        name.endsWith('.mkv') ||
        name.endsWith('.webm') ||
        name.endsWith('.3gp') ||
        urlStr.endsWith('.mp4') ||
        urlStr.endsWith('.mov') ||
        urlStr.endsWith('.mkv') ||
        urlStr.endsWith('.webm')) {
      return ChatMediaType.video;
    }

    if (mime == 'application/pdf' ||
        mime.contains('pdf') ||
        mime.contains('document') ||
        mime.contains('word') ||
        mime.contains('excel') ||
        name.endsWith('.pdf') ||
        name.endsWith('.doc') ||
        name.endsWith('.docx') ||
        name.endsWith('.xls') ||
        name.endsWith('.xlsx') ||
        name.endsWith('.txt') ||
        urlStr.endsWith('.pdf') ||
        urlStr.endsWith('.doc') ||
        urlStr.endsWith('.docx')) {
      return ChatMediaType.document;
    }

    return ChatMediaType.other;
  }

  static String getAttachmentName(dynamic attachment) {
    if (attachment is Map) {
      final name = attachment['name']?.toString();
      if (name != null && name.trim().isNotEmpty) return name;
      final urlStr = attachment['url']?.toString() ?? attachment['download_url']?.toString();
      if (urlStr != null && urlStr.trim().isNotEmpty) {
        return urlStr.split('/').last;
      }
    } else if (attachment is String) {
      return attachment.split('/').last;
    }
    return 'attachment';
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> attachments = [];

    if (messageData is Map) {
      if (messageData['attachments'] is List &&
          (messageData['attachments'] as List).isNotEmpty) {
        attachments = List.from(messageData['attachments']);
      } else if (messageData['gallery'] is List &&
          (messageData['gallery'] as List).isNotEmpty) {
        attachments = List.from(messageData['gallery']);
      } else if (messageData['attachment'] != null) {
        attachments = [messageData['attachment']];
      }
    } else if (messageData is List) {
      attachments = List.from(messageData);
    }

    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: attachments.map((att) {
          final mediaType = detectMediaType(att);
          switch (mediaType) {
            case ChatMediaType.image:
              return _ImageAttachmentTile(attachment: att, allImages: attachments);
            case ChatMediaType.video:
              return _VideoAttachmentTile(attachment: att);
            case ChatMediaType.document:
            case ChatMediaType.other:
              return _DocumentAttachmentTile(attachment: att);
          }
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image Attachment Tile
// ---------------------------------------------------------------------------
class _ImageAttachmentTile extends StatelessWidget {
  final dynamic attachment;
  final List<dynamic> allImages;

  const _ImageAttachmentTile({
    Key? key,
    required this.attachment,
    required this.allImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = HelperFunctions().getImage(attachment);
    if (imageUrl.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GestureDetector(
          onTap: () {
            Get.to(
              () => const AttachmentPreviewScreen(),
              arguments: {
                "images": allImages.isNotEmpty ? allImages : [attachment]
              },
            );
          },
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, progress) => Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.black12,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.progress,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.grey.withOpacity(0.2),
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey, size: 36),
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.zoom_in_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fullscreen Image Preview
// ---------------------------------------------------------------------------
class AttachmentPreviewScreen extends StatelessWidget {
  const AttachmentPreviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final images = (Get.arguments?['images'] as List?) ?? [];
    final controller = PageController();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: controller,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imageUrl = HelperFunctions().getImage(images[index]);
          return InteractiveViewer(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Video Attachment Tile
// ---------------------------------------------------------------------------
class _VideoAttachmentTile extends StatefulWidget {
  final dynamic attachment;

  const _VideoAttachmentTile({Key? key, required this.attachment})
      : super(key: key);

  @override
  State<_VideoAttachmentTile> createState() => _VideoAttachmentTileState();
}

class _VideoAttachmentTileState extends State<_VideoAttachmentTile> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _checkIfDownloaded();
  }

  String get _fileName =>
      ChatAttachmentWidget.getAttachmentName(widget.attachment);
  String get _fileUrl =>
      ChatAttachmentWidget.resolveAttachmentUrl(widget.attachment);

  Future<String> _getLocalFilePath() async {
    final tempDir = await getTemporaryDirectory();
    final localFolder = Directory('${tempDir.path}/attachments');
    if (!localFolder.existsSync()) {
      localFolder.createSync(recursive: true);
    }
    final safeName = _fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');
    return '${localFolder.path}/$safeName';
  }

  Future<void> _checkIfDownloaded() async {
    try {
      final path = await _getLocalFilePath();
      if (File(path).existsSync()) {
        if (mounted) setState(() => _isDownloaded = true);
      }
    } catch (_) {}
  }

  Future<void> _handleTap() async {
    if (_fileUrl.isEmpty) {
      Fluttertoast.showToast(msg: "Video URL not found");
      return;
    }

    try {
      final localPath = await _getLocalFilePath();
      final localFile = File(localPath);

      if (await localFile.exists()) {
        final result = await OpenFilex.open(localPath);
        if (result.type != ResultType.done) {
          Fluttertoast.showToast(msg: "Could not open video: ${result.message}");
        }
        return;
      }

      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
      });

      final dio = Dio();
      await dio.download(
        _fileUrl,
        localPath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isDownloaded = true;
        });
      }

      final result = await OpenFilex.open(localPath);
      if (result.type != ResultType.done) {
        Fluttertoast.showToast(msg: "Could not open video: ${result.message}");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
      Fluttertoast.showToast(msg: "Failed to download video: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: GestureDetector(
        onTap: _isDownloading ? null : _handleTap,
        child: Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Center Play button or Download Progress
              Center(
                child: _isDownloading
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            value: _downloadProgress > 0 ? _downloadProgress : null,
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(_downloadProgress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isDownloaded
                              ? Icons.play_arrow_rounded
                              : Icons.download_rounded,
                          color: primaryColor,
                          size: 34,
                        ),
                      ),
              ),

              // Bottom Info Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.videocam_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isDownloaded ? 'PLAY' : 'TAP TO LOAD',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Document / PDF Attachment Tile
// ---------------------------------------------------------------------------
class _DocumentAttachmentTile extends StatefulWidget {
  final dynamic attachment;

  const _DocumentAttachmentTile({Key? key, required this.attachment})
      : super(key: key);

  @override
  State<_DocumentAttachmentTile> createState() =>
      _DocumentAttachmentTileState();
}

class _DocumentAttachmentTileState extends State<_DocumentAttachmentTile> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _checkIfDownloaded();
  }

  String get _fileName =>
      ChatAttachmentWidget.getAttachmentName(widget.attachment);
  String get _fileUrl =>
      ChatAttachmentWidget.resolveAttachmentUrl(widget.attachment);
  bool get _isPdf => _fileName.toLowerCase().endsWith('.pdf');

  Future<String> _getLocalFilePath() async {
    final tempDir = await getTemporaryDirectory();
    final localFolder = Directory('${tempDir.path}/attachments');
    if (!localFolder.existsSync()) {
      localFolder.createSync(recursive: true);
    }
    final safeName = _fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');
    return '${localFolder.path}/$safeName';
  }

  Future<void> _checkIfDownloaded() async {
    try {
      final path = await _getLocalFilePath();
      if (File(path).existsSync()) {
        if (mounted) setState(() => _isDownloaded = true);
      }
    } catch (_) {}
  }

  Future<void> _handleTap() async {
    if (_fileUrl.isEmpty) {
      Fluttertoast.showToast(msg: "Document URL not found");
      return;
    }

    try {
      final localPath = await _getLocalFilePath();
      final localFile = File(localPath);

      if (await localFile.exists()) {
        final result = await OpenFilex.open(localPath);
        if (result.type != ResultType.done) {
          Fluttertoast.showToast(msg: "Could not open document: ${result.message}");
        }
        return;
      }

      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
      });

      final dio = Dio();
      await dio.download(
        _fileUrl,
        localPath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isDownloaded = true;
        });
      }

      final result = await OpenFilex.open(localPath);
      if (result.type != ResultType.done) {
        Fluttertoast.showToast(msg: "Could not open document: ${result.message}");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
      Fluttertoast.showToast(msg: "Failed to download document: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: _isDownloading ? null : _handleTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Document Icon Badge
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: _isPdf
                      ? const Color(0xFFFFEBEE)
                      : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: _isPdf
                      ? const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Color(0xFFE53935),
                          size: 26,
                        )
                      : const Icon(
                          Icons.description_rounded,
                          color: Color(0xFF1E88E5),
                          size: 26,
                        ),
                ),
              ),
              const SizedBox(width: 10),

              // File Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _isPdf ? 'PDF Document' : 'Document',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Action / Progress Icon
              if (_isDownloading)
                SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    value: _downloadProgress > 0 ? _downloadProgress : null,
                    strokeWidth: 2.5,
                  ),
                )
              else
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: _isDownloaded
                        ? Colors.green.withOpacity(0.12)
                        : primaryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isDownloaded
                        ? Icons.open_in_new_rounded
                        : Icons.arrow_downward_rounded,
                    size: 18,
                    color: _isDownloaded ? Colors.green : primaryColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
