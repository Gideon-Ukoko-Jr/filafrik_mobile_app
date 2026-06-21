import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import 'typography.dart';

class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    required this.label,
    this.value,
    this.hint,
    this.focused = false,
    this.obscure = false,
    this.height = 48,
  });

  final String label;
  final String? value;
  final String? hint;
  final bool focused;
  final bool obscure;
  final double height;

  @override
  Widget build(BuildContext context) {
    final text = value ?? hint ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        const SizedBox(height: 6),
        Container(
          height: height,
          alignment: height > 52 ? Alignment.topLeft : Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focused
                  ? AppColors.gold
                  : AppColors.gold.withValues(alpha: .18),
            ),
          ),
          child: Text(
            obscure && value == null ? '' : text,
            style: TextStyle(
              color: value == null ? AppColors.dim : AppColors.text,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.textFieldKey,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final Key? textFieldKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        const SizedBox(height: 6),
        TextField(
          key: textFieldKey,
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: obscure ? 1 : maxLines,
          minLines: maxLines > 1 ? maxLines : null,
          style: const TextStyle(color: AppColors.text, fontSize: 13),
          cursorColor: AppColors.gold,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.dim, fontSize: 13),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.gold.withValues(alpha: .18),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gold),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB05050)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB05050)),
            ),
          ),
        ),
      ],
    );
  }
}

class ChoiceChipView extends StatelessWidget {
  const ChoiceChipView(this.label, {super.key, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.gold.withValues(alpha: .13)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? AppColors.gold
              : AppColors.gold.withValues(alpha: .18),
        ),
      ),
      child: Text(
        selected ? '✓ $label' : label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: selected ? AppColors.gold : AppColors.muted,
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class StageTile extends StatelessWidget {
  const StageTile(this.label, {super.key, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.gold.withValues(alpha: .12)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? AppColors.gold
              : AppColors.gold.withValues(alpha: .18),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.gold : AppColors.muted,
                fontSize: 13,
              ),
            ),
          ),
          if (selected)
            const Text(
              '✓',
              style: TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}
