import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../controllers/map_controller.dart';
import '../models/node_model.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MapController>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 👇 1. THEME SELECTOR (Light, Dark, Sepia)
          const Text('APPEARANCE',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildThemeCard(context, controller, 'light', 'Light',
                  Icons.light_mode, Colors.orange),
              _buildThemeCard(context, controller, 'dark', 'Dark',
                  Icons.dark_mode, Colors.purple),
              _buildThemeCard(context, controller, 'sepia', 'Sepia',
                  Icons.menu_book, Colors.brown),
              _buildThemeCard(
                  context,
                  controller,
                  'zen',
                  'Zen', // 👈 Naya Theme
                  Icons.spa,
                  const Color(0xFF435747)),
            ],
          ),
          const SizedBox(height: 30),

          // 👇 2 & 3. DATA MANAGEMENT (Import / Export)
          const Text('DATA MANAGEMENT',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file_outlined,
                      color: Color(0xFFD4A373)),
                  title: Text('Import JSON',
                      style: TextStyle(color: theme.colorScheme.onSurface)),
                  subtitle: Text('Paste your backup JSON here',
                      style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                          fontSize: 12)),
                  onTap: () => _showImportDialog(context, controller, theme),
                ),
                Divider(
                    height: 1,
                    color: theme.dividerColor.withValues(alpha: 0.1)),
                ListTile(
                  leading: const Icon(Icons.download_outlined,
                      color: Color(0xFFA5A58D)),
                  title: Text('Export JSON',
                      style: TextStyle(color: theme.colorScheme.onSurface)),
                  subtitle: Text('Backup your mind maps to clipboard',
                      style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                          fontSize: 12)),
                  onTap: () {
                    final jsonStr = jsonEncode(
                        controller.nodes.map((n) => n.toJson()).toList());
                    Clipboard.setData(ClipboardData(text: jsonStr));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('✅ Data copied to clipboard!'),
                          backgroundColor: Colors.green),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // 👇 4. STORAGE
          const Text('DATA STORAGE',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
            ),
            child: SwitchListTile(
              title: Text('Cloud Sync (Firebase)',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface, fontSize: 16)),
              subtitle: Text(
                  FirebaseAuth.instance.currentUser == null
                      ? 'Sign in to enable cloud sync across devices.'
                      : 'Save maps to cloud and access on any device.',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 12)),
              value: controller.storageMode == StorageMode.cloud,
              activeThumbColor: const Color(0xFFE8D5B7),
              activeTrackColor: const Color(0xFFE8D5B7).withValues(alpha: 0.3),
              onChanged: (bool value) async {
                // 👇 Guest trying to enable cloud → prompt signup
                if (value && FirebaseAuth.instance.currentUser == null) {
                  final signedIn = await Navigator.push<bool>(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const LoginScreen(),
                      transitionsBuilder: (_, animation, __, child) {
                        return SlideTransition(
                          position:
                              Tween(begin: const Offset(0, 1), end: Offset.zero)
                                  .animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic)),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                  if (signedIn != true) return;
                  if (!context.mounted) return;
                  await controller.toggleStorageMode(true);
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Cloud Sync Enabled ☁️'),
                        backgroundColor: Colors.green),
                  );
                  return;
                }
                controller.toggleStorageMode(value);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(value
                      ? 'Cloud Sync Enabled ☁️'
                      : 'Local Storage Enabled 📱'),
                  backgroundColor: value ? Colors.green : Colors.grey,
                ));
              },
            ),
          ),
          const SizedBox(height: 30),

          // 👇 5. ACCOUNT (Logout)
          const Text('ACCOUNT',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: (FirebaseAuth.instance.currentUser == null
                          ? const Color(0xFFE8D5B7)
                          : Colors.redAccent)
                      .withValues(alpha: 0.3)),
            ),
            child: FirebaseAuth.instance.currentUser == null
                ? ListTile(
                    leading: const Icon(Icons.login, color: Color(0xFFE8D5B7)),
                    title: const Text('Sign In / Sign Up',
                        style: TextStyle(
                            color: Color(0xFFE8D5B7),
                            fontWeight: FontWeight.w600)),
                    subtitle: Text('Sync data across devices, access profile',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                            fontSize: 12)),
                    onTap: () async {
                      final signedIn = await Navigator.push<bool>(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const LoginScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            return SlideTransition(
                              position: Tween(
                                      begin: const Offset(0, 1),
                                      end: Offset.zero)
                                  .animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic)),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                      );
                      if (signedIn == true && context.mounted) {
                        controller.loadNodes();
                      }
                    },
                  )
                : ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text('Logout',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600)),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      controller.loadNodes();
                    },
                  ),
          ),
          const SizedBox(height: 40),
          const Center(
              child: Text('Abcitta v1.0.0',
                  style: TextStyle(color: Colors.grey, fontSize: 12))),
        ],
      ),
    );
  }

  // 👇 Helper widget for Theme Cards
  Widget _buildThemeCard(BuildContext context, MapController controller,
      String mode, String title, IconData icon, Color color) {
    final isSelected = controller.themeMode == mode;
    final theme = Theme.of(context);

    return SizedBox(
      width: 80, // 👈 Fixed width for Wrap
      child: GestureDetector(
        onTap: () => controller.setThemeMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? color
                  : theme.dividerColor.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 28),
              const SizedBox(height: 8),
              Text(title,
                  style: TextStyle(
                      color: isSelected ? color : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  // Import Dialog Logic
  void _showImportDialog(
      BuildContext context, MapController controller, ThemeData theme) {
    TextEditingController jsonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Import JSON',
            style: TextStyle(color: theme.colorScheme.onSurface)),
        content: TextField(
          controller: jsonCtrl,
          maxLines: 5,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 12),
          decoration: const InputDecoration(
              hintText: 'Paste JSON here...',
              hintStyle: TextStyle(color: Colors.grey)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              try {
                final List<dynamic> decoded = jsonDecode(jsonCtrl.text);
                final newNodes =
                    decoded.map((e) => MindMapNode.fromJson(e)).toList();
                final count = await controller.importNodesFromJson(newNodes);
                if (!context.mounted) return;
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('✅ Imported $count nodes!'),
                    backgroundColor: Colors.green));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('❌ Error: $e'),
                    backgroundColor: Colors.redAccent));
              }
            },
            child: const Text('Import',
                style: TextStyle(color: Color(0xFFE8D5B7))),
          ),
        ],
      ),
    );
  }
}
