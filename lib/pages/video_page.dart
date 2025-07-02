import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_app/constants.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_app/widgets/custom_text.dart';
import 'package:youtube_app/widgets/video_item.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key, required this.videoId});

  final String videoId;

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController? _controller;
  bool isLoading = false;
  bool isComment = false;
  List videosList = [];
  List relatedVideos = [];
  List commentsList = [];
  Map<String, dynamic>? videoDetails;
  bool isDesc = false;

  Future<void> getVideo() async {
    final url = Uri.parse(
        '${AppConstants.baserUrl}/v2/video/details?videoId=${widget.videoId}');
    final response = await http.get(url, headers: AppConstants.headers);
    final json = jsonDecode(response.body) as Map<String, dynamic>?;
    if (json == null ||
        json['videos'] == null ||
        json['videos']['items'] == null) {
      throw Exception('Invalid API response ');
    }

    final result = json!['videos']['items'] as List;
    if (result.isEmpty || result[0]['url'] == null) {
      throw Exception('Invalid URL');
    }
    final videoUrl = result[0]['url'] as String;

    setState(() {
      videoDetails = json;
      videosList = result;
      isLoading = true;
    });
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
    )..initialize().then((v) {
        setState(() {
          _controller!.play();
        });
      });

    setState(() {
      isLoading = false;
    });
  }

// related videos
  Future<void> getRelatedVideos() async {
    final url = Uri.parse(
        '${AppConstants.baserUrl}/v2/video/related?videoId=${widget.videoId}');
    final response = await http.get(url, headers: AppConstants.headers);
    final json = jsonDecode(response.body) as Map;
    final result = json['items'] as List;
    setState(() {
      relatedVideos = result;
    });
  }

  Future<void> getCommentVideos() async {
    final url = Uri.parse(
        '${AppConstants.baserUrl}/v2/video/comments?videoId=d${widget.videoId}');
    final response = await http.get(url, headers: AppConstants.headers);
    final json = jsonDecode(response.body) as Map;
    final result = json['items'] as List;
    setState(() {
      commentsList = result;
    });
  }

  void initState() {
    getVideo();
    getRelatedVideos();
    getCommentVideos();
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  void toggleVideo() {
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CupertinoActivityIndicator())
          : (videoDetails == null || videosList.isEmpty)
              ? Center(child: CupertinoActivityIndicator())
              : Column(
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: toggleVideo,
                          child: Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: _controller!.value.isInitialized
                                    ? VideoPlayer(_controller!)
                                    : Shimmer.fromColors(
                                        child: Container(
                                          color: Colors.black,
                                        ),
                                        baseColor: Colors.black,
                                        highlightColor: Colors.black12),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          // video title and description
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: size.height * 0.02,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isDesc = !isDesc;
                                  });
                                },
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: size.width * 0.8,
                                        child: AutoSizeText(
                                            maxLines: 2,
                                            minFontSize: 16,
                                            maxFontSize: double.infinity,
                                            videoDetails!['title'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                      ),
                                      Spacer(),
                                      Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: size.height * 0.01),
                              SizedBox(
                                width: size.width / 0.7,
                                child: AutoSizeText(
                                    maxLines: isDesc ? 17 : 2,
                                    minFontSize: 12,
                                    maxFontSize: double.infinity,
                                    videoDetails!['description'],
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        const TextStyle(color: Colors.white70)),
                              ),
                              SizedBox(
                                height: size.height * 0.02,
                              ),
                              isDesc
                                  ? Center(
                                      child: AutoSizeText(
                                        "${videoDetails!['viewCount']} views    ${videoDetails!['publishedTimeText']} ",
                                        maxLines: 1,
                                        minFontSize: 8,
                                        maxFontSize: double.infinity,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                              SizedBox(height: size.height * 0.02),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(
                                        '${videoDetails!['channel']['avatar'][0]['url']}'),
                                  ),
                                  SizedBox(
                                    width: size.width * 0.02,
                                  ),
                                  AutoSizeText(
                                    '${videoDetails!['channel']['name']}',
                                    minFontSize: 14,
                                    maxFontSize: double.infinity,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: size.width * 0.02,
                                  ),
                                  AutoSizeText(
                                    "${videoDetails!['channel']['subscriberCountText']} ",
                                    minFontSize: 11,
                                    maxFontSize: double.infinity,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.white54,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: CustomText(
                                      txt: 'Subscribe',
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: size.height * 0.04,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isComment = !isComment;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CustomText(
                                    fontWeight: FontWeight.bold,
                                    txt:
                                        '${videoDetails!['commentCountText']} comments'),
                                Spacer(),
                                Icon(Icons.arrow_drop_down),
                                if (isComment)
                                  SizedBox(
                                    width: size.width * 8,
                                    child: Column(
                                      children: List.generate(
                                          commentsList.length, (index) {
                                        final comment = commentsList[index];
                                        return ListTile(
                                          leading: CircleAvatar(
                                            radius: 20,
                                            backgroundImage: NetworkImage(
                                                '${comment['channel']['avatar'][0]['url']}'),
                                          ),
                                          title: AutoSizeText(
                                            '${comment['channel']['name']}',
                                            minFontSize: 14,
                                            maxFontSize: double.infinity,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: AutoSizeText(
                                            '${comment['contentText']}',
                                            minFontSize: 11,
                                            maxFontSize: double.infinity,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.white54,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        );
                                      }),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                      ],
                    ),
                    Expanded(
                      //list of related videos
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: relatedVideos.length,
                        itemBuilder: (context, index) {
                          final item = relatedVideos[index];
                          return VideoItem(
                              videoTitle: item['title'],
                              channelName: item['channel']['name'],
                              videoDuration: item['lengthText'],
                              videoViews: item['viewCountText'],
                              videoDate: item['publishedTimeText'],
                              videoThumbnailUrl: item['thumbnails'][0]['url'],
                              channelAvatarUrl: item['channel']['avatar'][0]
                                  ['url']);
                        },
                      ),
                    )
                  ],
                ),
    );
  }
}
