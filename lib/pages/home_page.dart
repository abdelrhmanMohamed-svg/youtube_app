import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_app/constants.dart';
import 'package:youtube_app/pages/video_page.dart';
import 'package:youtube_app/widgets/appBarWidget.dart';
import 'package:youtube_app/widgets/custom_text.dart';
import 'package:youtube_app/widgets/video_item.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  List items = [];
  bool isClear = false;
  bool isLoading = false;
  @override
  void initState() {
    searchVideo('flutter');
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  //serach video function
  Future<void> searchVideo(String txt) async {
    setState(() {
      isLoading = true;
    });
    final uri =
        '${AppConstants.baserUrl}/v2/search/videos?keyword=${txt}%20Astley&uploadDate=all&duration=all&sortBy=relevance';
    final url = Uri.parse(uri);
    final response = await http.get(url, headers: AppConstants.headers);
    final json = jsonDecode(response.body) as Map;
    final result = json['items'] as List;
    setState(() {
      items = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CupertinoActivityIndicator()
        : GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus;
              setState(() {
                isClear = false;
              });
            },
            child: Scaffold(
              appBar: AppBar(
                  title: Appbarwidget(
                searchController: searchController,
                searchFocusNode: searchFocusNode,
                onTap: () {
                  setState(() {
                    isClear = true;
                  });
                },
                onSubmitted: (txt) {
                  searchVideo(txt);
                },
                suffix: isClear
                    ? GestureDetector(
                        onTap: () {
                          searchController.clear();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 7.0),
                          child: Icon(Icons.cancel_rounded,
                              color: Colors.blue, size: 18),
                        ),
                      )
                    : SizedBox.shrink(),
              )),
              body: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final videoId = item['id'];
                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VideoPage(videoId: videoId,)));
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: VideoItem(
                        videoTitle: item['title'],
                        channelName: item['channel']['name'],
                        videoViews: item['viewCountText'],
                        videoDate: item['publishedTimeText'],
                        videoThumbnailUrl: item['thumbnails'][0]['url'],
                        videoDuration: item['lengthText'],
                        channelAvatarUrl: item['channel']['avatar'][0]['url'],
                      ),
                    );
                  }),
            ),
          );
  }
}
