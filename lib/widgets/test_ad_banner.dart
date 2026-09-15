import 'package:flutter/material.dart';

class TestAdBanner extends StatelessWidget {
  final bool compact;

  const TestAdBanner({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Row(
          children: [
            Icon(
              Icons.storefront_outlined,
              size: compact ? 28 : 36,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Publicidad',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Ferretería El Constructor',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  const Text('Materiales para tu obra cerca de ti'),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Anuncio de prueba')),
                );
              },
              child: const Text('Ver oferta'),
            ),
          ],
        ),
      ),
    );
  }
}
