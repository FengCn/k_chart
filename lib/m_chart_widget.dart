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
  double mScaleX = 1.0, mScrollX = 0.0, mSelectX = 0.0;

  bool isLongPress = false;

  @override
  Widget build(BuildContext context) {
    if (widget.datas == null || widget.datas.isEmpty) {
      mScrollX = mSelectX = 0.0;
      mScaleX = 1.0;
    }
    return GestureDetector(
      onLongPressStart: (details) {
        isLongPress = true;
        if (mSelectX != details.globalPosition.dx) {
          mSelectX = details.globalPosition.dx;
          notifyChanged();
        }
      },
      onLongPressMoveUpdate: (details) {
        if (mSelectX != details.globalPosition.dx) {
          mSelectX = details.globalPosition.dx;
          notifyChanged();
        }
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
              widget.datas,
              widget.leftDayClose,
              mSelectX,
              isLongPress: isLongPress
            ),
          )
        ],
      ),
    );
  }

  void notifyChanged() => setState(() {});
}
