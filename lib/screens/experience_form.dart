import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({this.experience, super.key});

  /// When provided, the form edits the existing experience via `PATCH`.
  final Experience? experience;

  bool get isEditing => experience?.id != null;

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _organizationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _logoSourceController;
  late final TextEditingController _logoAltController;
  late final TextEditingController _startController;
  late final TextEditingController _endController;

  String _category = 'full-time';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.experience;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _organizationController = TextEditingController(
      text: existing?.organization ?? '',
    );
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    _logoSourceController = TextEditingController(
      text: existing?.logoStaticPath ?? '',
    );
    _logoAltController = TextEditingController(text: existing?.logoAlt ?? '');

    if (existing != null) {
      if (Experience.categoryLabels.containsKey(existing.category)) {
        _category = existing.category;
      }
      if (existing.startYear != null) {
        _startDate = DateTime(existing.startYear!, existing.startMonth ?? 1);
      }
      _isCurrent = existing.isCurrent ?? false;
      if (!_isCurrent && existing.endYear != null) {
        _endDate = DateTime(existing.endYear!, existing.endMonth ?? 1);
      }
    }

    _startController = TextEditingController(
      text: _startDate == null ? '' : _formatDate(_startDate!),
    );
    _endController = TextEditingController(
      text: _endDate == null ? '' : _formatDate(_endDate!),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _organizationController.dispose();
    _descriptionController.dispose();
    _logoSourceController.dispose();
    _logoAltController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _startController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _endController.text = _formatDate(picked);
      });
    }
  }

  bool _isValidLogoSource(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return true;
    if (trimmed.contains(RegExp(r'\s'))) return false;

    final uri = Uri.tryParse(trimmed);
    if (uri != null && (uri.hasScheme || uri.host.isNotEmpty)) {
      return uri.scheme == 'https' && uri.host.isNotEmpty;
    }

    // Also allow relative static paths matching Django's validator.
    if (trimmed.startsWith('/') ||
        trimmed.startsWith(r'\') ||
        trimmed.contains(r'\') ||
        trimmed.contains(':') ||
        trimmed.contains('?') ||
        trimmed.contains('#') ||
        trimmed.contains('%')) {
      return false;
    }
    final segments = trimmed.split('/');
    return !segments.any((s) => s.isEmpty || s == '.' || s == '..');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ensureLoggedIn(context);
    if (!ok || !mounted) return;

    final token = context.read<AuthState>().token;
    if (token == null) return;

    final payload = Experience(
      id: widget.experience?.id,
      title: _titleController.text.trim(),
      organization: _organizationController.text.trim(),
      category: _category,
      description: _descriptionController.text.trim(),
      logoStaticPath: _logoSourceController.text.trim(),
      logoAlt: _logoAltController.text.trim(),
      startYear: _startDate?.year,
      startMonth: _startDate?.month,
      endYear: _isCurrent ? null : _endDate?.year,
      endMonth: _isCurrent ? null : _endDate?.month,
      isCurrent: _isCurrent,
      displayOrder: widget.experience?.displayOrder ?? 0,
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      final apiClient = context.read<ApiClient>();
      final saved = widget.isEditing
          ? await apiClient.updateExperience(
              widget.experience!.id!,
              payload,
              token: token,
            )
          : await apiClient.createExperience(payload, token: token);

      if (!mounted) return;

      final action = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              widget.isEditing
                  ? 'Pengalaman berhasil diperbarui!'
                  : 'Pengalaman berhasil ditambahkan!',
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Judul: ${saved.title}'),
                  if (saved.organization.isNotEmpty)
                    Text('Organisasi: ${saved.organization}'),
                  Text('Kategori: ${saved.categoryLabel}'),
                  Text('Periode: ${saved.periodLabel}'),
                  Text('Deskripsi: ${saved.description}'),
                  if (saved.logoStaticPath.isNotEmpty)
                    Text('Logo: ${saved.logoStaticPath}'),
                ],
              ),
            ),
            actions: [
              if (!widget.isEditing)
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, 'add_another'),
                  child: const Text('Tambah Lagi'),
                ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, 'view_list'),
                child: Text(widget.isEditing ? 'OK' : 'Lihat Daftar'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      if (widget.isEditing) {
        Navigator.pop(context, saved);
        return;
      }

      if (action == 'add_another') {
        _resetForm();
      } else if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ExperienceListScreen()),
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        await context.read<AuthState>().logout();
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please log in again.'),
            ),
          );
        await ensureLoggedIn(context);
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Failed to save experience (HTTP ${e.statusCode}): ${e.message}',
              ),
            ),
          );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _resetForm() {
    setState(() {
      _titleController.clear();
      _organizationController.clear();
      _descriptionController.clear();
      _logoSourceController.clear();
      _logoAltController.clear();
      _startController.clear();
      _endController.clear();
      _category = 'full-time';
      _startDate = null;
      _endDate = null;
      _isCurrent = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            widget.isEditing ? 'Edit Experience' : 'Add Experience Form',
          ),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: widget.isEditing ? null : const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Title ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Backend Developer Intern',
                    labelText: 'Judul / Posisi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul tidak boleh kosong!';
                    }
                    if (value.trim().length > 255) {
                      return 'Judul maksimal 255 karakter!';
                    }
                    return null;
                  },
                ),
              ),
              // === Organization ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _organizationController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Tokopedia',
                    labelText: 'Organisasi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Organisasi tidak boleh kosong!';
                    }
                    if (value.trim().length > 255) {
                      return 'Organisasi maksimal 255 karakter!';
                    }
                    return null;
                  },
                ),
              ),
              // === Category ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  initialValue: _category,
                  items: Experience.categoryLabels.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _category = newValue;
                      });
                    }
                  },
                ),
              ),
              // === Start Date ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _startController,
                  readOnly: true,
                  onTap: _pickStartDate,
                  decoration: InputDecoration(
                    hintText: 'Pilih tanggal mulai',
                    labelText: 'Tanggal Mulai',
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (_startDate == null) {
                      return 'Tanggal mulai wajib dipilih!';
                    }
                    return null;
                  },
                ),
              ),
              // === Is Current ===
              CheckboxListTile(
                title: const Text('Masih berlangsung'),
                controlAffinity: ListTileControlAffinity.leading,
                value: _isCurrent,
                onChanged: (bool? value) {
                  setState(() {
                    _isCurrent = value ?? false;
                    if (_isCurrent) {
                      _endDate = null;
                      _endController.clear();
                    }
                  });
                },
              ),
              // === End Date ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _endController,
                  readOnly: true,
                  enabled: !_isCurrent,
                  onTap: _pickEndDate,
                  decoration: InputDecoration(
                    hintText: 'Pilih tanggal selesai',
                    labelText: 'Tanggal Selesai',
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (_isCurrent) return null;
                    if (_endDate == null) {
                      return "Tanggal selesai wajib dipilih (atau centang 'Masih berlangsung')!";
                    }
                    if (_startDate != null && _endDate!.isBefore(_startDate!)) {
                      return 'Tanggal selesai tidak boleh sebelum tanggal mulai!';
                    }
                    return null;
                  },
                ),
              ),
              // === Description ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Ceritakan tanggung jawab dan pencapaianmu',
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Deskripsi tidak boleh kosong!';
                    }
                    return null;
                  },
                ),
              ),
              // === Logo URL / Static Path ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _logoSourceController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    hintText: 'https://contoh.com/logo.png (opsional)',
                    labelText: 'URL Logo (HTTPS) / Static Path',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) return null;
                    if (!_isValidLogoSource(value)) {
                      return 'Gunakan URL https:// yang valid atau path static relatif';
                    }
                    return null;
                  },
                ),
              ),
              // === Logo Alt Text ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _logoAltController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Logo Tokopedia (opsional)',
                    labelText: 'Alt Text Logo (Opsional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value != null && value.trim().length > 255) {
                      return 'Alt text maksimal 255 karakter!';
                    }
                    return null;
                  },
                ),
              ),
              // === Save Button ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.indigo),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(widget.isEditing ? 'Update' : 'Save'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
