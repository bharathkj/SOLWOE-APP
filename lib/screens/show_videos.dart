import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:solwoe/colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ShowVideosScreen extends StatefulWidget {
  final String title;
  const ShowVideosScreen({super.key, required this.title});

  @override
  State<ShowVideosScreen> createState() => _ShowVideosScreenState();
}

class _ShowVideosScreenState extends State<ShowVideosScreen> {
  List<String>? _videoLinks;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideoLinks();
  }

  Future<void> _loadVideoLinks() async {
    final String videoLinksString =
        await rootBundle.loadString('assets/${widget.title}.txt');

    setState(() {
      _videoLinks= videoLinksString.split('\n');
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors.secondaryBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 3,
        backgroundColor: ConstantColors.secondaryBackgroundColor,
        title: Text(
          widget.title,
          style: GoogleFonts.sourceSerifPro(
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _videoLinks!.length,
                itemBuilder: (BuildContext context, int index) {
                  final videoLinks = _videoLinks![index];
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      top: 8,
                      bottom: 8,
                    ),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.grey,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: YoutubePlayer(
                            controller: YoutubePlayerController(
                              initialVideoId: YoutubePlayer.convertUrlToId(
                                videoLinks,
                              )!,
                              flags: const YoutubePlayerFlags(
                                useHybridComposition: false,
                                autoPlay: false,
                                mute: false,
                              ),
                            ),
                            showVideoProgressIndicator: true,
                            progressIndicatorColor: ConstantColors.primaryBackgroundColor,
                            bottomActions: [
                              CurrentPosition(),
                              ProgressBar(
                                isExpanded: true,
                                colors: const ProgressBarColors(
                                  playedColor: ConstantColors.primaryBackgroundColor,
                                  handleColor: ConstantColors.primaryBackgroundColor,
                                ),
                              ),
                              const PlaybackSpeedButton(),
                            ],
                            onReady: () {
                              log('player ready');
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
