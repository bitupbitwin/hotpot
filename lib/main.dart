import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_scaffold.dart';
import 'services/feedback_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 锁定竖屏，仅手机使用
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await FeedbackService.init();
  runApp(const HotpotApp());
}

class HotpotApp extends StatelessWidget {
  const HotpotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '火锅捞捞',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
      home: const MainScaffold(),
    );
  }
}
