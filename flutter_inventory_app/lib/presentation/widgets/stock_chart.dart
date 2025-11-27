import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inventory_app/data/models/item.dart';

class StockChart extends StatelessWidget {
  final List<Item> items;

  const StockChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _calculateMaxY(),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (BarChartGroupData group) => Colors.blueGrey,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final item = items[group.x.toInt()];
                    return BarTooltipItem(
                      '${item.name}\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: item.quantity.toString(),
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final itemIndex = value.toInt();
                      if (itemIndex < 0 || itemIndex >= items.length) {
                        return SideTitleWidget(
                          meta: meta, // Pass the meta object directly
                          space: 0.0,
                          child: const SizedBox(),
                        );
                      }
                      final item = items[itemIndex];
                      return SideTitleWidget(
                        meta: meta, // Pass the meta object directly
                        space: 8.0,
                        child: Text(
                          item.name.length > 3 ? item.name.substring(0, 3) : item.name,
                          style: const TextStyle(
                            color: Color(0xff7589a2),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              barGroups: _generateBarGroups(),
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  double _calculateMaxY() {
    if (items.isEmpty) {
      return 0;
    }
    return items.map((item) => item.quantity).reduce((a, b) => a > b ? a : b).toDouble() * 1.2;
  }

  List<BarChartGroupData> _generateBarGroups() {
    return List.generate(items.length, (index) {
      final item = items[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.quantity.toDouble(),
            color: Colors.lightBlue,
          )
        ],
        showingTooltipIndicators: [0],
      );
    });
  }
}
