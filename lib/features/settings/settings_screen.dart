import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:sizesync/shared/providers/providers.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final settings = ref.watch(appSettingsProvider);
    final isPremium = ref.watch(purchaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          const _SectionHeader('Отображение'),
          ListTile(
            title: const Text('Тема'),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('Авто')),
                  ButtonSegment(value: ThemeMode.light, label: Text('Светлая')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Тёмная')),
                ],
                selected: {themeMode},
                onSelectionChanged: (s) => ref.read(themeProvider.notifier).setTheme(s.first),
              ),
            ),
          ),
          ListTile(
            title: const Text('Система размеров'),
            trailing: DropdownButton<String>(
              value: settings.sizeSystem,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'EU', child: Text('EU')),
                DropdownMenuItem(value: 'US', child: Text('US')),
                DropdownMenuItem(value: 'UK', child: Text('UK')),
                DropdownMenuItem(value: 'Asia', child: Text('Asia')),
              ],
              onChanged: (v) {
                if (v != null) ref.read(appSettingsProvider.notifier).setSizeSystem(v);
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Дюймы'),
            subtitle: const Text('Показывать мерки в дюймах'),
            value: settings.useInches,
            onChanged: (v) => ref.read(appSettingsProvider.notifier).setUseInches(value: v),
          ),
          const Divider(),
          const _SectionHeader('Подписка'),
          if (isPremium)
            const ListTile(leading: Icon(Icons.workspace_premium), title: Text('Premium активен ✓'), subtitle: Text('Доступны все бренды'))
          else
            ListTile(
              leading: const Icon(Icons.workspace_premium),
              title: const Text('Разблокировать Premium'),
              subtitle: const Text('Доступ ко всем брендам'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/paywall'),
            ),
          ListTile(leading: const Icon(Icons.restore), title: const Text('Восстановить покупки'), onTap: () => _restorePurchases(context, ref)),
          const Divider(),
          const _SectionHeader('Приложение'),
          ListTile(leading: const Icon(Icons.star_outline), title: const Text('Оценить приложение'), onTap: _requestReview),
          ListTile(leading: const Icon(Icons.mail_outline), title: const Text('Написать нам'), onTap: _contactUs),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('О приложении'),
            onTap: () => showAboutDialog(context: context, applicationName: 'SizeSync', applicationVersion: '1.0.0'),
          ),
        ],
      ),
    );
  }

  Future<void> _restorePurchases(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(purchaseProvider.notifier).restorePurchases();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Покупки восстановлены' : 'Нет активных покупок')));
  }

  Future<void> _requestReview() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) await review.requestReview();
  }

  Future<void> _contactUs() async {
    final uri = Uri.parse('mailto:support@sizesync.app?subject=SizeSync%20feedback');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
    );
  }
}
