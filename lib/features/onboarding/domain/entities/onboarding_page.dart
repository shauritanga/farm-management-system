import 'package:equatable/equatable.dart';

class OnboardingPageEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final String? buttonText;
  final int order;

  const OnboardingPageEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    this.buttonText,
    required this.order,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    imagePath,
    buttonText,
    order,
  ];
}
