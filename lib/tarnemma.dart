// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';
import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tarneemna/player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'widgets/snackbar.dart';

final yt = YoutubeExplode();

class Tarnemma {
  String title;
  String id;
  String downloadUrl = "";

  Rx<DownloadTaskStatus> downloadProcess = DownloadTaskStatus.undefined.obs;
  static String downloadPath = "";
  // static int lastToPlayIndex = 0;
  Tarnemma({
    required this.title,
    required this.id,
  }) {
    setDownloadUrl();
  }

  static Future<List<Tarnemma>> search(String traneema) async {
    if (await InternetConnectionChecker().hasConnection) {
      List<Tarnemma> videos = (await yt.search("ترنيمة " + traneema))
          .map((t) => Tarnemma(title: t.title, id: t.id.toString()))
          .toList();

      return videos;
    } else {
      showCustomSnackbar(
          "خطأ", "لا يوجد اتصال بالانترنت", Icons.interests_rounded);
      return [];
    }
  }

  static Future<String> getDownloadPath() async {
    if (Tarnemma.downloadPath.isEmpty) {
      if (Platform.isAndroid) {
        try {
          downloadPath = await AndroidPathProvider.downloadsPath;
        } catch (e) {
          final directory = await getExternalStorageDirectory();
          downloadPath = directory?.path as String;
        }
      }
      final savedDir = Directory(downloadPath);
      final hasExisted = savedDir.existsSync();
      if (!hasExisted) {
        await savedDir.create();
      }
      showCustomSnackbar("مكان التحميل هو", downloadPath, Icons.download);
    }

    return Tarnemma.downloadPath;
  }

  void setDownloadUrl() async {
    StreamManifest streamManifest =
        await yt.videos.streamsClient.getManifest(id);
    downloadUrl = streamManifest.audioOnly[0].url.toString();
  }

  Future download() async {
    if (downloadProcess.value == DownloadTaskStatus.undefined) {
      if (kDebugMode) print("Downloading $title");

      final status = await Permission.storage.request();

      if (status.isGranted) {
        if (downloadUrl.isNotEmpty) {
          id = (await FlutterDownloader.enqueue(
            url: downloadUrl,
            savedDir: await getDownloadPath(),
            fileName: "$title.mp3",
            saveInPublicStorage: true,
          ))!;
          // ignore: unused_local_variable
          Timer timer = Timer.periodic(1.seconds, (t) async {
            downloadProcess.value = (await FlutterDownloader.loadTasks())!
                .firstWhere((element) => element.taskId == id)
                .status;
            if (downloadProcess.value == DownloadTaskStatus.complete ||
                downloadProcess.value == DownloadTaskStatus.failed) t.cancel();
          });

          return id;
        } else {
          setDownloadUrl();
          download();
        }
      } else {
        showCustomSnackbar(
            "خطا!", "الرجاء الموافقة علي تصريح الولوج", Icons.error);
      }
    }
  }

  play() async => Player.playUrl(url: downloadUrl, title: title);
}
