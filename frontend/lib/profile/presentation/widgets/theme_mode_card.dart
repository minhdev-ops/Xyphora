import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeModeCard extends StatefulWidget {
  const ThemeModeCard({super.key});

  @override
  State<ThemeModeCard> createState() => _ThemeModeCardState();
}

class _ThemeModeCardState extends State<ThemeModeCard> {
  bool _isDarkMode = false;
  int _selectedColor = 0;

  final List<Color> _colors = const [
    Color(0xFF0F5C43),
    Color(0xFF1976D2),
    Color(0xFF424242),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đổi chế độ',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D1D1D),
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() => _isDarkMode = value);
                  },
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF0F5C43),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFD0D0D0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF0F5C43),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'Xanh lá - Sinh thái',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F5C43),
                    ),
                  ),
                ),
              ),
              ...List.generate(_colors.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = index);
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _colors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == index
                            ? const Color(0xFF1D1D1D)
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        if (_selectedColor == index)
                          BoxShadow(
                            color: _colors[index].withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: _selectedColor == index
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
