import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MonthlyExpensesCard extends StatelessWidget {
  const MonthlyExpensesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chi tiêu hàng tháng',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D1D1D),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4FAF6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      'Năm nay',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0F5C43),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF0F5C43),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            height: 160,
            child: _buildBarChart(),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final List<_BarData> bars = [
      _BarData('Thg1', 0.5, false),
      _BarData('Thg2', 0.35, false),
      _BarData('Thg3', 0.45, false),
      _BarData('Thg4', 0.9, true),
      _BarData('Thg5', 0.3, false),
      _BarData('Thg6', 0.4, false),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = (constraints.maxWidth - (bars.length - 1) * 16) / bars.length;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: bars.map((bar) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: barWidth > 36 ? 36 : barWidth,
                      height: constraints.maxHeight * 0.75 * bar.height,
                      decoration: BoxDecoration(
                        color: bar.isHighlighted
                            ? const Color(0xFF0F5C43)
                            : const Color(0xFFD9E8DF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bar.label,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: bar.isHighlighted
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: bar.isHighlighted
                            ? const Color(0xFF0F5C43)
                            : const Color(0xFF8A8A8A),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _BarData {
  final String label;
  final double height;
  final bool isHighlighted;

  _BarData(this.label, this.height, this.isHighlighted);
}
