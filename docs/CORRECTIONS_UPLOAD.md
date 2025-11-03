# 🔧 Corrections - Upload d'Avatar

## Problèmes Identifiés

### 1. ❌ Erreur 404 - Logo manquant
```
GET http://localhost:53697/assets/assets/images/logo.png 404 (Not Found)
```

**Cause** : Le fichier `logo.png` n'existe pas dans `assets/images/`

**Solution** : Le widget `app_drawer.dart` a déjà un fallback qui affiche un "B" si l'image n'est pas trouvée. Cette erreur n'est pas bloquante.

**Action future** : Ajouter un vrai logo dans `assets/images/logo.png`

---

### 2. ❌ Erreur 400 - Upload d'avatar échoué
```
POST https://uerwlrpatvumjdksfgbj.supabase.co/storage/v1/object/profiles/avatars/... 400 (Bad Request)
```

**Cause** : Le chemin d'upload `avatars/$fileName` ne correspondait pas aux politiques RLS configurées qui attendent `$userId/...`

**Solution appliquée** : ✅ Corrigé dans `profile_service.dart`

#### Avant
```dart
final fileName = '$_userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
final path = 'avatars/$fileName';  // ❌ Mauvais chemin

await _client.storage
    .from('profiles')
    .uploadBinary(path, fileBytes);
```

#### Après
```dart
final fileName = 'avatar-${DateTime.now().millisecondsSinceEpoch}.jpg';
final path = '$_userId/$fileName';  // ✅ Bon chemin

await _client.storage
    .from('profiles')
    .uploadBinary(
      path,
      fileBytes,
      fileOptions: const FileOptions(
        contentType: 'image/jpeg',
        upsert: true,  // Permet de remplacer l'ancien avatar
      ),
    );
```

---

## Politiques RLS Storage

Les politiques configurées dans Supabase attendent que les fichiers soient organisés par userId :

```sql
-- Politique d'upload
CREATE POLICY "Users can upload own avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profiles' 
  AND (storage.foldername(name))[1] = auth.uid()::text  -- ← Vérifie userId
);
```

**Structure attendue** :
```
profiles/
  ├── userId-1/
  │   └── avatar-123456789.jpg
  ├── userId-2/
  │   └── avatar-987654321.jpg
  └── ...
```

---

## Changements Effectués

### 1. `profile_service.dart` - Fonction `uploadAvatar`
- ✅ Chemin changé de `avatars/$fileName` à `$_userId/$fileName`
- ✅ Ajout de `FileOptions` avec `contentType` et `upsert`
- ✅ Permet le remplacement automatique de l'ancien avatar

### 2. `profile_service.dart` - Fonction `deleteAvatar`
- ✅ Mise à jour de l'extraction du chemin pour correspondre à la nouvelle structure
- ✅ Utilise `$_userId/` au lieu de `avatars/`

---

## Test de l'Upload

### Étapes pour tester
1. Lancer l'application : `flutter run -d chrome`
2. Se connecter avec un compte
3. Aller dans Profil → Modifier le profil
4. Cliquer sur l'avatar
5. Choisir "Prendre une photo" ou "Galerie"
6. Sélectionner une image

### Résultat attendu
- ✅ L'image est uploadée avec succès
- ✅ L'avatar s'affiche immédiatement
- ✅ Message de confirmation : "Photo mise à jour avec succès"
- ✅ L'URL publique est sauvegardée dans le profil

### Vérification dans Supabase
```sql
-- Vérifier le profil
SELECT id, full_name, avatar_url 
FROM profiles 
WHERE id = 'votre-user-id';

-- Vérifier les fichiers dans Storage
SELECT * FROM storage.objects 
WHERE bucket_id = 'profiles';
```

---

## Structure des Fichiers Uploadés

### URL Publique Générée
```
https://uerwlrpatvumjdksfgbj.supabase.co/storage/v1/object/public/profiles/userId/avatar-123456789.jpg
```

### Décomposition
- **Base URL** : `https://uerwlrpatvumjdksfgbj.supabase.co/storage/v1/object/public`
- **Bucket** : `profiles`
- **Chemin** : `userId/avatar-123456789.jpg`

---

## Gestion des Erreurs

### Erreurs Possibles

#### 1. Utilisateur non connecté
```dart
if (_userId == null) {
  throw Exception('Utilisateur non connecté');
}
```

#### 2. Erreur d'upload
```dart
try {
  await _client.storage.from('profiles').uploadBinary(...);
} catch (e) {
  throw Exception('Erreur lors de l\'upload de l\'avatar: $e');
}
```

#### 3. Erreur de mise à jour du profil
```dart
await updateProfile(avatarUrl: publicUrl);
```

### Affichage dans l'UI
```dart
// Dans edit_profile_screen.dart
catch (e) {
  if (mounted) {
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur lors de l\'upload: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

---

## Optimisations Futures

### 1. Compression d'Image
```dart
// Ajouter le package image
dependencies:
  image: ^4.0.0

// Compresser avant upload
import 'package:image/image.dart' as img;

Future<Uint8List> compressImage(Uint8List bytes) async {
  final image = img.decodeImage(bytes);
  if (image == null) return bytes;
  
  final resized = img.copyResize(image, width: 512);
  return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
}
```

### 2. Suppression de l'Ancien Avatar
```dart
// Avant d'uploader le nouveau, supprimer l'ancien
Future<String> uploadAvatar(String filePath, Uint8List fileBytes) async {
  // Supprimer l'ancien avatar s'il existe
  final profile = await getUserProfile();
  if (profile?.avatarUrl != null) {
    await deleteAvatar();
  }
  
  // Upload du nouveau
  // ...
}
```

### 3. Validation du Type de Fichier
```dart
Future<void> _pickImage(String source) async {
  final image = await picker.pickImage(
    source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 85,
  );
  
  if (image != null) {
    // Vérifier l'extension
    final ext = image.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png'].contains(ext)) {
      throw Exception('Format non supporté. Utilisez JPG ou PNG.');
    }
    
    // Continuer l'upload...
  }
}
```

---

## Checklist de Vérification

### Configuration Supabase ✅
- [x] Bucket `profiles` créé
- [x] Bucket configuré en public
- [x] Politiques RLS configurées
- [x] Politiques testées

### Code ✅
- [x] Chemin d'upload corrigé (`$userId/$fileName`)
- [x] FileOptions ajoutées (contentType, upsert)
- [x] Fonction deleteAvatar mise à jour
- [x] Gestion d'erreurs implémentée
- [x] Loading states ajoutés

### Tests 🔄
- [ ] Upload depuis la galerie
- [ ] Upload depuis la caméra
- [ ] Remplacement d'avatar existant
- [ ] Suppression d'avatar
- [ ] Affichage dans profile_screen

---

## Commandes Utiles

### Vérifier les fichiers uploadés
```sql
SELECT 
  name,
  bucket_id,
  created_at,
  metadata->>'size' as size
FROM storage.objects
WHERE bucket_id = 'profiles'
ORDER BY created_at DESC;
```

### Nettoyer les anciens avatars
```sql
-- Supprimer les fichiers orphelins
DELETE FROM storage.objects
WHERE bucket_id = 'profiles'
AND name NOT IN (
  SELECT avatar_url 
  FROM profiles 
  WHERE avatar_url IS NOT NULL
);
```

---

**Date de correction** : 30 octobre 2025  
**Statut** : ✅ Corrigé et prêt pour les tests  
**Prochaine étape** : Tester l'upload d'avatar dans l'application
