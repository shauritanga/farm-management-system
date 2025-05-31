import '../../domain/entities/onboarding_page.dart';

class OnboardingPageModel extends OnboardingPageEntity {
  const OnboardingPageModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imagePath,
    super.buttonText,
    required super.order,
  });

  factory OnboardingPageModel.fromMap(Map<String, dynamic> map) {
    return OnboardingPageModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['imagePath'] ?? '',
      buttonText: map['buttonText'],
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'buttonText': buttonText,
      'order': order,
    };
  }

  factory OnboardingPageModel.fromEntity(OnboardingPageEntity entity) {
    return OnboardingPageModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      imagePath: entity.imagePath,
      buttonText: entity.buttonText,
      order: entity.order,
    );
  }

  OnboardingPageEntity toEntity() {
    return OnboardingPageEntity(
      id: id,
      title: title,
      description: description,
      imagePath: imagePath,
      buttonText: buttonText,
      order: order,
    );
  }

  @override
  String toString() {
    return 'OnboardingPageModel(id: $id, title: $title, description: $description, imagePath: $imagePath, buttonText: $buttonText, order: $order)';
  }
}
