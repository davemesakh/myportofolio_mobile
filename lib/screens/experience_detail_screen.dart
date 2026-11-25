import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class ExperienceDetailScreen extends StatefulWidget {
  const ExperienceDetailScreen({required this.experience, super.key});

  final Experience experience;

  @override
  State<ExperienceDetailScreen> createState() => _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState extends State<ExperienceDetailScreen> {
  late Experience _experience;
  bool _isDeleting = false;
  bool _wasModified = false;

  @override
  void initState() {
    super.initState();
    _experience = widget.experience;
  }

  Future<void> _editExperience() async {
    final ok = await ensureLoggedIn(context);
    if (!ok || !mounted) return;

    final updated = await Navigator.push<Experience>(
      context,
      MaterialPageRoute(
        builder: (context) => ExperienceFormPage(experience: _experience),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        _experience = updated;
        _wasModified = true;
      });
    }
  }

  Future<void> _deleteExperience() async {
    final id = _experience.id;
    if (id == null || id.isEmpty) return;

    final ok = await ensureLoggedIn(context);
    if (!ok || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Experience'),
          content: Text(
            'Are you sure you want to delete "${_experience.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    final token = context.read<AuthState>().token;
    if (token == null) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await context.read<ApiClient>().deleteExperience(id, token: token);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Deleted "${_experience.title}".')),
        );
      Navigator.pop(context, true);
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
                'Failed to delete experience (HTTP ${e.statusCode})',
              ),
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Widget _buildDetailSection(
    BuildContext context, {
    required String label,
    required String value,
    bool selectable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          if (selectable) SelectableText(value) else Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = context.read<ApiClient>().baseUrl;
    final resolvedLogo = _experience.resolvedLogoUrl(baseUrl);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _wasModified);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _experience.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            if (_experience.id != null && _experience.id!.isNotEmpty) ...[
              IconButton(
                tooltip: 'Edit experience',
                onPressed: _isDeleting ? null : _editExperience,
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                tooltip: 'Delete experience',
                onPressed: _isDeleting ? null : _deleteExperience,
                icon: _isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.delete_outline),
              ),
            ],
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (resolvedLogo.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    resolvedLogo,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 140,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image_outlined, size: 40),
                          SizedBox(height: 8),
                          Text('Failed to load logo image'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                _experience.title,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.work_outline, size: 18),
                    label: Text(_experience.categoryLabel),
                  ),
                  if (_experience.isCurrent == true)
                    const Chip(
                      avatar: Icon(Icons.check_circle_outline, size: 18),
                      label: Text('Ongoing'),
                    ),
                  Chip(
                    avatar: const Icon(Icons.star_outline, size: 18),
                    label: Text('${_experience.starCount} stars'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailSection(
                context,
                label: 'Organization',
                value: _experience.organization.isEmpty
                    ? '-'
                    : _experience.organization,
              ),
              _buildDetailSection(
                context,
                label: 'Period',
                value: _experience.periodLabel,
              ),
              _buildDetailSection(
                context,
                label: 'Description',
                value: _experience.description,
              ),
              if (_experience.logoStaticPath.isNotEmpty)
                _buildDetailSection(
                  context,
                  label: 'Logo Source',
                  value: _experience.logoStaticPath,
                  selectable: true,
                ),
              if (_experience.logoAlt.isNotEmpty)
                _buildDetailSection(
                  context,
                  label: 'Logo Alt Text',
                  value: _experience.logoAlt,
                ),
              _buildDetailSection(
                context,
                label: 'Display Order',
                value: '${_experience.displayOrder}',
              ),
              if (_experience.id != null && _experience.id!.isNotEmpty)
                _buildDetailSection(
                  context,
                  label: 'ID',
                  value: _experience.id!,
                  selectable: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
