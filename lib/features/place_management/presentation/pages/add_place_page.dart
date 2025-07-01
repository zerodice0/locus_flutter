import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locus_flutter/features/common/presentation/widgets/custom_app_bar.dart';
import 'package:locus_flutter/features/common/presentation/widgets/loading_overlay.dart'
    as loading;
import 'package:locus_flutter/features/place_management/presentation/providers/place_form_provider.dart';
import 'package:locus_flutter/features/place_management/presentation/providers/place_provider.dart';
import 'package:locus_flutter/features/place_management/presentation/widgets/category_selector.dart';
import 'package:locus_flutter/features/place_management/presentation/widgets/operating_hours_picker.dart';
import 'package:locus_flutter/features/place_management/presentation/widgets/event_periods_picker.dart';
import 'package:locus_flutter/features/place_management/presentation/widgets/duplicate_warning_dialog.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';
import 'package:locus_flutter/core/services/map/map_service.dart';

class AddPlacePage extends ConsumerStatefulWidget {
  const AddPlacePage({super.key});

  @override
  ConsumerState<AddPlacePage> createState() => _AddPlacePageState();
}

class _AddPlacePageState extends ConsumerState<AddPlacePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(placeFormProvider);
    final formNotifier = ref.read(placeFormProvider.notifier);

    return Scaffold(
      appBar: const CustomAppBar(title: '장소 추가'),
      body: loading.LoadingOverlay(
        isLoading: _isLoading,
        loadingMessage: '장소를 저장하는 중...',
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Location selector
                _buildLocationSelector(formState, formNotifier),
                const SizedBox(height: 24),

                // Name field
                _buildNameField(formState, formNotifier),
                const SizedBox(height: 16),

                // Description field
                _buildDescriptionField(formNotifier),
                const SizedBox(height: 16),

                // Address field
                _buildAddressField(formNotifier),
                const SizedBox(height: 24),

                // Category selector
                CategorySelector(
                  selectedCategoryId:
                      formState.categoryId.isEmpty
                          ? null
                          : formState.categoryId,
                  onCategorySelected: formNotifier.updateCategoryId,
                  errorText: formNotifier.getError('categoryId'),
                ),
                const SizedBox(height: 24),

                // Notes field
                _buildNotesField(formNotifier),
                const SizedBox(height: 24),

                // Operating hours
                OperatingHoursPicker(
                  operatingHours: formState.operatingHours,
                  onChanged: formNotifier.updateOperatingHours,
                ),
                const SizedBox(height: 24),

                // Event periods
                EventPeriodsPicker(
                  eventPeriods: formState.eventPeriods,
                  onChanged: formNotifier.updateEventPeriods,
                ),
                const SizedBox(height: 32),

                // Save button
                _buildSaveButton(formState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSelector(
    PlaceFormState formState,
    PlaceFormNotifier formNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '위치',
          style: AppTheme.labelLarge.copyWith(
            color: formNotifier.hasError('location') ? AppTheme.errorRed : null,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  formNotifier.hasError('location')
                      ? AppTheme.errorRed
                      : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (formState.location != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '위도: ${formState.location!.latitude.toStringAsFixed(6)}\n'
                        '경도: ${formState.location!.longitude.toStringAsFixed(6)}',
                        style: AppTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton.icon(
                onPressed: () => _selectLocation(formNotifier),
                icon: const Icon(Icons.map),
                label: Text(formState.location != null ? '위치 변경' : '지도에서 선택'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      formState.location != null
                          ? AppTheme.primaryBlue
                          : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
        if (formNotifier.hasError('location')) ...[
          const SizedBox(height: 4),
          Text(
            formNotifier.getError('location')!,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.errorRed),
          ),
        ],
      ],
    );
  }

  Widget _buildNameField(
    PlaceFormState formState,
    PlaceFormNotifier formNotifier,
  ) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: '장소 이름 *',
        hintText: '예: 카페 라임',
        errorText: formNotifier.getError('name'),
      ),
      maxLength: 100,
      onChanged: formNotifier.updateName,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '장소 이름을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField(PlaceFormNotifier formNotifier) {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: '설명',
        hintText: '장소에 대한 간단한 설명을 입력하세요',
      ),
      maxLines: 3,
      maxLength: 500,
      onChanged: formNotifier.updateDescription,
    );
  }

  Widget _buildAddressField(PlaceFormNotifier formNotifier) {
    return TextFormField(
      controller: _addressController,
      decoration: const InputDecoration(
        labelText: '주소',
        hintText: '주소 또는 위치 정보',
        prefixIcon: Icon(Icons.location_on),
      ),
      onChanged: formNotifier.updateAddress,
    );
  }

  Widget _buildNotesField(PlaceFormNotifier formNotifier) {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: '메모',
        hintText: '개인적인 메모나 특이사항을 입력하세요',
      ),
      maxLines: 3,
      maxLength: 1000,
      onChanged: formNotifier.updateNotes,
    );
  }

  Widget _buildSaveButton(PlaceFormState formState) {
    return ElevatedButton(
      onPressed: formState.isValid ? _savePlace : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        '장소 저장',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _selectLocation(PlaceFormNotifier formNotifier) async {
    final selectedLocation = await context.push<UniversalLatLng>(
      '/real-map-picker',
    );
    if (selectedLocation != null) {
      formNotifier.updateLocation(selectedLocation);
    }
  }

  Future<void> _savePlace() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final formNotifier = ref.read(placeFormProvider.notifier);
      final formState = ref.read(placeFormProvider);

      // 중복 검사 수행
      final validateNewPlaceUseCase = ref.read(validateNewPlaceUseCaseProvider);
      final validationResult = await validateNewPlaceUseCase.call(
        placeName: formState.name,
        latitude: formState.location!.latitude,
        longitude: formState.location!.longitude,
      );

      setState(() => _isLoading = false);

      // 중복 장소가 있는 경우 경고 다이얼로그 표시
      if (validationResult.hasDuplicates) {
        if (!mounted) return;
        final shouldProceed = await showDialog<bool>(
          context: context,
          builder:
              (context) => DuplicateWarningDialog(
                newPlace: formNotifier.createPlace(),
                duplicateCandiates: validationResult.duplicatePlaces,
                onProceed: () => Navigator.of(context).pop(true),
                onCancel: () => Navigator.of(context).pop(false),
              ),
        );

        if (shouldProceed != true) {
          return; // 사용자가 취소한 경우
        }
      }

      setState(() => _isLoading = true);

      // 실제 저장 수행
      final addPlaceUseCase = ref.read(addPlaceUseCaseProvider);
      final placesNotifier = ref.read(placesProvider.notifier);

      final place = formNotifier.createPlace();
      await addPlaceUseCase(place);

      // 장소 목록 새로고침
      await placesNotifier.refreshPlaces();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('장소가 성공적으로 저장되었습니다'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
