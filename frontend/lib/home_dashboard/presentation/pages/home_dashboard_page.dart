import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/balance_card.dart';
import '../widgets/monthly_expenses_card.dart';
import '../widgets/recent_transactions_card.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      bottomNavigationBar: const CustomBottomNavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 24),
              const BalanceCard(),
              const SizedBox(height: 24),
              const MonthlyExpensesCard(),
              const SizedBox(height: 24),
              const RecentTransactionsCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF0F5C43).withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/BeDauu.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFE8F5E9),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF0F5C43),
                    size: 24,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Trang chủ',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D1D1D),
          ),
        ),
        const Spacer(),
        _buildIconCircle(
          icon: Icons.search_rounded,
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _buildNotificationIcon(),
      ],
    );
  }

  Widget _buildIconCircle({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF1D1D1D),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF1D1D1D),
              size: 22,
            ),
          ),
          Positioned(
            top: 6,
            right: 8,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
