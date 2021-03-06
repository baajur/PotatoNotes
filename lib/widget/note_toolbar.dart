/*
 * Karmka Text Editor
 * Copyright 2019 Adam Bahr.
 * https://github.com/TutOsirisOm/karmka_text_editor/
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * This project uses modified source code from https://github.com/namhyun-gu/flutter_rich_text_editor, copyright Namhyun Gu 2019, licensed under the Apache 2.0 license.
 */

/*
 * Modified by HrX to be used on PotatoNotes
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rich_text_editor/rich_text_editor.dart';

class NoteToolbar extends StatefulWidget {
  final SpannableTextEditingController controller;
  final List<Widget> rightActions;
  final Color toolbarActionToggleColor;
  final Color toolbarBackgroundColor;
  final Color toolbarActionColor;
  final bool stayFocused;

  NoteToolbar({
    Key key,
    this.controller,
    this.rightActions = const [],
    this.stayFocused = true,
    this.toolbarActionToggleColor,
    this.toolbarBackgroundColor,
    this.toolbarActionColor,
  }) : super(key: key);

  @override
  _NoteToolbarState createState() => _NoteToolbarState();
}

class _NoteToolbarState extends State<NoteToolbar> {
  final StreamController<TextEditingValue> _streamController =
      StreamController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      _streamController.sink.add(widget.controller.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TextEditingValue>(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        var currentStyle = SpannableStyle();
        var currentSelection;
        if (snapshot.hasData) {
          var value = snapshot.data;
          var selection = value.selection;
          if (selection != null && !selection.isCollapsed) {
            currentSelection = selection;
            currentStyle = widget.controller.getSelectionStyle();
          } else {
            currentStyle = widget.controller.composingStyle;
          }
        }
        return Material(
          color: Theme.of(context).cardColor,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 48,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  ..._buildActions(
                    currentStyle ?? SpannableStyle(),
                    currentSelection,
                  ),
                  Spacer(),
                  ...widget.rightActions,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  List<Widget> _buildActions(
      SpannableStyle spannableStyle, TextSelection selection) {
    final Map<int, IconData> styleMap = {
      styleBold: Icons.format_bold,
      styleItalic: Icons.format_italic,
      styleUnderline: Icons.format_underlined,
      styleLineThrough: Icons.format_strikethrough,
    };

    return styleMap.keys
        .map((style) => IconButton(
              icon: CircleAvatar(
                backgroundColor: spannableStyle.hasStyle(style)
                    ? Theme.of(context).accentColor.withOpacity(0.2)
                    : Colors.transparent,
                child: SizedBox.fromSize(
                  size: Size.square(36),
                  child: Icon(
                    styleMap[style],
                    color: spannableStyle.hasStyle(style)
                        ? Theme.of(context).accentColor
                        : Theme.of(context).iconTheme.color,
                    size: 24,
                  ),
                ),
              ),
              padding: EdgeInsets.all(0),
              onPressed: () => _toggleTextStyle(
                spannableStyle.copy(),
                style,
                selection: selection,
              ),
            ))
        .toList();
  }

  void _toggleTextStyle(
    SpannableStyle spannableStyle,
    int textStyle, {
    TextSelection selection,
  }) {
    bool hasSelection = selection != null;
    if (spannableStyle.hasStyle(textStyle)) {
      if (hasSelection) {
        widget.controller
            .setSelectionStyle((style) => style..clearStyle(textStyle));
      } else {
        widget.controller.composingStyle = spannableStyle
          ..clearStyle(textStyle);
      }
    } else {
      if (hasSelection) {
        widget.controller
            .setSelectionStyle((style) => style..setStyle(textStyle));
      } else {
        widget.controller.composingStyle = spannableStyle..setStyle(textStyle);
      }
    }
  }
}
