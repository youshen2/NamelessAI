import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

class HrBuilder extends MarkdownElementBuilder {
  final BuildContext context;
  HrBuilder({required this.context});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(
        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        thickness: 1.5,
        indent: 20,
        endIndent: 20,
      ),
    );
  }
}

class MathBuilder extends MarkdownElementBuilder {
  final BuildContext context;
  final double fontSize;

  MathBuilder({required this.context, required this.fontSize});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = element.textContent;
    final isDisplayMode = element.tag == 'math_display';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDisplayMode ? 8.0 : 2.0),
      child: Math.tex(
        text,
        mathStyle: isDisplayMode ? MathStyle.display : MathStyle.text,
        textStyle: preferredStyle?.copyWith(
          fontSize: fontSize,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onErrorFallback: (err) => SelectableText(
          isDisplayMode ? '\$\$${text}\$\$' : '\$${text}\$',
          style: preferredStyle?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}

class MathInlineSyntax extends md.InlineSyntax {
  MathInlineSyntax() : super(r'\$((?:\\.|[^$])+)\$');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final md.Element el = md.Element.text('math_inline', match[1]!);
    parser.addNode(el);
    return true;
  }
}

class MathDisplaySyntax extends md.InlineSyntax {
  MathDisplaySyntax() : super(r'\$\$((?:\\.|[^$])+)\$\$');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final md.Element el = md.Element.text('math_display', match[1]!);
    parser.addNode(el);
    return true;
  }
}
