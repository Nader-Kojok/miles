import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../models/address.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  // Récupérer le profil de l'utilisateur
  Future<Profile?> getUserProfile() async {
    if (_userId == null) {
      return null;
    }

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', _userId!)
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      print('Erreur lors de la récupération du profil: $e');
      return null;
    }
  }

  // Mettre à jour le profil
  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? email,
    String? address,
    DateTime? birthDate,
    String? avatarUrl,
  }) async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour modifier votre profil');
    }

    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (email != null) updates['email'] = email;
      if (address != null) updates['address'] = address;
      if (birthDate != null) updates['birth_date'] = birthDate.toIso8601String().split('T')[0];
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _client
          .from('profiles')
          .update(updates)
          .eq('id', _userId!);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  // Récupérer toutes les adresses de l'utilisateur
  Future<List<Address>> getAddresses() async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour accéder à vos adresses');
    }

    try {
      final response = await _client
          .from('addresses')
          .select()
          .eq('user_id', _userId!)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Address.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des adresses: $e');
    }
  }

  // Récupérer l'adresse par défaut
  Future<Address?> getDefaultAddress() async {
    if (_userId == null) {
      return null;
    }

    try {
      final response = await _client
          .from('addresses')
          .select()
          .eq('user_id', _userId!)
          .eq('is_default', true)
          .maybeSingle();

      if (response == null) return null;
      return Address.fromJson(response);
    } catch (e) {
      print('Erreur lors de la récupération de l\'adresse par défaut: $e');
      return null;
    }
  }

  // Ajouter une nouvelle adresse
  Future<Address> addAddress({
    required String label,
    required String fullName,
    required String phone,
    required String addressLine1,
    String? addressLine2,
    required String city,
    String? postalCode,
    String country = 'CI',
    bool isDefault = false,
  }) async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour ajouter une adresse');
    }

    try {
      final addressData = {
        'user_id': _userId,
        'label': label,
        'full_name': fullName,
        'phone': phone,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'city': city,
        'postal_code': postalCode,
        'country': country,
        'is_default': isDefault,
      };

      final response = await _client
          .from('addresses')
          .insert(addressData)
          .select()
          .single();

      return Address.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de l\'adresse: $e');
    }
  }

  // Mettre à jour une adresse
  Future<void> updateAddress(String addressId, {
    String? label,
    String? fullName,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? postalCode,
    String? country,
    bool? isDefault,
  }) async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour modifier vos adresses');
    }

    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (label != null) updates['label'] = label;
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (addressLine1 != null) updates['address_line1'] = addressLine1;
      if (addressLine2 != null) updates['address_line2'] = addressLine2;
      if (city != null) updates['city'] = city;
      if (postalCode != null) updates['postal_code'] = postalCode;
      if (country != null) updates['country'] = country;
      if (isDefault != null) updates['is_default'] = isDefault;

      await _client
          .from('addresses')
          .update(updates)
          .eq('id', addressId)
          .eq('user_id', _userId!);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'adresse: $e');
    }
  }

  // Supprimer une adresse
  Future<void> deleteAddress(String addressId) async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour gérer vos adresses');
    }

    try {
      await _client
          .from('addresses')
          .delete()
          .eq('id', addressId)
          .eq('user_id', _userId!);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'adresse: $e');
    }
  }

  // Définir une adresse comme adresse par défaut
  Future<void> setDefaultAddress(String addressId) async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour gérer vos adresses');
    }

    try {
      // Le trigger de la base de données s'occupe de mettre les autres à false
      await _client
          .from('addresses')
          .update({'is_default': true, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', addressId)
          .eq('user_id', _userId!);
    } catch (e) {
      throw Exception('Erreur lors de la définition de l\'adresse par défaut: $e');
    }
  }

  // Uploader une photo de profil
  Future<String> uploadAvatar(String filePath, Uint8List fileBytes) async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour modifier votre photo de profil');
    }

    try {
      final fileName = 'avatar-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$_userId/$fileName';

      await _client.storage
          .from('profiles')
          .uploadBinary(
            path,
            fileBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      final publicUrl = _client.storage
          .from('profiles')
          .getPublicUrl(path);

      // Mettre à jour le profil avec la nouvelle URL
      await updateProfile(avatarUrl: publicUrl);

      return publicUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'avatar: $e');
    }
  }

  // Supprimer l'avatar
  Future<void> deleteAvatar() async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour modifier votre photo de profil');
    }

    try {
      final profile = await getUserProfile();
      if (profile?.avatarUrl != null) {
        // Extraire le chemin du fichier depuis l'URL
        final url = profile!.avatarUrl!;
        // Le chemin est maintenant userId/filename
        if (url.contains('$_userId/')) {
          final path = url.split('/object/public/profiles/').last;
          await _client.storage
              .from('profiles')
              .remove([path]);
        }
      }

      await updateProfile(avatarUrl: null);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'avatar: $e');
    }
  }

  // Stream du profil en temps réel
  Stream<Profile?> watchUserProfile() {
    if (_userId == null) {
      return Stream.value(null);
    }

    return _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', _userId!)
        .map((data) {
          if (data.isEmpty) return null;
          return Profile.fromJson(data.first);
        });
  }
}
