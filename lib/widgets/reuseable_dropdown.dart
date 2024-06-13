import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';
import 'package:tfnd_app/themes/color.dart';

class CustomSearchField extends StatefulWidget {
  final List<String> suggestions;
  final Icon icon;
  final TextEditingController controller;
  final String hint;
  final VoidCallback onSuggestionAdded;
  final FocusNode? focusNode; // Accept external focus node
  final Function(String)? onSubmitted; // Accept external onSubmitted callback

  const CustomSearchField({
    Key? key,
    required this.suggestions,
    required this.icon,
    required this.hint,
    required this.onSuggestionAdded,
    required this.controller,
    this.focusNode, // Make focusNode nullable
    this.onSubmitted, // Make onSubmitted callback nullable
  }) : super(key: key);

  @override
  _CustomSearchFieldState createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  late FocusNode _focus; // Declare a local focus node for internal use

  @override
  void initState() {
    super.initState();
    // Initialize the local focus node or use the provided one
    _focus = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    // Dispose the local focus node if it was created internally
    if (widget.focusNode == null) {
      _focus.dispose();
    }
    super.dispose();
  }

  Widget searchChild(String x) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
        child: Text(x, style: const TextStyle(fontSize: 18, color: Colors.black)),
      );

  @override
  Widget build(BuildContext context) {
    return SearchField<String>(
      suggestionDirection: SuggestionDirection.flex,
      onSearchTextChanged: (query) {
        final filter = widget.suggestions
            .where((element) => element.toLowerCase().contains(query.toLowerCase()))
            .toList();
        return filter.map((e) => SearchFieldListItem<String>(e, child: searchChild(e))).toList();
      },
      controller: widget.controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || !widget.suggestions.contains(value.trim())) {
          return 'Enter a valid industreis name';
        }
        return null;
      },
      onSubmit: (x) {
        if (widget.onSubmitted != null) {
          widget.onSubmitted!(x); // Call external onSubmitted callback if provided
        }
      },
      autofocus: false,
      key: const Key('searchfield'),
      hint: widget.hint,
      itemHeight: 50,
      onTapOutside: (x) {
        // _focus.unfocus(); // Uncomment if you want to unfocus on tap outside
      },
      scrollbarDecoration: ScrollbarDecoration(
        thickness: 6,
        radius: const Radius.circular(18),
        trackColor: Colors.grey,
        trackBorderColor: Colors.red,
        thumbColor: AppColor.btnColor,
      ),
      suggestionStyle: const TextStyle(fontSize: 18, color: Colors.white),
      searchStyle: const TextStyle(fontSize: 14, color: AppColor.hintColor, fontWeight: FontWeight.w400),
      suggestionItemDecoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      searchInputDecoration: InputDecoration(
        filled: true, // Add this line
        fillColor: Colors.white,
        hintStyle: const TextStyle(fontSize: 18, color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.white,
            style: BorderStyle.solid,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.white,
            style: BorderStyle.solid,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.red,
            style: BorderStyle.solid,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.grey,
            style: BorderStyle.solid,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.white,
            style: BorderStyle.solid,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        prefixIcon: IconButton(
          icon: widget.icon,
          onPressed: () {
            // Define the action you want to perform when the icon is pressed
            print("Icon pressed");
          },
        ),
      ),
      suggestionsDecoration: SuggestionDecoration(
        elevation: 8.0,
        selectionColor: Colors.grey.shade100,
        hoverColor: Colors.purple.shade100,
        gradient: const LinearGradient(
          colors: [Color(0xffffffffffff), Color.fromARGB(255, 255, 255, 255)],
          stops: [0.25, 0.75],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      suggestions: widget.suggestions
          .map((e) => SearchFieldListItem<String>(e, child: searchChild(e)))
          .toList(),
      focusNode: _focus, // Use the local focus node
      suggestionState: Suggestion.expand,
      onSuggestionTap: (SearchFieldListItem<String> x) {
        // Handle suggestion tap action here
      },
    );
  }
}
