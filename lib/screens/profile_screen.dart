import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatelessWidget {
  final Set<String> tabooItems;
  final VoidCallback onNavigateToSeasoning;

  const ProfileScreen({
    super.key,
    required this.tabooItems,
    required this.onNavigateToSeasoning,
  });

  static const String _version = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '👤 我的',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AppHeader(),
            const SizedBox(height: 8),
            _buildSection(context, '饮食偏好', [
              _PrefsTabooTile(tabooItems: tabooItems, onTap: onNavigateToSeasoning),
            ]),
            const SizedBox(height: 16),
            _buildSection(context, '使用说明', [
              _NavTile(
                icon: Icons.help_outline,
                title: '如何使用',
                onTap: () => _showHowToUse(context),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection(context, '关于应用', [
              _NavTile(
                icon: Icons.feedback_outlined,
                title: '意见反馈',
                onTap: () => _showFeedback(context),
              ),
              const _Divider(),
              _InfoTile(icon: Icons.info_outline, title: '版本', value: _version),
            ]),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                '涮得刚好，每一口都是完美',
                style: TextStyle(color: Color(0xFF3A3A3A), fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFFCC00),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  void _showHowToUse(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('如何使用', style: TextStyle(color: Colors.white, fontSize: 17)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HowToRow('👆 轻触食材圆圈', '开始计时，外圈黄色闪烁'),
            SizedBox(height: 10),
            _HowToRow('🟡 黄色外圈', '正在煮制中'),
            SizedBox(height: 10),
            _HowToRow('🟢 绿色常亮', '完美出锅！震动提醒'),
            SizedBox(height: 10),
            _HowToRow('🔴 红色急闪', '已严重超时，快捞出来'),
            SizedBox(height: 10),
            _HowToRow('👆 长按圆圈', '重置该食材，重新计时'),
            SizedBox(height: 10),
            _HowToRow('🥣 调料标签', '查看忌口设置与蘸料方案'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('知道了', style: TextStyle(color: Color(0xFFFFCC00))),
          ),
        ],
      ),
    );
  }

  void _showFeedback(BuildContext context) {
    const email = 'feedback@hotpot-app.example';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('意见反馈', style: TextStyle(color: Colors.white, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('欢迎把你的想法、建议或 Bug 反馈给我们 😊',
                style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Clipboard.setData(const ClipboardData(text: email));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('邮箱已复制'),
                    backgroundColor: Color(0xFF2A2A2A),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF242424),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: Row(
                  children: [
                    const Text(email,
                        style: TextStyle(color: Color(0xFFFFCC00), fontSize: 13)),
                    const Spacer(),
                    const Icon(Icons.copy, size: 15, color: Color(0xFF666666)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭', style: TextStyle(color: Color(0xFF888888))),
          ),
        ],
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: const Column(
        children: [
          Text('🍲', style: TextStyle(fontSize: 56)),
          SizedBox(height: 10),
          Text(
            '火锅捞捞',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            '你的专属涮锅计时助手',
            style: TextStyle(color: Color(0xFF666666), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _PrefsTabooTile extends StatelessWidget {
  final Set<String> tabooItems;
  final VoidCallback onTap;

  const _PrefsTabooTile({required this.tabooItems, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.no_food_outlined, size: 20, color: Color(0xFF888888)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('忌口设置', style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 6),
                  tabooItems.isEmpty
                      ? const Text('暂未设置，点击前往调料页配置',
                          style: TextStyle(color: Color(0xFF555555), fontSize: 12))
                      : Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: tabooItems.map((item) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3A1818),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFF3B30).withValues(alpha: 0.4)),
                            ),
                            child: Text(item,
                                style: const TextStyle(color: Color(0xFFFF6B60), fontSize: 11)),
                          )).toList(),
                        ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFF555555)),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _NavTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF888888)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14))),
            const Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFF555555)),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF888888)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14))),
          Text(value, style: const TextStyle(color: Color(0xFF666666), fontSize: 14)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 48),
      child: Divider(height: 1, color: Color(0xFF242424)),
    );
  }
}

class _HowToRow extends StatelessWidget {
  final String label;
  final String desc;

  const _HowToRow(this.label, this.desc);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13)),
        ),
        Expanded(
          child: Text(desc, style: const TextStyle(color: Color(0xFF888888), fontSize: 13)),
        ),
      ],
    );
  }
}
