/// Service for managing app images and illustrations
class ImageService {
  // Private constructor to prevent instantiation
  ImageService._();

  /// High-quality agricultural illustrations for onboarding
  static const Map<String, String> onboardingImages = {
    // Farm Management - Modern farmer using technology
    'farm_management':
        'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=800&h=600&fit=crop&crop=center&auto=format&q=80',

    // Cooperative Management - Group of farmers working together
    'cooperative_management':
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&h=600&fit=crop&crop=center&auto=format&q=80',

    // Agricultural Journey - Successful harvest/farming scene
    'agricultural_journey':
        'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=800&h=600&fit=crop&crop=center&auto=format&q=80',
  };

  /// Alternative high-quality agricultural images
  static const Map<String, List<String>> alternativeImages = {
    'farm_management': [
      'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&h=600&fit=crop&crop=center&auto=format&q=80', // Wheat field
      'https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?w=800&h=600&fit=crop&crop=center&auto=format&q=80', // Modern farming
      'https://images.unsplash.com/photo-1560493676-04071c5f467b?w=800&h=600&fit=crop&crop=center&auto=format&q=80', // Farmer with tablet
    ],
    'cooperative_management': [
      'https://images.unsplash.com/photo-1581833971358-2c8b550f87b3?w=800&h=600&fit=crop&crop=center&auto=format&q=80', // Farmers meeting
      'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800&h=600&fit=crop&crop=center&auto=format&q=80', // Agricultural community
      'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=800&h=600&fit=crop&crop=center&auto=format&q=80', // Farmers collaboration
    ],
    'agricultural_journey': [
      'https://images.unsplash.com/photo-1500595046743-cd271d694d30?w=800&h=600&fit=crop&crop=center&auto=format&q=80', // Harvest time
      'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=800&h=600&fit=crop&crop=center&auto=format&q=80', // Agricultural success
      'https://images.unsplash.com/photo-1592982736920-1b0d8b3c8c7c?w=800&h=600&fit=crop&crop=center&auto=format&q=80', // Modern agriculture
    ],
  };

  /// Get primary onboarding image URL
  static String getOnboardingImage(String key) {
    return onboardingImages[key] ?? onboardingImages['farm_management']!;
  }

  /// Get alternative images for fallback
  static List<String> getAlternativeImages(String key) {
    return alternativeImages[key] ?? alternativeImages['farm_management']!;
  }

  /// Get optimized image URL with specific dimensions
  static String getOptimizedImageUrl(
    String baseUrl, {
    int width = 800,
    int height = 600,
    String fit = 'crop',
    String crop = 'center',
    String format = 'auto',
    int quality = 80,
  }) {
    // For Unsplash images, add optimization parameters
    if (baseUrl.contains('unsplash.com')) {
      final uri = Uri.parse(baseUrl);
      final params = Map<String, String>.from(uri.queryParameters);

      params['w'] = width.toString();
      params['h'] = height.toString();
      params['fit'] = fit;
      params['crop'] = crop;
      params['auto'] = format;
      params['q'] = quality.toString();

      return uri.replace(queryParameters: params).toString();
    }

    return baseUrl;
  }

  /// Preload images for better performance
  static Future<void> preloadOnboardingImages() async {
    // This would be implemented to preload critical images
    // For now, we rely on CachedNetworkImage's caching
  }
}
