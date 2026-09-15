import 'package:flutter/material.dart';

import '../services/profile_storage.dart';
import '../widgets/test_ad_banner.dart';
import 'solicitudes_ferreteria_page.dart';

class AppStartPage extends StatefulWidget {
  final WidgetBuilder maestroPageBuilder;

  const AppStartPage({super.key, required this.maestroPageBuilder});

  @override
  State<AppStartPage> createState() => _AppStartPageState();
}

class _AppStartPageState extends State<AppStartPage> {
  late final Future<String?> _profileIdFuture;

  @override
  void initState() {
    super.initState();
    _profileIdFuture = ProfileStorage().loadProfileId();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _profileIdFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _StartupLoadingPage();
        }

        final destination = profileDestinationFromId(snapshot.data);
        if (destination == null) {
          return ProfileSelectionPage(
            maestroPageBuilder: widget.maestroPageBuilder,
          );
        }

        return ProfileSelectionPage.pageForDestination(
          destination,
          widget.maestroPageBuilder,
        );
      },
    );
  }
}

class _StartupLoadingPage extends StatelessWidget {
  const _StartupLoadingPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chaupi Master')),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/chaupi_master_logo.png',
                fit: BoxFit.contain,
                width: 180,
                height: 100,
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSelectionPage extends StatelessWidget {
  final WidgetBuilder maestroPageBuilder;

  const ProfileSelectionPage({super.key, required this.maestroPageBuilder});

  static Widget pageForDestination(
    ProfileDestination destination,
    WidgetBuilder maestroPageBuilder,
  ) {
    switch (destination) {
      case ProfileDestination.maestro:
        return Builder(builder: maestroPageBuilder);
      case ProfileDestination.ferreteria:
        return SolicitudesFerreteriaPage(
          maestroPageBuilder: maestroPageBuilder,
        );
      default:
        final profile = _profiles.firstWhere(
          (option) => option.destination == destination,
        );
        return TemporaryProfilePage(
          title: profile.title,
          description: profile.description,
          maestroPageBuilder: maestroPageBuilder,
        );
    }
  }

  static const _profiles = [
    _ProfileOption(
      title: 'Soy Maestro o Profesional',
      description: 'Ofrezco servicios y preparo presupuestos.',
      icon: Icons.construction_outlined,
      destination: ProfileDestination.maestro,
    ),
    _ProfileOption(
      title: 'Soy Cliente',
      description: 'Necesito contratar un trabajo o servicio.',
      icon: Icons.person_outline,
      destination: ProfileDestination.cliente,
    ),
    _ProfileOption(
      title: 'Soy Ferretería',
      description: 'Recibo solicitudes y envío proformas.',
      icon: Icons.storefront_outlined,
      destination: ProfileDestination.ferreteria,
    ),
    _ProfileOption(
      title: 'Soy Distribuidor',
      description: 'Ofrezco materiales y productos al por mayor.',
      icon: Icons.inventory_2_outlined,
      destination: ProfileDestination.distribuidor,
    ),
    _ProfileOption(
      title: 'Soy Transportista',
      description: 'Realizo entregas, fletes o retiro de escombros.',
      icon: Icons.local_shipping_outlined,
      destination: ProfileDestination.transportista,
    ),
    _ProfileOption(
      title: 'Alquilo maquinaria o herramientas',
      description: 'Ofrezco equipos y herramientas en alquiler.',
      icon: Icons.handyman_outlined,
      destination: ProfileDestination.alquiler,
    ),
  ];

  Future<void> _openProfile(
    BuildContext context,
    _ProfileOption profile,
  ) async {
    await ProfileStorage().saveProfileId(profile.destination.id);
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileSelectionPage.pageForDestination(
          profile.destination,
          maestroPageBuilder,
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chaupi Master'), centerTitle: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 700 ? 2 : 1;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/chaupi_master_logo.png',
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: 110,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Elige cómo usarás Chaupi Master',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selecciona el perfil que mejor describe lo que haces.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _profiles.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 160,
                  ),
                  itemBuilder: (context, index) {
                    final profile = _profiles[index];
                    return _ProfileCard(
                      profile: profile,
                      onTap: () => _openProfile(context, profile),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const TestAdBanner(),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PromotionPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Anuncia tu negocio en Chaupi Master',
                      textAlign: TextAlign.center,
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
}

class _ProfileCard extends StatelessWidget {
  final _ProfileOption profile;
  final VoidCallback onTap;

  const _ProfileCard({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(profile.icon, size: 36),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profile.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(profile.description),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class TemporaryProfilePage extends StatelessWidget {
  final String title;
  final String description;
  final WidgetBuilder maestroPageBuilder;

  const TemporaryProfilePage({
    super.key,
    required this.title,
    required this.description,
    required this.maestroPageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Cambiar perfil',
            icon: const Icon(Icons.switch_account_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileSelectionPage(
                  maestroPageBuilder: maestroPageBuilder,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.construction_outlined, size: 64),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(description, textAlign: TextAlign.center),
                const SizedBox(height: 18),
                const Text('Estamos preparando este espacio.'),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileSelectionPage(
                        maestroPageBuilder: maestroPageBuilder,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.switch_account_outlined),
                  label: const Text('Cambiar perfil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PromotionPage extends StatelessWidget {
  const PromotionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anuncia en Chaupi Master')),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Próximamente podrás promocionar tu negocio dentro de Chaupi Master.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileOption {
  final String title;
  final String description;
  final IconData icon;
  final ProfileDestination destination;

  const _ProfileOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.destination,
  });
}

enum ProfileDestination {
  maestro,
  cliente,
  ferreteria,
  distribuidor,
  transportista,
  alquiler,
}

extension on ProfileDestination {
  String get id {
    switch (this) {
      case ProfileDestination.maestro:
        return 'maestro_profesional';
      case ProfileDestination.cliente:
        return 'cliente';
      case ProfileDestination.ferreteria:
        return 'ferreteria';
      case ProfileDestination.distribuidor:
        return 'distribuidor';
      case ProfileDestination.transportista:
        return 'transportista';
      case ProfileDestination.alquiler:
        return 'alquiler_maquinaria';
    }
  }
}

ProfileDestination? profileDestinationFromId(String? id) {
  for (final destination in ProfileDestination.values) {
    if (destination.id == id) return destination;
  }
  return null;
}
