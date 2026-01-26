import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/enums/category_type.dart';
import '../../data/repositories/category_repository.dart';
import 'input_field.dart';
import 'primary_button.dart';

class CategoryBottomSheet extends StatefulWidget {
  final String? selectedCategory;
  final Function(String categoryId, String categoryName) onSelect;

  const CategoryBottomSheet({
    super.key,
    this.selectedCategory,
    required this.onSelect,
  });

  static Future<void> show(
    BuildContext context, {
    String? selectedCategory,
    required Function(String categoryId, String categoryName) onSelect,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryBottomSheet(
        selectedCategory: selectedCategory,
        onSelect: onSelect,
      ),
    );
  }

  @override
  State<CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<CategoryBottomSheet> {
  bool _showCustomInput = false;
  final _customNameController = TextEditingController();

  @override
  void dispose() {
    _customNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = CategoryRepository.instance.getAllCategories();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Select Category',
              style: AppTypography.h2,
            ),
          ),

          if (_showCustomInput) ...[
            // Custom category input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  InputField(
                    controller: _customNameController,
                    label: 'Category Name',
                    hint: 'Enter custom category name',
                    prefixIcon: Icons.add_rounded,
                    autofocus: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _showCustomInput = false;
                              _customNameController.clear();
                            });
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Add',
                          height: 48,
                          onPressed: _addCustomCategory,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            // Category grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: categories.length + 1, // +1 for add custom
                itemBuilder: (context, index) {
                  if (index == categories.length) {
                    // Add custom button
                    return _buildAddCustomButton();
                  }

                  final category = categories[index];
                  final isSelected =
                      widget.selectedCategory == category['id'] ||
                          widget.selectedCategory == category['name'];

                  return _buildCategoryCard(
                    id: category['id'] as String,
                    name: category['name'] as String,
                    emoji: category['emoji'] as String,
                    backgroundColor: category['backgroundColor'] as Color,
                    isSelected: isSelected,
                  );
                },
              ),
            ),
          ],

          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String id,
    required String name,
    required String emoji,
    required Color backgroundColor,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        widget.onSelect(id, name);
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : backgroundColor,
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: AppTypography.caption.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCustomButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showCustomInput = true;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSoft,
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(
            color: AppColors.border,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_rounded,
              size: 28,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Add Custom',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _addCustomCategory() {
    final name = _customNameController.text.trim();
    if (name.isEmpty) return;

    widget.onSelect('custom', name);
    Navigator.pop(context);
  }
}
