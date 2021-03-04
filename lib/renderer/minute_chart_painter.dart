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

  Rect mMainRect, mSecondaryRect;

  MinuteChartPainter(this.mDatas, this.leftDayClose) {
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
    double absv = max((mMainMaxValue - leftDayClose).abs(), (mMainMinValue - leftDayClose).abs());
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
    mPointWidth = mDrawWidth / 240;
    initRect(size);
    drawMainGrid(canvas);
    drawSecondaryGrid(canvas);

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
      canvas.drawLine(Offset(0, rowSpace * i),
          Offset(mMainRect.width, rowSpace * i), gridPaint);
    }
    double columnSpace = mMainRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      canvas.drawLine(Offset(columnSpace * i, 0),
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

  void initRect(Size size) {
    double secondaryHeight = size.height * 0.2;

    double mainHeight = size.height;
    mainHeight -= secondaryHeight;
    mMainRect = Rect.fromLTRB(0, 0, mWidth, mainHeight);
    mSecondaryRect = Rect.fromLTRB(
        0, mMainRect.bottom, mWidth, mMainRect.bottom + secondaryHeight);
  }
}
