import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locus_flutter/features/common/presentation/widgets/custom_app_bar.dart';
import 'package:locus_flutter/features/common/presentation/widgets/loading_widget.dart';
import 'package:locus_flutter/features/common/presentation/widgets/loading_overlay.dart' as loading;
import 'package:locus_flutter/features/common/presentation/widgets/error_widget.dart';
import 'package:locus_flutter/features/place_management/presentation/providers/place_form_provider.dart';
import 'package:locus_flutter/features/place_management/presentation/providers/place_provider.dart';
import 'package:locus_flutter/features/place_management/presentation/widgets/category_selector.dart';
import 'package:locus_flutter/features/place_management/presentation/widgets/operating_hours_picker.dart';
import 'package:locus_flutter/features/place_management/presentation/widgets/event_periods_picker.dart';
import 'package:locus_flutter/features/common/presentation/providers/location_provider.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';
import 'package:locus_flutter/core/services/map/map_service.dart';
import 'package:locus_flutter/features/place_management/domain/entities/place.dart';

class EditPlacePage extends ConsumerStatefulWidget {
  final String placeId;
  
  const EditPlacePage({
    super.key,
    required this.placeId,
  });

  @override
  ConsumerState<EditPlacePage> createState() => _EditPlacePageState();
}

class _EditPlacePageState extends ConsumerState<EditPlacePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isLoading = false;
  bool _isInitialized = false;
  Place? _originalPlace;

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
    final placesAsync = ref.watch(placesProvider);
    final formState = ref.watch(placeFormProvider);
    final formNotifier = ref.read(placeFormProvider.notifier);

    return Scaffold(
      appBar: CustomAppBar(
        title: '장소 편집',
        actions: [
          if (_originalPlace != null)
            TextButton(
              onPressed: () => _resetForm(formNotifier),
              child: const Text('초기화'),
            ),
        ],
      ),
      body: placesAsync.when(
        data: (places) {
          try {
            final place = places.firstWhere((p) => p.id == widget.placeId);
            
            // Initialize form with place data
            if (!_isInitialized) {
              _initializeForm(formNotifier, place);
            }
            
            return loading.LoadingOverlay(
              isLoading: _isLoading,
              loadingMessage: '장소를 수정하는 중...',
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info banner
                      _buildInfoBanner(),
                      const SizedBox(height: 24),
                      
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
                        selectedCategoryId: formState.categoryId.isEmpty ? null : formState.categoryId,
                        onCategorySelected: formNotifier.updateCategoryId,
                        errorText: formNotifier.getError('categoryId'),
                      ),
                      const SizedBox(height: 24),
                      
                      // Rating field
                      _buildRatingField(formState, formNotifier),
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
                      
                      // Action buttons
                      _buildActionButtons(formState),
                    ],
                  ),
                ),
              ),
            );
          } catch (e) {
            return CustomErrorWidget.generic(
              message: '해당 장소를 찾을 수 없습니다',
              onRetry: () => context.pop(),
            );
          }
        },
        loading: () => const LoadingWidget(message: '장소 정보를 불러오는 중...'),
        error: (error, stackTrace) => CustomErrorWidget.generic(
          message: '장소 정보를 불러올 수 없습니다',
          onRetry: () => ref.refresh(placesProvider),
        ),
      ),
    );
  }

  void _initializeForm(PlaceFormNotifier formNotifier, Place place) {
    _originalPlace = place;
    formNotifier.loadPlace(place);
    
    // Initialize text controllers
    _nameController.text = place.name;
    _descriptionController.text = place.description ?? '';
    _addressController.text = place.address ?? '';
    _notesController.text = place.notes ?? '';
    
    _isInitialized = true;
  }

  Widget _buildInfoBanner() {
    if (_originalPlace == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.primaryGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_originalPlace!.name} 편집',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                Text(
                  '등록일: ${_originalPlace!.createdAtFormatted}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelector(PlaceFormState formState, PlaceFormNotifier formNotifier) {
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
              color: formNotifier.hasError('location') 
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
                      color: AppTheme.primaryGreen,
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _selectLocation(formNotifier),
                      icon: const Icon(Icons.map),
                      label: const Text('위치 변경'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _resetLocation(formNotifier),
                    icon: const Icon(Icons.refresh),
                    label: const Text('원래 위치'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                    ),
                  ),
                ],
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

  Widget _buildNameField(PlaceFormState formState, PlaceFormNotifier formNotifier) {
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

  Widget _buildRatingField(PlaceFormState formState, PlaceFormNotifier formNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '평점',
          style: AppTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('평점 없음'),
                  const Spacer(),
                  Switch(
                    value: formState.rating != null,
                    onChanged: (hasRating) {
                      if (hasRating) {
                        formNotifier.updateRating(3.0);
                      } else {
                        formNotifier.updateRating(null);
                      }
                    },
                  ),
                ],
              ),
              if (formState.rating != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('평점: '),
                    Expanded(
                      child: Slider(
                        value: formState.rating!,
                        min: 1.0,
                        max: 5.0,
                        divisions: 8,
                        label: formState.rating!.toStringAsFixed(1),
                        onChanged: formNotifier.updateRating,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            formState.rating!.toStringAsFixed(1),
                            style: AppTheme.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
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

  Widget _buildActionButtons(PlaceFormState formState) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: formState.isValid ? _savePlace : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppTheme.primaryGreen,
          ),
          child: const Text(
            '변경사항 저장',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _showDiscardDialog(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: AppTheme.errorRed),
          ),
          child: Text(
            '취소',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.errorRed,
            ),
          ),
        ),
      ],
    );
  }

  void _resetLocation(PlaceFormNotifier formNotifier) {
    if (_originalPlace != null) {
      formNotifier.updateLocation(
        UniversalLatLng(_originalPlace!.latitude, _originalPlace!.longitude),
      );
    }
  }

  void _resetForm(PlaceFormNotifier formNotifier) {
    if (_originalPlace != null) {
      formNotifier.loadPlace(_originalPlace!);
      _nameController.text = _originalPlace!.name;
      _descriptionController.text = _originalPlace!.description ?? '';
      _addressController.text = _originalPlace!.address ?? '';
      _notesController.text = _originalPlace!.notes ?? '';
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('양식이 초기화되었습니다'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  Future<void> _selectLocation(PlaceFormNotifier formNotifier) async {
    final selectedLocation = await context.push<UniversalLatLng>('/real-map-picker');
    if (selectedLocation != null) {
      formNotifier.updateLocation(selectedLocation);
    }
  }

  Future<void> _savePlace() async {
    if (!_formKey.currentState!.validate() || _originalPlace == null) return;

    setState(() => _isLoading = true);

    try {
      final formNotifier = ref.read(placeFormProvider.notifier);
      final updatePlaceUseCase = ref.read(updatePlaceUseCaseProvider);
      final placesNotifier = ref.read(placesProvider.notifier);

      final updatedPlace = formNotifier.updatePlace(_originalPlace!);
      await updatePlaceUseCase(updatedPlace);
      
      // 장소 목록 새로고침
      await placesNotifier.refreshPlaces();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('장소가 성공적으로 수정되었습니다'),
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

  Future<void> _showDiscardDialog() async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('변경사항 취소'),
        content: const Text('편집을 취소하시겠습니까?\n변경사항이 저장되지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('계속 편집'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    if (shouldDiscard == true && mounted) {
      ref.read(placeFormProvider.notifier).reset();
      context.pop();
    }
  }
}