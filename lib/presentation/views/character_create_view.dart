import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/theme/app_theme.dart';
import '../../core/typedefs/types_defs.dart';
import '../../core/validators/empty_str_validator.dart';
import '../../domain/models/character_entity.dart';
import '../controllers/characters_view_model.dart';
import '../functions/ui_functions.dart';
import '../widgets/app_drawer.dart';
import '../widgets/date_wheel_picker.dart';
import '../widgets/input_text_field.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Página de criação de personagem
class CharacterCreateView extends StatefulWidget {
  const CharacterCreateView({super.key});

  @override
  State<CharacterCreateView> createState() => _CharacterCreateViewState();
}

class _CharacterCreateViewState extends State<CharacterCreateView> {
  late final CharactersViewModel _vmCharacters;
  late final void Function() _disposeSuccessEffect;
  late final void Function() _disposeErrorEffect;

  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  late final CharacterFormFieldsController _formFields;

  String _name = '';
  CharacterClass _characterClass = CharacterClass.poderoso;
  CharacterRarity _rarity = CharacterRarity.prata;
  CharacterAlignment _alignment = CharacterAlignment.heroi;
  DateTime _createdAt = DateTime.now();
  int _level = 1;
  int _threat = 0;
  int _attack = 0;
  int _health = 0;
  int _stars = 1;

