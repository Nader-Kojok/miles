# ✅ Ajout du Champ Email au Profil

## Contexte

L'email a été ajouté comme champ **optionnel** dans le profil utilisateur pour permettre :
- L'envoi de newsletters
- Les promotions et offres spéciales
- La communication marketing

**Important** : L'email n'est PAS utilisé pour l'authentification. La connexion se fait uniquement par numéro de téléphone.

---

## Modifications Effectuées

### 1. Base de Données ✅

Ajout du champ `email` à la table `profiles` :

```sql
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS email text;
```

**Structure de la table `profiles`** :
```sql
CREATE TABLE public.profiles (
  id uuid PRIMARY KEY,
  phone varchar(20),
  full_name text,
  email text,              -- ✅ NOUVEAU
  avatar_url text,
  created_at timestamptz,
  updated_at timestamptz
);
```

### 2. Modèle Profile ✅

**Fichier** : `lib/models/profile.dart`

```dart
class Profile {
  final String id;
  final String? phone;
  final String? fullName;
  final String? email;        // ✅ NOUVEAU
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    this.phone,
    this.fullName,
    this.email,              // ✅ NOUVEAU
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });
}
```

**Méthodes mises à jour** :
- ✅ `fromJson` - Lit l'email depuis la DB
- ✅ `toJson` - Écrit l'email dans la DB
- ✅ `copyWith` - Permet de copier avec un nouvel email

### 3. ProfileService ✅

**Fichier** : `lib/services/profile_service.dart`

```dart
Future<void> updateProfile({
  String? fullName,
  String? phone,
  String? email,    // ✅ NOUVEAU
  String? avatarUrl,
}) async {
  // ...
  if (email != null) updates['email'] = email;
  // ...
}
```

### 4. EditProfileScreen ✅

**Fichier** : `lib/screens/edit_profile_screen.dart`

#### Chargement de l'email
```dart
Future<void> _loadProfile() async {
  final profile = await _profileService.getUserProfile();
  if (profile != null && mounted) {
    setState(() {
      _nameController.text = profile.fullName ?? '';
      _phoneController.text = profile.phone ?? '';
      _emailController.text = profile.email ?? '';  // ✅ NOUVEAU
      _photoUrl = profile.avatarUrl;
    });
  }
}
```

#### Sauvegarde de l'email
```dart
Future<void> _saveProfile() async {
  await _profileService.updateProfile(
    fullName: _nameController.text.trim(),
    phone: _phoneController.text.trim(),
    email: _emailController.text.trim().isEmpty 
        ? null 
        : _emailController.text.trim(),  // ✅ NOUVEAU
  );
}
```

#### Interface utilisateur
```dart
_buildTextField(
  controller: _emailController,
  label: 'Email (optionnel)',           // ✅ Indique que c'est optionnel
  icon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    // Validation uniquement si l'email est renseigné
    if (value != null && value.isNotEmpty && !value.contains('@')) {
      return 'Email invalide';
    }
    return null;
  },
),
Padding(
  padding: const EdgeInsets.only(left: 16, top: 4),
  child: Text(
    'Pour recevoir nos newsletters et promotions',  // ✅ Explication
    style: TextStyle(
      fontSize: 12,
      color: Colors.grey[600],
      fontStyle: FontStyle.italic,
    ),
  ),
),
```

---

## Caractéristiques

### ✅ Champ Optionnel
- L'utilisateur peut laisser le champ vide
- Aucune erreur si non renseigné
- Peut être ajouté/modifié à tout moment

### ✅ Validation
- Vérifie la présence du `@` si l'email est renseigné
- N'empêche pas la sauvegarde si vide
- Message d'erreur clair : "Email invalide"

### ✅ Sauvegarde Intelligente
```dart
email: _emailController.text.trim().isEmpty 
    ? null                              // Sauvegarde NULL si vide
    : _emailController.text.trim(),     // Sauvegarde l'email si renseigné
```

### ✅ Interface Claire
- Label : "Email (optionnel)"
- Texte d'aide : "Pour recevoir nos newsletters et promotions"
- Icône email pour la reconnaissance visuelle

---

## Utilisation

### Pour l'Utilisateur

