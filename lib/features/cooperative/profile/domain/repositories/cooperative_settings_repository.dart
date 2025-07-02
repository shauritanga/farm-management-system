import '../entities/cooperative_settings.dart';

/// Repository interface for cooperative settings
abstract class CooperativeSettingsRepository {
  /// Get cooperative settings by cooperative ID
  Future<CooperativeSettings?> getCooperativeSettings(String cooperativeId);
  
  /// Update cooperative settings
  Future<void> updateCooperativeSettings(String cooperativeId, CooperativeSettings settings);
  
  /// Create default cooperative settings
  Future<void> createDefaultSettings(String cooperativeId, String cooperativeName);
  
  /// Check if cooperative settings exist
  Future<bool> settingsExist(String cooperativeId);
  
  /// Delete cooperative settings
  Future<void> deleteCooperativeSettings(String cooperativeId);
  
  /// Stream cooperative settings for real-time updates
  Stream<CooperativeSettings?> watchCooperativeSettings(String cooperativeId);
}
