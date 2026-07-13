import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/data/models/reward_model.dart';
import 'package:autowash_pro/presentation/providers/loyalty_provider.dart';
import 'package:autowash_pro/presentation/providers/auth_provider.dart';
import 'package:autowash_pro/presentation/screens/loyalty/vouchers_screen.dart';

class LoyaltyHomeScreen extends StatefulWidget {
  const LoyaltyHomeScreen({super.key});

  @override
  State<LoyaltyHomeScreen> createState() => _LoyaltyHomeScreenState();
}

class _LoyaltyHomeScreenState extends State<LoyaltyHomeScreen> {
  int _selectedTab = 0; // 0: All, 1: Services, 2: Discounts

  String _translateTier(String tier) {
    switch (tier.toLowerCase()) {
      case 'silver': return 'Bạc';
      case 'gold': return 'Vàng';
      case 'platinum': return 'Bạch kim';
      default: return 'Thành viên';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LoyaltyProvider>(context, listen: false);
      provider.loadLoyaltyHome();
      provider.loadRewards();
    });
  }

  void _redeemReward(RewardModel reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Đổi Quà Tặng', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.pristineNavy)),
        content: Text('Dùng ${reward.pointsCost} điểm để đổi:\n\n${reward.name}?', style: GoogleFonts.outfit(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final provider = Provider.of<LoyaltyProvider>(context, listen: false);
              final messenger = ScaffoldMessenger.of(context);
              navigator.pop();
              final success = await provider.redeemReward(reward.id);
              if (context.mounted) {
                if (success) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Đổi quà tặng thành công!'), backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(content: Text(provider.error ?? 'Có lỗi xảy ra'), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating),
                  );
                }
              }
            },
            child: Text('Đổi quà', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: Consumer<LoyaltyProvider>(
          builder: (context, provider, _) {
            if (provider.error != null && provider.loyaltyHome == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Lỗi: ${provider.error}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          provider.loadLoyaltyHome();
                          provider.loadRewards();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final loyalty = provider.loyaltyHome;
            if (loyalty == null) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
            }

            final currentTier = loyalty.tierName;
            final translatedTier = _translateTier(currentTier);
            final isSilver = currentTier.toLowerCase() == 'silver';
            final badgeColor = isSilver ? Colors.grey.shade300 : Colors.amber;
            final badgeTextColor = isSilver ? AppTheme.pristineNavy : Colors.black;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.pristineNavy, size: 20),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  const SizedBox(width: 12),
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppTheme.accentLightBlue,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset('assets/images/background.png', fit: BoxFit.cover, errorBuilder: (_, _, _) => Icon(Icons.person, color: AppTheme.primaryBlue)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      auth.user?.fullName ?? 'Pristine Care',
                                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.pristineNavy),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.card_giftcard_rounded, color: AppTheme.pristineNavy),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const VouchersScreen()));
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.pristineNavy),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Member Status Card
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.pristineDark, AppTheme.primaryBlue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: AppTheme.primaryBlue.withAlpha(50), blurRadius: 20, offset: const Offset(0, 8))
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'HẠNG HIỆN TẠI',
                                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white.withAlpha(200), letterSpacing: 1),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: badgeColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.stars_rounded, size: 12, color: badgeTextColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          translatedTier,
                                          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: badgeTextColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Hạng $translatedTier',
                                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '${loyalty.loyaltyPoints}',
                                    style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, height: 1),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'điểm',
                                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withAlpha(200)),
                                  ),
                                  const Spacer(),
                                  if (loyalty.pointsToNextTier > 0)
                                    Text(
                                      'Còn ${loyalty.pointsToNextTier} điểm để lên ${_translateTier(loyalty.nextTierName)}',
                                      style: GoogleFonts.outfit(fontSize: 12, color: Colors.white.withAlpha(200)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (loyalty.pointsToNextTier > 0) ...[
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(30),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final totalRequired = loyalty.loyaltyPoints + loyalty.pointsToNextTier;
                                      final ratio = totalRequired > 0 ? (loyalty.loyaltyPoints / totalRequired).clamp(0.0, 1.0) : 0.0;
                                      return FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: ratio,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: badgeColor,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('0', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white.withAlpha(200))),
                                    Text('${loyalty.loyaltyPoints + loyalty.pointsToNextTier} điểm', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white.withAlpha(200))),
                                  ],
                                ),
                              ]
                            ],
                          ),
                        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                        const SizedBox(height: 24),
                        
                        // Tabs
                        Row(
                          children: [
                            _buildTab(0, 'Tất cả'),
                                const SizedBox(width: 12),
                                _buildTab(1, 'Dịch vụ'),
                                const SizedBox(width: 12),
                                _buildTab(2, 'Giảm giá'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        Text('Quà tặng sẵn có', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.pristineNavy)),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                
                // Rewards List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final reward = provider.rewards[index];
                        final canRedeem = loyalty.loyaltyPoints >= reward.pointsCost;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Row(
                            children: [
                              // Icon/Image
                              Container(
                                width: 70, height: 70,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentLightBlue,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: reward.type.toLowerCase() == 'discount' 
                                      ? Text('GIẢM\n${reward.discountValue.toInt()}%', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, fontSize: 14))
                                      : Icon(Icons.clean_hands_rounded, size: 32, color: AppTheme.primaryBlue),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(reward.name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text(reward.description, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.stars_rounded, size: 14, color: canRedeem ? Colors.amber.shade700 : AppTheme.textMuted),
                                        const SizedBox(width: 4),
                                        Text('${reward.pointsCost} điểm', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: canRedeem ? Colors.amber.shade700 : AppTheme.textMuted)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Action Button
                              GestureDetector(
                                onTap: canRedeem ? () => _redeemReward(reward) : null,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: canRedeem ? Colors.white : Colors.grey.shade100,
                                    border: Border.all(color: canRedeem ? AppTheme.primaryBlue : Colors.transparent),
                                  ),
                                  child: Icon(
                                    canRedeem ? Icons.add : Icons.lock_outline_rounded,
                                    size: 20, color: canRedeem ? AppTheme.primaryBlue : AppTheme.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.1);
                      },
                      childCount: provider.rewards.length,
                    ),
                  ),
                ),
                
                // Tier Benefits section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 80),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Đặc quyền hạng $translatedTier', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.pristineNavy)),
                          const SizedBox(height: 20),
                          _buildBenefit(Icons.check_circle_outline_rounded, 'Nhân 1.2x điểm tích lũy', 'Tích lũy điểm nhanh hơn trong mỗi lần ghé thăm.'),
                          const SizedBox(height: 16),
                          _buildBenefit(Icons.check_circle_outline_rounded, 'Quà tặng sinh nhật', 'Một phần quà đặc biệt dành riêng cho bạn trong tháng sinh nhật.'),
                          const SizedBox(height: 16),
                          _buildBenefit(Icons.check_circle_outline_rounded, 'Ưu tiên đặt lịch', 'Truy cập đặt lịch các khung giờ cuối tuần sớm hơn 24 giờ.'),
                          const SizedBox(height: 24),
                          
                          if (loyalty.pointsToNextTier > 0)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9E6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.military_tech_rounded, color: Colors.amber, size: 32),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Mở khóa hạng ${_translateTier(loyalty.nextTierName)}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade700)),
                                        const SizedBox(height: 2),
                                        Text('Nhận dịch vụ đưa đón xe miễn phí & tích lũy 1.5x điểm.', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textPrimary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.pristineNavy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.pristineNavy : Colors.grey.shade300),
        ),
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppTheme.pristineNavy,
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Text(desc, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
