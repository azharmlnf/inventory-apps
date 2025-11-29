import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inventory_app/features/home/providers/dashboard_providers.dart';

class StockChart extends StatefulWidget {
  final List<CategoryStock> categoryStocks;

  const StockChart({super.key, required this.categoryStocks});

  @override
  State<StatefulWidget> createState() => StockChartState();
}

class StockChartState extends State<StockChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 18),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: showingSections(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: widget.categoryStocks.map((data) {
                  return _buildIndicator(data.color, data.categoryName);
                }).toList(),
              ),
            ),
            const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(widget.categoryStocks.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final data = widget.categoryStocks[i];
      final percentage = (data.totalQuantity /
              widget.categoryStocks
                  .map((d) => d.totalQuantity)
                  .reduce((a, b) => a + b) *
              100)
          .toStringAsFixed(1);

      return PieChartSectionData(
        color: data.color,
        value: data.totalQuantity,
        title: '$percentage%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    });
  }

  Widget _buildIndicator(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
