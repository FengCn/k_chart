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
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(double.infinity, double.infinity),
          painter: MinuteChartPainter(
            widget.datas,
            widget.leftDayClose,
          ),
        )
      ],
    );
  }
}
