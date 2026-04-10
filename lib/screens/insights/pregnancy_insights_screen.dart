import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PregnancyInsightsScreen extends StatefulWidget {
  final int pregnancyWeek;
  const PregnancyInsightsScreen({super.key, this.pregnancyWeek = 24});

  @override
  State<PregnancyInsightsScreen> createState() => _PregnancyInsightsScreenState();
}

class _PregnancyInsightsScreenState extends State<PregnancyInsightsScreen> {
  int _currentWeek = 24;

  @override
  void initState() {
    super.initState();
    _currentWeek = widget.pregnancyWeek;
    _loadTrimester();
  }

  Future<void> _loadTrimester() async {
    final prefs = await SharedPreferences.getInstance();
    int? savedWeek = prefs.getInt("pregnancyWeek");
    if (mounted) {
      setState(() {
        if (savedWeek != null) _currentWeek = savedWeek;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data for logic
    const double bloodSugar = 124.0;
    const int steps = 4280;
    const double weightGain = 0.2; // kg this week

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E4A6B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pregnancy Insights',
          style: TextStyle(
            color: Color(0xFF2E4A6B),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // ── Gestational Assessment Card ──────────────────────────
            _buildAssessmentCard(),

            const SizedBox(height: 32),

            // ── Smart Insights Section ────────────────────────────────
            const Text(
              'Smart Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A2B3C),
              ),
            ),
            const SizedBox(height: 16),

            // Logic based insight cards
            if (bloodSugar > 120)
              _buildInsightCard(
                title: 'Blood sugar slightly high',
                desc: 'Your levels are above target. Consider reducing sugar intake and increase gentle walking.',
                status: 'Warning',
                icon: Icons.water_drop_outlined,
                iconColor: const Color(0xFFB5616A),
                bgColor: const Color(0xFFFFF0F0),
              ),
            
            if (steps < 5000)
              _buildInsightCard(
                title: 'Activity level low',
                desc: 'Regular movement helps glucose control. Try a 15-minute walk after meals.',
                status: 'Warning',
                icon: Icons.directions_run_rounded,
                iconColor: const Color(0xFFD68A3D),
                bgColor: const Color(0xFFFDF3E9),
              ),

            if (weightGain < 0.5)
              _buildInsightCard(
                title: 'Stable weight trend',
                desc: 'Your weight gain is within the healthy range for this week.',
                status: 'Normal',
                icon: Icons.monitor_weight_outlined,
                iconColor: const Color(0xFF2E7D6B),
                bgColor: const Color(0xFFE0F4F0),
              ),
            
            _buildInsightCard(
              title: 'Consistent tracking',
              desc: 'Great job logging your data daily! This helps provide better insights.',
              status: 'Normal',
              icon: Icons.check_circle_outline,
              iconColor: const Color(0xFF3A6EA8),
              bgColor: const Color(0xFFE8F0F8),
            ),

            const SizedBox(height: 32),

            // ── Category Sections ─────────────────────────────────────
            _buildSectionHeader('Lifestyle Tips'),
            const SizedBox(height: 16),
            _recommendationTile(
              icon: Icons.restaurant_rounded,
              iconColor: const Color(0xFFB5616A),
              label: 'Focus on Low-GI snacks',
            ),
            _recommendationTile(
              icon: Icons.nightlight_round,
              iconColor: const Color(0xFF3A6EA8),
              label: 'Aim for 8 hours of sleep',
            ),
            _recommendationTile(
              icon: Icons.local_drink,
              iconColor: const Color(0xFF4AC2CD),
              label: 'Stay hydrated (2.5L target)',
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3A6EA8).withValues(alpha: 0.9),
            const Color(0xFF2E4A6B).withValues(alpha: 0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A6EA8).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'GESTATIONAL HEALTH OVERVIEW',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getWeekStatus(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Keep monitoring your blood sugar consistently to maintain optimal vitality.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekStatus() {
    int week = _currentWeek;
    String status = "Early Pregnancy";
    if (week >= 13 && week <= 26) {
      status = "Growth Phase";
    } else if (week >= 27) {
      status = "Final Stage";
    }
    return "Week $week • $status";
  }

  Widget _buildInsightCard({
    required String title,
    required String desc,
    required String status,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2B3C),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A8FA6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A2B3C),
      ),
    );
  }

  Widget _recommendationTile({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2B3C),
            ),
          ),
        ],
      ),
    );
  }
}
