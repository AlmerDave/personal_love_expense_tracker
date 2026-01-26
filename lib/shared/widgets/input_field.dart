import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

class InputField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  const InputField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onTap,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          readOnly: readOnly,
          autofocus: autofocus,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
          style: AppTypography.input,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.inputHint,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: AppColors.textMuted,
                    size: 20,
                  )
                : null,
            prefix: prefix,
            suffix: suffix,
            filled: true,
            fillColor: AppColors.bgCard,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.mediumRadius,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.mediumRadius,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.mediumRadius,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.mediumRadius,
              borderSide: const BorderSide(color: AppColors.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.mediumRadius,
              borderSide: const BorderSide(color: AppColors.danger, width: 2),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }
}
