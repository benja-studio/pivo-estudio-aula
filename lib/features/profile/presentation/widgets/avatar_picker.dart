import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aula/core/design_system/components/pressable_scale.dart';
import 'package:aula/core/design_system/components/spring_sheet.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/services/file_service.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';

class AvatarPicker extends ConsumerStatefulWidget {
  const AvatarPicker({
    super.key,
    this.initialRelativePath,
    required this.initials,
    this.onAvatarChanged,
    this.size = 100.0,
    this.editable = true,
  });

  final String? initialRelativePath;
  final String initials;
  final ValueChanged<String?>? onAvatarChanged;
  final double size;
  final bool editable;

  @override
  ConsumerState<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends ConsumerState<AvatarPicker> {
  File? _avatarFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadInitialFile();
  }

  @override
  void didUpdateWidget(covariant AvatarPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRelativePath != widget.initialRelativePath) {
      _loadInitialFile();
    }
  }

  Future<void> _loadInitialFile() async {
    if (widget.initialRelativePath != null) {
      final fileService = ref.read(fileServiceProvider);
      final file = await fileService.getAbsoluteFile(widget.initialRelativePath);
      if (mounted) {
        setState(() => _avatarFile = file);
      }
    } else {
      if (mounted) {
        setState(() => _avatarFile = null);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked == null) return;

      final fileService = ref.read(fileServiceProvider);
      final relativePath = await fileService.saveAvatar(File(picked.path));
      final resolved = await fileService.getAbsoluteFile(relativePath);

      if (mounted) {
        setState(() => _avatarFile = resolved);
        widget.onAvatarChanged?.call(relativePath);
        unawaited(AppHaptics.success());
      }
    } catch (_) {
      unawaited(AppHaptics.error());
    }
  }

  void _removeAvatar() {
    setState(() => _avatarFile = null);
    widget.onAvatarChanged?.call(null);
    AppHaptics.snapPoint();
  }

  void _showOptionsSheet() {
    if (!widget.editable) return;
    AppHaptics.selectionClick();

    SpringSheet.show(
      context: context,
      title: 'Foto de perfil',
      snapFractions: const [0.38],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_rounded),
            title: const Text('Elegir de la galería'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded),
            title: const Text('Tomar foto con la cámara'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          if (_avatarFile != null)
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: const Text('Eliminar foto', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _removeAvatar();
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    Widget avatarContent;

    if (_avatarFile != null) {
      avatarContent = Image.file(
        _avatarFile!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
      );
    } else {
      avatarContent = Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: isDark ? 0.22 : 0.12),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.initials.isNotEmpty ? widget.initials : 'A',
          style: TextStyle(
            fontSize: widget.size * 0.38,
            fontWeight: FontWeight.w700,
            color: primary,
          ),
        ),
      );
    }

    Widget avatarWidget = Stack(
      children: [
        ClipPath(
          clipper: ShapeBorderClipper(
            shape: AppRadius.continuousShape(widget.size * 0.26),
          ),
          child: avatarContent,
        ),
        if (widget.editable)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xs + 2),
              decoration: ShapeDecoration(
                color: primary,
                shape: AppRadius.continuousShape(AppRadius.sm),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );

    if (widget.editable) {
      return PressableScale(
        onTap: _showOptionsSheet,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}
