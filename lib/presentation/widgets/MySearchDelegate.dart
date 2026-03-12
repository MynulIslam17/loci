import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';

class MySearchDelegate extends SearchDelegate {
  List<String> data = [
    "Apple",
    "Banana",
    "Mango",
    "Orange",
    "Pineapple",
    "Watermelon",
    "Strawberry",
    "Grapes",
  ];

  // Optional: apply app theme to search page
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme,
      scaffoldBackgroundColor: theme.colorScheme.surface,
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        border: InputBorder.none,
      ),
    );
  }

  //-----sets size of text in textFiled
  @override
  TextStyle? get searchFieldStyle =>
      AppTextStyle.textSm(weight: FontWeight.w500);

  //------ Right side button (clear text)
  @override
  List<Widget>? buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [

      if(query.isNotEmpty)
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: Icon(Icons.clear),
      ),

    ];
  }

  //------left side button (back)
  @override
  Widget? buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  //-------- Final result screen
  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return Center(child: Text("Your Search Result is :${query} "));
  }

  //------ Suggestions while typing
  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions

    List<String> suggestions = data.where((item) {
      return item.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.search),
          title: Text(suggestions[index]),
          onTap: () {
            //TODO:ONTap
            query = suggestions[index];
            showResults(context);
          },
        );
      },
    );
  }
}
