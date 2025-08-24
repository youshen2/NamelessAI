import 'package:flutter/material.dart';

class JsonViewer extends StatelessWidget {
  final Map<String, dynamic> json;

  const JsonViewer({super.key, required this.json});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: json.entries.map((entry) {
          return _buildNode(context, entry.key, entry.value, 0);
        }).toList(),
      ),
    );
  }

  Widget _buildNode(
      BuildContext context, String key, dynamic value, int depth) {
    final indent = 16.0 * depth;

    if (value is Map<String, dynamic>) {
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(left: indent),
          title: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
          children: value.entries.map((entry) {
            return _buildNode(context, entry.key, entry.value, depth + 1);
          }).toList(),
        ),
      );
    } else if (value is List) {
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(left: indent),
          title: Text('$key [${value.length}]',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          children: value.asMap().entries.map((entry) {
            return _buildNode(
                context, '[${entry.key}]', entry.value, depth + 1);
          }).toList(),
        ),
      );
    } else {
      return ListTile(
        contentPadding: EdgeInsets.only(left: indent + 16.0, right: 16.0),
        title: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: SelectableText(value.toString()),
        dense: true,
      );
    }
  }
}
