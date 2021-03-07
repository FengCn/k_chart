import 'package:flutter/material.dart';
import 'package:k_chart/renderer/minute_chart_painter.dart';

import 'entity/k_line_entity.dart';

enum SubState { Vol }

class MChartWidget extends StatefulWidget {
  final List<KLineEntity> datas;
  final double leftDayClose;
  final SubState subState;

  const MChartWidget(this.datas, this.leftDayClose, {this.subState});

  @override
  _MChartWidgetState createState() => _MChartWidgetState();
}

class _MChartWidgetState extends State<MChartWidget> {
  double mScaleX = 1.0, mScrollX = 0.0;
  Offset mSelectPosition = Offset.zero;

  bool isLongPress = false;

  @override
  Widget build(BuildContext context) {
    if (widget.datas == null || widget.datas.isEmpty) {
      mScrollX = 0.0;
      mScaleX = 1.0;
    }
    return GestureDetector(
      onLongPressStart: (details) {
        isLongPress = true;
        /*** convert globalPosition to local position
        print(details.globalPosition.toString());
        RenderBox getBox = context.findRenderObject();
        var local = getBox.globalToLocal(details.globalPosition);
        print(local.dx.toString() + "|" + local.dy.toString()); ***/
        mSelectPosition = details.localPosition;
        notifyChanged();
      },
      onLongPressMoveUpdate: (details) {
        mSelectPosition = details.localPosition;
        notifyChanged();
      },
      onLongPressEnd: (details) {
        isLongPress = false;
        notifyChanged();
      },
      child: Stack(
        children: [
          CustomPaint(
            size: Size(double.infinity, double.infinity),
            painter: MinuteChartPainter(
                widget.datas, widget.leftDayClose, mSelectPosition,
                isLongPress: isLongPress),
          )
        ],
      ),
    );
  }

  void notifyChanged() => setState(() {});
}