1. **Accéder au profil** :
   - Profil → Modifier le profil

2. **Renseigner l'email** (optionnel) :
   - Saisir une adresse email valide
   - Ou laisser vide

3. **Enregistrer** :
   - Cliquer sur "Enregistrer les modifications"
   - L'email est sauvegardé dans la base de données

### Pour le Marketing

L'email peut maintenant être utilisé pour :

```sql
-- Récupérer tous les emails pour newsletter
SELECT email, full_name 
FROM profiles 
WHERE email IS NOT NULL;

-- Compter les utilisateurs avec email
SELECT COUNT(*) 
FROM profiles 
WHERE email IS NOT NULL;

-- Statistiques
SELECT 
  COUNT(*) as total_users,
  COUNT(email) as users_with_email,
  ROUND(COUNT(email) * 100.0 / COUNT(*), 2) as email_percentage
FROM profiles;
```

---

## Différence avec l'Authentification

### ❌ Email Auth (Désactivé)
```dart
// NE PAS UTILISER
await supabase.auth.signInWithPassword(
  email: 'user@example.com',
  password: 'password',
);
```

### ✅ Phone Auth (Actif)
```dart
// MÉTHODE DE CONNEXION
await supabase.auth.signInWithOtp(
  phone: '+221771234567',
);
```

### ✅ Email dans Profile (Actif)
```dart
// POUR MARKETING UNIQUEMENT
await profileService.updateProfile(
  email: 'user@example.com',  // Optionnel, pour newsletters
);
```

---

## Tests

### Test 1 : Sauvegarde avec email
1. Modifier le profil
2. Renseigner : `test@example.com`
3. Enregistrer
4. ✅ Vérifier dans Supabase :
```sql
SELECT email FROM profiles WHERE id = 'user-id';
-- Résultat : test@example.com
```

### Test 2 : Sauvegarde sans email
1. Modifier le profil
2. Laisser l'email vide
3. Enregistrer
4. ✅ Vérifier dans Supabase :
```sql
SELECT email FROM profiles WHERE id = 'user-id';
-- Résultat : NULL
```

### Test 3 : Validation email invalide
1. Modifier le profil
2. Renseigner : `invalidemail`
3. Enregistrer
4. ✅ Message d'erreur : "Email invalide"

### Test 4 : Modification de l'email
1. Modifier le profil
2. Changer l'email de `old@example.com` à `new@example.com`
3. Enregistrer
4. ✅ L'email est mis à jour

---

## Politiques RLS

Les politiques existantes s'appliquent automatiquement au champ email :

```sql
-- Les utilisateurs peuvent voir leur propre email
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Les utilisateurs peuvent mettre à jour leur email
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
```

---

## Évolutions Futures

### 1. Vérification d'Email
```dart
// Envoyer un email de vérification
Future<void> sendVerificationEmail(String email) async {
  // Utiliser un service comme SendGrid, Mailgun, etc.
}
```

### 2. Préférences de Communication
```sql
-- Ajouter des préférences
ALTER TABLE profiles 
ADD COLUMN newsletter_subscribed boolean DEFAULT true,
ADD COLUMN promo_subscribed boolean DEFAULT true;
```

### 3. Double Opt-in
```dart
// Confirmer l'abonnement
Future<void> confirmEmailSubscription(String token) async {
  // Vérifier le token et activer l'abonnement
}
```

---

## Checklist

### Configuration ✅
- [x] Champ `email` ajouté à la table `profiles`
- [x] Modèle `Profile` mis à jour
- [x] `ProfileService.updateProfile` mis à jour
- [x] Politiques RLS appliquées automatiquement

### Interface ✅
- [x] Champ email dans `edit_profile_screen.dart`
- [x] Validation d'email
- [x] Texte d'aide affiché
- [x] Champ marqué comme optionnel

### Tests 🔄
- [ ] Sauvegarde avec email
- [ ] Sauvegarde sans email
- [ ] Validation email invalide
- [ ] Modification d'email existant
- [ ] Affichage dans profile_screen

---

**Date d'ajout** : 30 octobre 2025  
**Statut** : ✅ Implémenté et prêt pour les tests  
**Type** : Champ optionnel pour marketing  
**Authentification** : Téléphone uniquement
