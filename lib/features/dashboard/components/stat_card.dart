part of '../dashboard_page.dart';

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subTitle = '',
    this.onTap,
    this.alignment = Alignment.centerRight,
  });
  final String title, value, subTitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 5),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(value,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(title,
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                if (subTitle.isNotEmpty) const SizedBox(height: 4),
                Text(subTitle,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
        ),
      );
}
