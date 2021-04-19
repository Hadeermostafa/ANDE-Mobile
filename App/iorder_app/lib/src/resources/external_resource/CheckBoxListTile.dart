import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomizedCheckboxListTile extends StatelessWidget {
  const CustomizedCheckboxListTile({
    Key key,
    @required this.value,
    @required this.onChanged,
    this.activeColor,
    this.title,
    this.subtitle,
    this.isThreeLine = false,
    this.dense,
    this.secondary,
    this.selected = false,
    this.controlAffinity = ListTileControlAffinity.platform,
  })  : assert(value != null),
        assert(isThreeLine != null),
        assert(!isThreeLine || subtitle != null),
        assert(selected != null),
        assert(controlAffinity != null),
        super(key: key);

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Widget title;
  final Widget subtitle;
  final Widget secondary;
  final bool isThreeLine;
  final bool dense;
  final bool selected;

  final ListTileControlAffinity controlAffinity;

  @override
  Widget build(BuildContext context) {
    final Widget control = SizedBox(
      width: 30,
//      height: 50,
      child: Checkbox( key: key,
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    Widget leading, trailing;
    switch (controlAffinity) {
      case ListTileControlAffinity.leading:
        leading = control;
        trailing = secondary;
        break;
      case ListTileControlAffinity.trailing:
      case ListTileControlAffinity.platform:
        leading = secondary;
        trailing = control;
        break;
    }
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: GestureDetector(
          onTap: onChanged != null
              ? () {
                  onChanged(!value);
                }
              : null,
          child: Row(
            children: <Widget>[
              trailing,
              Expanded(child: title),
            ],
          ),
        ),
      ),
//      child: ListTileTheme.merge(
//        selectedColor: activeColor ?? Theme.of(context).accentColor,
//
//        child: ListTile(
//          leading: trailing,
//          title: title,
//          subtitle: subtitle,
//          trailing: leading,
//          isThreeLine: isThreeLine,
//          dense: dense,
//          enabled: onChanged != null,
//          onTap: onChanged != null
//              ? () {
//                  onChanged(!value);
//                }
//              : null,
//          selected: selected,
//        ),
//      ),
    );
  }
}