  @override
  void initState() {
    super.initState();
    _formFields = CharacterFormFieldsController();

    _vmCharacters = injector.get<CharactersViewModel>();
    _vmCharacters.charactersState.clearMessage();

    // Listener para atualizar o nome quando o controller mudar
    _formFields.name.controller.addListener(() {
      _name = _formFields.name.controller.text;
    });

    _disposeErrorEffect = effect(() {
      final errorMessage = _vmCharacters.charactersState.message.value;

      if (errorMessage != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          showSnackBar(context, errorMessage, backgroundColor: Colors.red);
          _vmCharacters.charactersState.clearMessage();
        });
      }
    });

    _disposeSuccessEffect = effect(() {
      final result = _vmCharacters.commands.createCharacterCommand.result.value;

      if (result != null && mounted) {
        result.fold(
          onSuccess: (character) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              showSnackBar(context, 'Personagem criado com sucesso!', backgroundColor: Colors.green);
              _vmCharacters.commands.createCharacterCommand.clear();
              Navigator.of(context).pop(); // Volta para a lista
            });
          },
          onFailure: (failure) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              showSnackBar(context, failure.msg, backgroundColor: Colors.red);
              _vmCharacters.commands.createCharacterCommand.clear();
            });
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _disposeSuccessEffect();
    _disposeErrorEffect();
    _scrollController.dispose();
    _formFields.dispose();
    super.dispose();
  }

  void _resetFormView() {
    FocusScope.of(context).unfocus();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _focusFirstError() {
    for (final field in _formFields.fields) {
      final state = field.key.currentState;

      if (state != null && !state.isValid) {
        field.focus.requestFocus();

        Scrollable.ensureVisible(
          field.key.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );

        break;
      }
    }
  }

  bool _validateForm() {
    final valid = _formKey.currentState!.validate();

    if (!valid) {
      _focusFirstError();
    }

    return valid;
  }

  Future<void> _salvarPersonagem() async {
    if (!_validateForm()) return;

    Character newCharacter = Character(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name.trim(),
      characterClass: _characterClass,
      rarity: _rarity,
      alignment: _alignment,
      level: _level,
      threat: _threat,
      attack: _attack,
      health: _health,
      stars: _stars,
      createdAt: _createdAt,
      updatedAt: _createdAt,
    );

    await _vmCharacters.commands.addCharacter(newCharacter);
    _resetFormView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Personagem'),
      ),
      drawer: AppDrawer(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: AppSpacing.paddingLg,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.person_add,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Crie seu personagem personalizado',
                  style: context.textStyles.bodyMedium?.withColor(
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Nome
                InputTextField(
                  fieldKey: _formFields.name.key,
                  controller: _formFields.name.controller,
                  focusNode: _formFields.name.focus,
                  label: 'Nome do Personagem',
                  hint: 'Digite o nome',
                  prefixIcon: Icons.account_circle,
                  validator: (value) =>
                      validateField(value, [EmptyStrValidator()]),
                ),
                const SizedBox(height: AppSpacing.md),

                // Classe
                _buildDropdownField<CharacterClass>(
                  label: 'Classe',
                  value: _characterClass,
                  items: CharacterClass.values,
                  onChanged: (value) => setState(() => _characterClass = value!),
                  displayName: (item) => item.displayName,
                  icon: Icons.category,
                ),
                const SizedBox(height: AppSpacing.md),

                // Raridade
                _buildDropdownField<CharacterRarity>(
                  label: 'Raridade',
                  value: _rarity,
                  items: CharacterRarity.values,
                  onChanged: (value) => setState(() => _rarity = value!),
                  displayName: (item) => item.displayName,
                  icon: Icons.star,
                ),
                const SizedBox(height: AppSpacing.md),

                // Alinhamento
                _buildDropdownField<CharacterAlignment>(
                  label: 'Alinhamento',
                  value: _alignment,
                  items: CharacterAlignment.values,
                  onChanged: (value) => setState(() => _alignment = value!),
                  displayName: (item) => item.displayName,
                  icon: Icons.balance,
                ),
                const SizedBox(height: AppSpacing.md),

                // Data de Criação
                DateWheelPicker(
                  label: 'Data de Criação',
                  selectedDate: _createdAt,
                  onDateSelected: (date) => setState(() => _createdAt = date),
                ),
                const SizedBox(height: AppSpacing.md),

                // Level
                _buildNumericField(
                  icon: Icons.star,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: 'Nível',
                  hint: '[1, 80]',
                  minValue: 1,
                  maxValue: 80,
                  value: _level,
                  onChanged: (value) => setState(() => _level = value),
                ),
                const SizedBox(height: 1),

                // Threat
                _buildNumericField(
                  icon: Icons.warning,
                  iconColor: Colors.red,
                  label: 'Ameaça',
                  hint: 'Min: 0',
                  minValue: 0,
                  maxValue: 999999,
                  value: _threat,
                  onChanged: (value) => setState(() => _threat = value),
                ),
                const SizedBox(height: 1),

                // Attack
                _buildNumericField(
                  icon: Icons.flash_on,
                  iconColor: Colors.orange,
                  label: 'Ataque',
                  hint: 'Min: 0',
                  minValue: 0,
                  maxValue: 999999,
                  value: _attack,
                  onChanged: (value) => setState(() => _attack = value),
                ),
                const SizedBox(height: 1),

                // Health
                _buildNumericField(
                  icon: Icons.favorite,
                  iconColor: Colors.green,
                  label: 'Vida',
                  hint: 'Min: 0',
                  minValue: 0,
                  maxValue: 999999,
                  value: _health,
                  onChanged: (value) => setState(() => _health = value),
                ),
                const SizedBox(height: 1),

                // Stars
                _buildNumericField(
                  icon: Icons.star_border,
                  iconColor: Colors.amber,
                  label: 'Estrelas',
                  hint: '[1, 14]',
                  minValue: 1,
                  maxValue: 14,
                  value: _stars,
                  onChanged: (value) => setState(() => _stars = value),
                ),
                const SizedBox(height: AppSpacing.md),

                // Botão salvar
                Watch((context) {
                  final isRunning =
                      _vmCharacters.commands.createCharacterCommand.isExecuting.value;

                  return ElevatedButton(
                    onPressed: isRunning ? null : _salvarPersonagem,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: isRunning
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('CRIAR PERSONAGEM'),
                  );
                }),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T>? onChanged,
    required String Function(T) displayName,
    required IconData icon,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: context.textStyles.labelMedium),
                  DropdownButtonFormField<T>(
                    value: value,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    items: items.map((item) {
                      return DropdownMenuItem<T>(
                        value: item,
                        child: Text(displayName(item)),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumericField({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String hint,
    required int minValue,
    required int maxValue,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: context.textStyles.labelMedium),
                  Text(hint, style: context.textStyles.bodySmall),
                ],
              ),
            ),
            SizedBox(
              width: 120,
              child: TextFormField(
                initialValue: value.toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                onChanged: (text) {
                  final newValue = int.tryParse(text) ?? minValue;
                  final clampedValue = newValue.clamp(minValue, maxValue);
                  onChanged(clampedValue);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CharacterFormFieldsController {
  final FormFieldControl name = _createField();

  List<FormFieldControl> get fields => [name];

  static FormFieldControl _createField() {
    return (
      key: GlobalKey<FormFieldState>(),
      focus: FocusNode(),
      controller: TextEditingController(),
    );
  }

  void clear() {
    for (final field in fields) {
      field.controller.clear();
    }
  }

  void dispose() {
    for (final field in fields) {
      field.focus.dispose();
      field.controller.dispose();
    }
  }
}