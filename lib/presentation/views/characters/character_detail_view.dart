import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/character_entity.dart';
import '../../../domain/models/extensions/character_ui.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/star_rating.dart';

/// Página de exibição detalhada de um personagem
class CharacterDetailView extends StatelessWidget {
  final Character character;

  const CharacterDetailView({
    super.key,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(character.name),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com nome e raridade
            Card(
              color: Theme.of(context).colorScheme.secondary,
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: Row(
                  children: [
                    // Indicador de raridade
                    Container(
                      width: 6,
                      height: 80,
                      decoration: BoxDecoration(
                        color: character.rarity.color,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    // Informações principais
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            character.name,
                            style: context.textStyles.headlineMedium?.semiBold,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Icon(
                                character.characterClass.icon,
                                size: 18,
                                color: character.characterClass.color,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                character.characterClass.displayName,
                                style: context.textStyles.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Raridade: ${character.rarity.displayName}',
                            style: context.textStyles.bodySmall?.withColor(
                              Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Alinhamento: ${character.alignment.displayName}',
                            style: context.textStyles.bodySmall?.withColor(
                              Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Nível e Estrelas
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.trending_up,
                    label: 'Nível',
                    value: character.level.toString(),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.star,
                    label: 'Estrelas',
                    value: character.stars.toString(),
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Estatísticas de combate
            Text(
              'Estatísticas de Combate',
              style: context.textStyles.titleMedium?.semiBold,
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.flash_on,
                    label: 'Ataque',
                    value: character.attack.toString(),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.favorite,
                    label: 'Vida',
                    value: character.health.toString(),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.warning,
                    label: 'Ameaça',
                    value: character.threat.toString(),
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Avaliação por Estrelas
            Text(
              'Avaliação',
              style: context.textStyles.titleMedium?.semiBold,
            ),
            const SizedBox(height: AppSpacing.md),
            StarRating(stars: character.stars, size: 28),
            const SizedBox(height: AppSpacing.lg),

            // Datas
            Text(
              'Informações',
              style: context.textStyles.titleMedium?.semiBold,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow(
              context,
              label: 'Data de Criação',
              value: _formatDate(character.createdAt),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow(
              context,
              label: 'Última Atualização',
              value: _formatDate(character.updatedAt),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: context.textStyles.labelSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: context.textStyles.headlineSmall?.semiBold,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textStyles.bodyMedium,
        ),
        Text(
          value,
          style: context.textStyles.bodyMedium?.semiBold,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
