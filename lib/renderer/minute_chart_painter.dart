import 'dart:math';

import 'package:flutter/material.dart';
import 'package:k_chart/entity/k_line_entity.dart';

import '../chart_style.dart';

class MinuteChartPainter extends CustomPainter {
  List<KLineEntity> mDatas;
  double leftDayClose;
  double mWidth = 0.0, mDrawHeight = 0.0, mDrawWidth = 0.0, mPointWidth;
  Path mClosePath;
  Paint mLinePaint, mGreenLinePaint, gridPaint, gridPaint2;

  double mMainMaxValue = double.minPositive, mMainMinValue = double.maxFinite;
  double mVolMaxValue = double.minPositive, mVolMinValue = double.maxFinite;

  double scaleY;
  double scaleX = 1.0, scrollX = 0.0;
  bool isLongPress = false;
  Offset selectPosition = Offset.zero;

  Rect mTopRect, mMainRect, mLableXRect, mSecondaryRect;

  int fixedLength = 2;

  MinuteChartPainter(this.mDatas, this.leftDayClose, this.selectPosition,
      {this.isLongPress}) {
    mClosePath ??= Path();
    mLinePaint ??= Paint()
      ..isAntiAlias = true
      ..color = ChartColors.depthSellColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    mGreenLinePaint ??= Paint()
      ..isAntiAlias = true
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    gridPaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..strokeWidth = 0.5
      ..color = Color(0xff4c5c74);
    gridPaint2 = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..strokeWidth = 0.5
      ..color = Colors.lightBlue;
    if (mDatas != null && mDatas.isNotEmpty) {
      for (var item in mDatas) {
        mMainMaxValue = max(mMainMaxValue, item.close);
        mMainMinValue = min(mMainMinValue, item.close);
        mVolMaxValue = max(mVolMaxValue, item.vol);
        mVolMinValue = min(mVolMinValue, item.vol);
      }
    }
    double absv = max((mMainMaxValue - leftDayClose).abs(),
        (mMainMinValue - leftDayClose).abs());
    mMainMaxValue = leftDayClose + absv;
    mMainMinValue = leftDayClose - absv;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (mDatas == null || mDatas.isEmpty) {
      return;
    }
    mWidth = size.width;
    mDrawWidth = mWidth;
    mPointWidth = mDrawWidth / 60 / 4;
    initRect(size);

    scaleY = mMainRect.height / (mMainMaxValue - mMainMinValue);

    drawMainGrid(canvas);
    drawSecondaryGrid(canvas);
    drawLeftText(canvas);
    drawRightText(canvas);
    drawText(canvas);
    drawCrossLine(canvas, size);

    mClosePath.reset();
    for (int i = 0; i < mDatas.length; i++) {
      KLineEntity item = mDatas[i];
      if (i == 0) {
        mClosePath.moveTo(getX(i), getY(item.close));
      } else {
        mClosePath.lineTo(getX(i), getY(item.close));
      }
      canvas.drawLine(
          Offset(mPointWidth * i, mSecondaryRect.bottom),
          Offset(
              mPointWidth * i,
              mSecondaryRect.bottom -
                  mSecondaryRect.height * item.vol / mVolMaxValue),
          item.close > item.open ? mLinePaint : mGreenLinePaint);
    }
    //mClosePath.close();
    canvas.drawPath(mClosePath, mLinePaint);
  }

