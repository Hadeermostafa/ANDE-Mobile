// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RadioButtonListTile<T> extends StatelessWidget {
  const RadioButtonListTile({
    Key key,
    @required this.value,
    @required this.groupValue,
    @required this.onChanged,
    this.activeColor,
    this.title,
    this.subtitle,
    this.isThreeLine = false,
    this.dense,
    this.secondary,
    this.selected = false,
    this.controlAffinity = ListTileControlAffinity.platform,
  })  : assert(isThreeLine != null),
        assert(!isThreeLine || subtitle != null),
        assert(selected != null),
        assert(controlAffinity != null),
        super(key: key);
  final T value;

  final T groupValue;

  final ValueChanged<T> onChanged;

  final Color activeColor;
  final Widget title;

  final Widget subtitle;

  final Widget secondary;

  final bool isThreeLine;

  final bool dense;

  final bool selected;

  final ListTileControlAffinity controlAffinity;

  bool get checked => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final Widget control = SizedBox(
      width: 30,
      height: 20,
      child: Radio<T>(key: Key('cash'),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: activeColor,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
    Widget leading, trailing;
    switch (controlAffinity) {
      case ListTileControlAffinity.leading:
      case ListTileControlAffinity.platform:
        leading = control;
        trailing = secondary;
        break;
      case ListTileControlAffinity.trailing:
        leading = secondary;
        trailing = control;
        break;
    }
    return MergeSemantics(
      child: ListTileTheme.merge(
        selectedColor: activeColor ?? Theme.of(context).accentColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector( key: Key('select'),
            onTap: onChanged != null && !checked
                ? () {
                    onChanged(value);
                  }
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                leading,
                title,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
