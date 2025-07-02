import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:youtube_app/widgets/custom_text.dart';

class VideoItem extends StatelessWidget {
  const VideoItem({super.key, required this.videoTitle, required this.channelName, required this.videoDuration, required this.videoViews, required this.videoDate, required this.videoThumbnailUrl, required this.channelAvatarUrl});
  final String videoTitle, channelName, videoDuration, videoViews, videoDate;
  final String videoThumbnailUrl;
  final String channelAvatarUrl;
  @override
  Widget build(BuildContext context) {

    final  screenSize = MediaQuery.of(context).size;
    return Column(
      children: [
        Stack(
          children: [
            Image.network(videoThumbnailUrl,width: double.infinity,),
            Positioned(
                bottom: 5,
                right: 11,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  color: Colors.black54,
                  child: CustomText(
                    txt: "${videoDuration}",
                    fontWeight: FontWeight.bold,
                    fontsize: 11,
                  ),
                ))
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(channelAvatarUrl),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                 SizedBox(
                  width: screenSize.width * 0.8,
                   child: AutoSizeText(
                    videoTitle,
                     minFontSize: 14,maxFontSize: double.infinity,
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                     style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                     ),
                 ),
                  SizedBox(
                  width: screenSize.width * 0.8,
                   child: AutoSizeText(
                     "${channelName}   ${videoViews}     ${videoDate}",
                     minFontSize: 11,maxFontSize: double.infinity,
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                     style: TextStyle(color: Colors.white54,fontWeight: FontWeight.w500),
                     ),
                 ),
                         
                
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