  double getX(int position) => position * mPointWidth + mPointWidth / 2;
  double getY(double volume) =>
      mMainRect.top +
      (mMainMaxValue - volume) *
          (mMainRect.height / (mMainMaxValue - mMainMinValue));

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void drawMainGrid(Canvas canvas) {
    // mMainRect Grids
    final int gridRows = 4, gridColumns = 4;
    double rowSpace = mMainRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      canvas.drawLine(Offset(0, rowSpace * i + mMainRect.top),
          Offset(mMainRect.width, rowSpace * i + mMainRect.top), gridPaint);
    }
    double columnSpace = mMainRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      canvas.drawLine(Offset(columnSpace * i, mMainRect.top),
          Offset(columnSpace * i, mMainRect.bottom), gridPaint);
    }
  }

  void drawSecondaryGrid(Canvas canvas) {
    // mSecondaryRect Grids
    final int gridRows = 2, gridColumns = 4;
    double rowSpace = mSecondaryRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      canvas.drawLine(
          Offset(0, mSecondaryRect.top + rowSpace * i),
          Offset(mSecondaryRect.width, mSecondaryRect.top + rowSpace * i),
          gridPaint2);
    }
    double columnSpace = mSecondaryRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      canvas.drawLine(Offset(columnSpace * i, mSecondaryRect.top),
          Offset(columnSpace * i, mSecondaryRect.bottom), gridPaint2);
    }
  }

  void drawLeftText(canvas) {
    var textStyle =
        TextStyle(fontSize: 10.0, color: ChartColors.defaultTextColor);
    final int gridRows = 4;
    double rowSpace = mMainRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      double value = (gridRows - i) * rowSpace / scaleY + mMainMinValue;

      TextSpan span = TextSpan(text: "${format(value)}", style: textStyle);
      TextPainter tp =
          TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      if (i == 0) {
        tp.paint(canvas, Offset(0, mMainRect.top + rowSpace * i));
      } else if (i == gridRows) {
        tp.paint(canvas, Offset(0, mMainRect.top + rowSpace * i - tp.height));
      } else {
        tp.paint(
            canvas, Offset(0, mMainRect.top + rowSpace * i - tp.height / 2));
      }
    }
  }

  void drawRightText(canvas) {
    var textStyle =
        TextStyle(fontSize: 10.0, color: ChartColors.defaultTextColor);
    final int gridRows = 4;
    double rowSpace = mMainRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      double value = (gridRows - i) * rowSpace / scaleY + mMainMinValue;
      value = (value - leftDayClose) / leftDayClose * 100;

      TextSpan span = TextSpan(text: "${format(value)}%", style: textStyle);
      TextPainter tp =
          TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      if (i == 0) {
        tp.paint(canvas,
            Offset(mMainRect.width - tp.width, mMainRect.top + rowSpace * i));
      } else if (i == gridRows) {
        tp.paint(
            canvas,
            Offset(mMainRect.width - tp.width,
                mMainRect.top + rowSpace * i - tp.height));
      } else {
        tp.paint(
            canvas,
            Offset(mMainRect.width - tp.width,
                mMainRect.top + rowSpace * i - tp.height / 2));
      }
    }
  }

  void drawText(canvas) {
    var selectedData;
    if (isLongPress) {
      var index = calculateSelectedX(selectPosition);
      selectedData = mDatas[index];
    }

    KLineEntity displayData = selectedData != null ? selectedData : mDatas.last;

    var span = TextSpan(children: [
      TextSpan(
          text:
              "最新: ${format(displayData.close)} ${format(displayData.close - leftDayClose)} ${format((displayData.close - leftDayClose) / leftDayClose * 100)}%"),
    ]);

    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(8.0, (mTopRect.height - tp.height) / 2));

    TextPainter tp930 = TextPainter(
        text: TextSpan(text: "9.30"), textDirection: TextDirection.ltr);
    tp930.layout();
    tp930.paint(canvas,
        Offset(0, mLableXRect.top + (mLableXRect.height - tp930.height) / 2));

    TextPainter tp11301300 = TextPainter(
        text: TextSpan(text: "11:30/13:00"), textDirection: TextDirection.ltr);
    tp11301300.layout();
    tp11301300.paint(
        canvas,
        Offset((mLableXRect.width - tp11301300.width) / 2,
            mLableXRect.top + (mLableXRect.height - tp930.height) / 2));

    TextPainter tp1500 = TextPainter(
        text: TextSpan(text: "15.00"), textDirection: TextDirection.ltr);
    tp1500.layout();
    tp1500.paint(
        canvas,
        Offset(mLableXRect.width - tp1500.width,
            mLableXRect.top + (mLableXRect.height - tp930.height) / 2));
  }

  int calculateSelectedX(Offset posi) {
    return Random().nextInt(mDatas.length - 1);
  }

  ///画交叉线
  void drawCrossLine(Canvas canvas, Size size) {
    if (isLongPress) {
      Paint paintX = Paint()
        ..color = Colors.white
        ..strokeWidth = ChartStyle.hCrossWidth
        ..isAntiAlias = true;

      Paint paintY = Paint()
        ..color = Colors.white12
        ..strokeWidth = ChartStyle.vCrossWidth
        ..isAntiAlias = true;

      //画横线
      canvas.drawLine(Offset(0, selectPosition.dy), Offset(mWidth, selectPosition.dy), paintX);

      //画竖线
      canvas.drawLine(
          Offset(selectPosition.dx, 0), Offset(selectPosition.dx, size.height), paintY);

      canvas.drawCircle(selectPosition, 2.0, paintX);
    }
  }

  void initRect(Size size) {
    double topHeight = 30;
    double labelXHeight = 30;
    double secondaryHeight = size.height * 0.2;

    double mainHeight = size.height;
    mainHeight -= secondaryHeight;
    mainHeight -= topHeight;
    mainHeight -= labelXHeight;
    mTopRect = Rect.fromLTRB(0, 0, mWidth, topHeight);
    mMainRect =
        Rect.fromLTRB(0, mTopRect.bottom, mWidth, mTopRect.bottom + mainHeight);
    mLableXRect = Rect.fromLTRB(
        0, mMainRect.bottom, mWidth, mMainRect.bottom + labelXHeight);
    mSecondaryRect = Rect.fromLTRB(
        0, mLableXRect.bottom, mWidth, mLableXRect.bottom + secondaryHeight);
  }

  String format(double n) {
    if (n == null || n.isNaN) {
      return "0.00";
    } else {
      return n.toStringAsFixed(fixedLength);
    }
  }
}
