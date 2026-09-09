import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Real logo helper — uses SVG assets from assets/logos/ with fallback to letter badge
class ModelLogo extends StatelessWidget {
  final String family; // qwen, deepseek, llama, mistral, gemma, phi, etc
  final double size;
  const ModelLogo({super.key, required this.family, this.size = 18});

  String _assetForFamily(String f) {
    final lower = f.toLowerCase();
    if (lower.contains('deepseek')) return 'assets/logos/deepseek.svg';
    if (lower.contains('qwen')) return 'assets/logos/qwen.svg';
    if (lower.contains('llama')) return 'assets/logos/llama.svg';
    if (lower.contains('mistral')) return 'assets/logos/mistral.svg';
    if (lower.contains('gemma')) return 'assets/logos/gemma.svg';
    if (lower.contains('phi')) return 'assets/logos/phi.svg';
    if (lower.contains('qwq')) return 'assets/logos/qwq.svg';
    return 'assets/logos/generic.svg';
  }

  Color _bgForFamily(String f) {
    final lower = f.toLowerCase();
    if (lower.contains('deepseek')) return const Color(0xFF1A73E8);
    if (lower.contains('qwen')) return const Color(0xFF00A67D);
    if (lower.contains('llama')) return const Color(0xFF9333EA);
    if (lower.contains('mistral')) return const Color(0xFFEA580C);
    if (lower.contains('gemma')) return const Color(0xFF0EA5E9);
    if (lower.contains('phi')) return const Color(0xFF6366F1);
    if (lower.contains('qwq')) return const Color(0xFF059669);
    return Colors.deepPurple;
  }

  @override
  Widget build(BuildContext context) {
    final asset = _assetForFamily(family);
    final bg = _bgForFamily(family);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: bg.withValues(alpha: 0.2), width: 1),
        boxShadow: [BoxShadow(color: bg.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(size * 0.15),
        child: SvgPicture.asset(
          asset,
          width: size * 0.7,
          height: size * 0.7,
          fit: BoxFit.contain,
          placeholderBuilder: (ctx) => Center(child: Text(family.isNotEmpty ? family[0].toUpperCase() : '?', style: TextStyle(color: bg, fontSize: size * 0.5, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  static Widget withLabel(String family, String modelName, {double size = 20, bool showFamilyBadge = true}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ModelLogo(family: family, size: size),
        const SizedBox(width: 6),
        if (showFamilyBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _familyColorStatic(family).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(family.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _familyColorStatic(family))),
          ),
      ],
    );
  }

  static Color _familyColorStatic(String family) {
    final f = family.toLowerCase();
    if (f.contains('deepseek')) return const Color(0xFF1A73E8);
    if (f.contains('qwen')) return const Color(0xFF00A67D);
    if (f.contains('llama')) return const Color(0xFF9333EA);
    if (f.contains('mistral')) return const Color(0xFFEA580C);
    if (f.contains('gemma')) return const Color(0xFF0EA5E9);
    if (f.contains('phi')) return const Color(0xFF6366F1);
    return Colors.deepPurple;
  }
}
