import 'package:flutter/material.dart';

class SearchableDropdown extends StatefulWidget {
  final List<String> options;
  final String initialValue;
  final Function(String) onChanged;

  const SearchableDropdown({
    Key? key,
    required this.options,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _SearchableDropdownState createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  late String _selectedValue;
  late List<String> _filteredOptions;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _filteredOptions = widget.options;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration:const  InputDecoration(
            labelText: 'Search',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _filterOptions(value);
          },
        ),
        DropdownButton(
          value: _selectedValue,
          items: _filteredOptions.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedValue = value as String;
              widget.onChanged(_selectedValue);
            });
          },
        ),
      ],
    );
  }

  void _filterOptions(String searchQuery) {
    setState(() {
      _filteredOptions = widget.options
          .where((option) => option
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    });
  }
}