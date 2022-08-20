import 'package:youtube_explode_dart/youtube_explode_dart.dart';

var yt = YoutubeExplode();

void main(List<String> args) async {
  // var videoId = (await yt.search("ترنيمة ايوة الهي صالح")).first.id;
  // var streamManifest = await yt.videos.streamsClient.getManifest(videoId);
  // var streamInfo = streamManifest.audioOnly[0].url;
  // print(streamInfo);
  String t = ((await tSearch("ترنيمة ايوة الهي صالح"))[0]["id"]).toString();
  String turl = await tDownloadUrl(t);
  print(turl);
}

Future<List> tSearch(String traneema) async {
  List videos = (await yt.search(traneema))
      .map((v) => {
            'title': v.title,
            'id': v.id,
          })
      .toList();

  return videos;
}

Future<String> tDownloadUrl(videoId) async {
  var streamManifest = await yt.videos.streamsClient.getManifest(videoId);
  String downloadUrl = streamManifest.audioOnly[0].url.toString();

  return downloadUrl;
}
