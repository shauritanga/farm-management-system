import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cooperative_settings.dart';
import '../../domain/entities/cooperative_settings_extended.dart';
import '../../domain/entities/cooperative_settings_final.dart';
import '../../domain/repositories/cooperative_settings_repository.dart';
import '../models/cooperative_settings_model.dart';

/// Implementation of CooperativeSettingsRepository using Firestore
class CooperativeSettingsRepositoryImpl implements CooperativeSettingsRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'cooperativeSettings';

  CooperativeSettingsRepositoryImpl(this._firestore);

  @override
  Future<CooperativeSettings?> getCooperativeSettings(String cooperativeId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(cooperativeId).get();
      
      if (!doc.exists) {
        return null;
      }
      
      return CooperativeSettingsModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get cooperative settings: $e');
    }
  }

  @override
  Future<void> updateCooperativeSettings(String cooperativeId, CooperativeSettings settings) async {
    try {
      final model = CooperativeSettingsModel.fromEntity(settings);
      await _firestore.collection(_collection).doc(cooperativeId).set(
        model.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to update cooperative settings: $e');
    }
  }

  @override
  Future<void> createDefaultSettings(String cooperativeId, String cooperativeName) async {
    try {
      final defaultSettings = CooperativeSettings(
        basicInfo: BasicInfo(
          name: cooperativeName,
          registrationNumber: '',
          establishedDate: DateTime.now().toIso8601String().split('T')[0],
          legalStatus: 'Primary Cooperative Society',
          website: '',
          description: '',
          logoUrl: '',
        ),
        contactDetails: ContactDetails.defaultDetails(),
        businessSettings: BusinessSettings.defaultSettings(),
        operationalSettings: OperationalSettings.defaultSettings(),
        notificationSettings: NotificationSettings.defaultSettings(),
        securitySettings: SecuritySettings.defaultSettings(),
        integrationSettings: IntegrationSettings.defaultSettings(),
      );

      final model = CooperativeSettingsModel.fromEntity(defaultSettings);
      await _firestore.collection(_collection).doc(cooperativeId).set(model.toMap());
    } catch (e) {
      throw Exception('Failed to create default settings: $e');
    }
  }

  @override
  Future<bool> settingsExist(String cooperativeId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(cooperativeId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteCooperativeSettings(String cooperativeId) async {
    try {
      await _firestore.collection(_collection).doc(cooperativeId).delete();
    } catch (e) {
      throw Exception('Failed to delete cooperative settings: $e');
    }
  }

  @override
  Stream<CooperativeSettings?> watchCooperativeSettings(String cooperativeId) {
    return _firestore
        .collection(_collection)
        .doc(cooperativeId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return null;
      }
      return CooperativeSettingsModel.fromFirestore(doc);
    });
  }
}

/// Provider for CooperativeSettingsRepository
final cooperativeSettingsRepositoryProvider = Provider<CooperativeSettingsRepository>((ref) {
  return CooperativeSettingsRepositoryImpl(FirebaseFirestore.instance);
});

/// Provider for getting cooperative settings by ID
final cooperativeSettingsProvider = FutureProvider.family<CooperativeSettings?, String>((ref, cooperativeId) async {
  if (cooperativeId.isEmpty) return null;
  
  final repository = ref.read(cooperativeSettingsRepositoryProvider);
  return await repository.getCooperativeSettings(cooperativeId);
});

/// Provider for watching cooperative settings in real-time
final cooperativeSettingsStreamProvider = StreamProvider.family<CooperativeSettings?, String>((ref, cooperativeId) {
  if (cooperativeId.isEmpty) {
    return Stream.value(null);
  }
  
  final repository = ref.read(cooperativeSettingsRepositoryProvider);
  return repository.watchCooperativeSettings(cooperativeId);
});
