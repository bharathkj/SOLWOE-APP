import 'package:flutter/material.dart';
import 'package:solwoe/screens/diary_screen.dart';
import 'package:solwoe/screens/show_videos.dart';

class SearchActivities extends SearchDelegate {
  final List<String> activities;

  SearchActivities(this.activities);

  @override
  String get searchFieldLabel => 'Search self care activities';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Perform the search and display results
    List<String> results = activities
        .where(
            (activity) => activity.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index]),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions as user types
    List<String> suggestions = activities
        .where((activity) =>
            activity.toLowerCase().startsWith(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            if (query != 'Diary') {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ShowVideosScreen(title: query)));
            } else {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => DiaryScreen()));
            }
          },
        );
      },
    );
  }
}
