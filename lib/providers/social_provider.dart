import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SocialLink {
  final String id;
  final String platform;
  final IconData icon;
  final String url;

  SocialLink({
    required this.id,
    required this.platform,
    required this.icon,
    required this.url,
  });
}

final socialProvider = FutureProvider<List<SocialLink>>((ref) async {
  final supabase = Supabase.instance.client;
  try {
    final response = await supabase
        .from('social_media_links')
        .select()
        .eq('is_active', true)
        .order('display_order', ascending: true);

    return (response as List).map((item) {
      return SocialLink(
        id: item['id'] as String,
        platform: item['platform'] as String? ?? '',
        icon: _mapIcon(item['icon'] as String? ?? ''),
        url: item['url'] as String? ?? '',
      );
    }).toList();
  } catch (e) {
    return [];
  }
});

IconData _mapIcon(String iconName) {
  switch (iconName) {
    case 'facebook':
      return Icons.facebook_rounded;
    case 'twitter':
      return Icons.alternate_email_rounded;
    case 'instagram':
      return Icons.camera_alt_rounded;
    case 'linkedin':
      return Icons.business_rounded;
    case 'youtube':
      return Icons.play_circle_filled;
    case 'whatsapp':
      return Icons.chat_rounded;
    case 'telegram':
      return Icons.telegram;
    case 'github':
      return Icons.code_rounded;
    default:
      return Icons.link_rounded;
  }
}
