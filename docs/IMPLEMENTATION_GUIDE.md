# 📱 Bolide - Complete UI Implementation Guide

This comprehensive guide covers all remaining screens based on e-commerce best practices and modern mobile UX patterns.

---

## 📋 Table of Contents

### High Value Additions
1. [Order Detail Screen](#1-order-detail-screen)
2. [Search Results Screen](#2-search-results-screen)  
3. [Notifications Screen](#3-notifications-screen)
4. [Edit Profile Screen](#4-edit-profile-screen)
5. [Addresses Screen](#5-addresses-screen)

### Nice to Have
6. [Filter/Sort Modal](#6-filtersort-modal)
7. [Product Reviews Screen](#7-product-reviews-screen)
8. [Promo Codes Screen](#8-promo-codes-screen)
9. [Help/FAQ Detail Screen](#9-helpfaq-detail-screen)
10. [About Us Screen](#10-about-us-screen)
11. [Terms & Conditions Screen](#11-terms--conditions-screen)
12. [Privacy Policy Screen](#12-privacy-policy-screen)
13. [Settings Screen](#13-settings-screen)

---

## 🎯 High Value Additions

### 1. Order Detail Screen
**File**: `lib/screens/order_detail_screen.dart`

**Key Components**:

#### Order Timeline (Vertical)
```dart
// Status progression with connected dots
_TimelineStep(title: 'Commande confirmée', isCompleted: true)
_TimelineStep(title: 'Préparation en cours', isCompleted: true)
_TimelineStep(title: 'Expédiée', isActive: true)
_TimelineStep(title: 'Livraison prévue', isCompleted: false)
```

**Design Elements**:
- Large status badge at top (colored: Orange/Blue/Green/Red)
- Vertical timeline with dots and connecting lines
- Product list with images, quantities, prices
- Delivery information card
- Payment summary section
- Action buttons: Download invoice, Track package, Contact support, Reorder

**Best Practices**:
- Use filled circles for completed steps, empty for pending
- Show estimated delivery date prominently
- Allow invoice download and sharing
- Display tracking number if available

---

### 2. Search Results Screen
**File**: `lib/screens/search_results_screen.dart`

**Key Components**:

#### Sticky Search Bar
```dart
TextField(
  autofocus: true,
  decoration: InputDecoration(
    hintText: 'Rechercher des pièces...',
    prefixIcon: Icon(Icons.search),
    suffixIcon: Icon(Icons.clear),
  ),
)
```

#### Results Header
```dart
Row(
  children: [
    Text('${count} résultats pour "${query}"'),
    IconButton(icon: Icon(Icons.filter_list)),
    IconButton(icon: Icon(Icons.grid_view)),
  ],
)
```

**Features**:
- **Auto-complete suggestions** as user types
- **Recent searches** with chips (removable)
- **Quick filters** bar (horizontal scroll)
- **Sort options**: Relevance, Price ↑↓, Newest, Best sellers
- **View toggle**: Grid vs List
- **Empty state** with "No results" message and clear filters button

**Sort Options** (Bottom sheet):
- Pertinence (default)
- Prix croissant / décroissant
- Nouveautés
- Meilleures ventes
- Meilleures notes

---

### 3. Notifications Screen
**File**: `lib/screens/notifications_screen.dart`

**Key Components**:

#### Tabs/Filters
```dart
TabBar(tabs: [
  Tab(text: 'Tout'),
  Tab(text: 'Commandes'),
  Tab(text: 'Promotions'),
  Tab(text: 'Système'),
])
```

#### Notification Card
```dart
Container(
  color: notification.isRead ? Colors.white : Colors.blue[50],
  child: ListTile(
    leading: CircleAvatar(
      child: Icon(_getTypeIcon(notification.type)),
    ),
    title: Text(notification.title, 
      style: notification.isRead ? normal : bold),
    subtitle: Column(
      children: [
        Text(notification.message),
        Text(_formatTime(notification.timestamp)),
      ],
    ),
    trailing: PopupMenu(), // Mark read, Delete
  ),
)
```

**Notification Types**:
- 🟠 **Order** (Shopping bag icon, orange)
- 🔵 **Delivery** (Truck icon, blue)
- 🟢 **Promo** (Tag icon, green)
- ⚪ **System** (Info icon, grey)
- 🟣 **Payment** (Payment icon, purple)

**Features**:
- **Group by date**: "Aujourd'hui", "Hier", date
- **Swipe to delete** (Dismissible widget)
- **Mark all as read** button
- **Unread indicator** with blue background
- **Empty state** with bell icon

---

### 4. Edit Profile Screen
**File**: `lib/screens/edit_profile_screen.dart`

**Key Components**:

#### Profile Photo
```dart
Stack(
  children: [
    CircleAvatar(radius: 60, backgroundImage: NetworkImage(url)),
    Positioned(
      bottom: 0, right: 0,
      child: CircleAvatar(
        backgroundColor: Colors.black,
        child: IconButton(
          icon: Icon(Icons.camera_alt, color: Colors.white),
          onPressed: () => showPhotoOptions(),
        ),
      ),
    ),
  ],
)
```

**Photo Options** (Bottom sheet):
- 📷 Prendre une photo
- 🖼️ Choisir depuis la galerie
- ❌ Supprimer la photo

#### Form Fields
- **Nom complet** (text, icon: person)
- **Email** (email validation, icon: email)
- **Téléphone** (disabled/read-only, icon: phone)
- **Adresse** (multiline, icon: location_on)
- **Date de naissance** (date picker, icon: cake)

#### Change Password Section
```dart
Card(
  child: ListTile(
    leading: Icon(Icons.lock),
    title: Text('Modifier le mot de passe'),
    trailing: Icon(Icons.chevron_right),
    onTap: () => showChangePasswordDialog(),
  ),
)
```

**Password Dialog**:
- Current password field
- New password field
- Confirm password field
- Validation: min 8 characters, match confirmation

**Actions**:
- ⚫ **Save** button (black, full width)
- ⚪ **Cancel** button (outlined)
- Success snackbar on save

---

### 5. Addresses Screen
**File**: `lib/screens/addresses_screen.dart`

**Key Components**:

#### Address Card
```dart
Container(
  border: address.isDefault ? thick_black : thin_grey,
  child: Column(
    children: [
      if (address.isDefault)
        Container(
          color: Colors.black,
          child: Row([
            Icon(Icons.check_circle, color: white),
            Text('Adresse par défaut', color: white),
          ]),
        ),
      
      // Address details
      Text(address.label), // "Domicile", "Bureau"
      Text(address.fullName),
      Text(address.phoneNumber),
      Text(address.fullAddress),
      Text('${address.city}, ${address.country}'),
      
      // Actions
      Row([
        TextButton.icon(icon: Edit, label: 'Modifier'),
        TextButton.icon(icon: Delete, label: 'Supprimer', color: red),
        if (!isDefault) TextButton('Définir par défaut'),
      ]),
    ],
  ),
)
```

**Features**:
- **Default badge** (black header with checkmark)
- **Label field**: Domicile, Bureau, Autre
- **Edit/Delete/Set Default** actions
- **FAB**: "+ Nouvelle adresse"
- **Delete confirmation** dialog
- **Empty state**: "Aucune adresse enregistrée"

#### Address Form Fields
- Libellé (Label)
- Nom complet
- Numéro de téléphone
- Adresse ligne 1 & 2
- Ville & Code postal (side by side)
- Pays (dropdown)
- Switch: "Définir comme adresse par défaut"

---

## 🎨 Nice to Have Features

### 6. Filter/Sort Modal
**File**: `lib/widgets/filter_sort_modal.dart`

**Pattern**: Draggable bottom sheet with tabs

**Sort Tab** (Radio buttons):
- Pertinence, Prix ↑↓, Nouveautés, Bestsellers, Notes

**Filter Tab** (Expandable sections):
- **Prix**: Range slider (min/max inputs)
- **Catégories**: Checkboxes (Moteur, Freinage, etc.)
- **Marques**: Checkboxes (BMW, Mercedes, etc.)
- **Disponibilité**: Switch "En stock uniquement"
- **État**: Radio (Neuf / Occasion / Reconditionné)

**Footer**:
- "Effacer tout" button (left)
- "Appliquer (X)" button (right, shows count)

---

### 7. Product Reviews Screen
**File**: `lib/screens/product_reviews_screen.dart`

**Components**:
- **Rating Summary**: Average stars, total reviews, bar chart
- **Filter**: All / 5★ / 4★ / 3★ / 2★ / 1★
- **Sort**: Most recent / Most helpful
- **Review Card**: Avatar, name, stars, date, text, images
- **Helpful buttons**: 👍 (X) / 👎 (Y)
- **Write Review** FAB

**Write Review Form**:
- Star rating picker (tap to select 1-5)
- Title input
- Review text (multiline)
- Photo upload (optional, up to 5 images)
- Submit button

---

### 8. Promo Codes Screen
**File**: `lib/screens/promo_codes_screen.dart`

**Components**:
- **Active Codes Section**
  - Card with code, discount %, expiry date
  - "Copier" button
  - "Appliquer" button
  
- **Expired Codes** (greyed out, collapsed)

**Promo Card Design**:
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(orange to red),
    borderRadius: 12,
  ),
  child: Row(
    children: [
      Column([
        Text('BOLID10', style: bold_white_24),
        Text('-10% sur tout', style: white),
        Text('Expire le 31 Oct', style: white_small),
      ]),
      DashedDivider(vertical),
      Column([
        IconButton(icon: Copy),
        Text('Copier', style: white_small),
      ]),
    ],
  ),
)
```

**Features**:
- Copy code to clipboard
- Apply directly to cart
- Show terms & conditions
- Push notification for new codes

---

### 9. Help/FAQ Detail Screen
**File**: `lib/screens/faq_detail_screen.dart`

**Structure**:
- **Search bar** at top
- **Categories** (expandable)
  - 📦 Commandes & Livraison
  - 💳 Paiement
  - 🔄 Retours & Remboursements
  - 👤 Compte
  - 🛡️ Sécurité

**FAQ Item**:
```dart
ExpansionTile(
  title: Text('Comment suivre ma commande ?'),
  children: [
    Padding(
      padding: EdgeInsets.all(16),
      child: Text('Pour suivre votre commande...'),
    ),
  ],
)
```

**Features**:
- Search within FAQs
- "Was this helpful?" Yes/No buttons
- "Contact support" button if not helpful
- Jump to related articles

---

### 10. About Us Screen
**File**: `lib/screens/about_us_screen.dart`

**Sections**:
1. **Hero**: Logo, company name, tagline
2. **Mission**: Company purpose and values
3. **Team**: Founder/team photos (optional)
4. **Stats**: Years in business, products, customers, cities
5. **Contact**: Email, phone, social media links
6. **Version**: App version, build number

**Design**: Scrollable single page with sections

---

### 11. Terms & Conditions Screen
**File**: `lib/screens/terms_conditions_screen.dart`

**Structure**:
```dart
Scaffold(
  appBar: AppBar(title: Text('Conditions Générales')),
  body: SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        _Section(title: '1. Acceptation des conditions'),
        _Section(title: '2. Utilisation du service'),
        _Section(title: '3. Compte utilisateur'),
        _Section(title: '4. Commandes et paiements'),
        _Section(title: '5. Livraison'),
        _Section(title: '6. Retours et remboursements'),
        _Section(title: '7. Garanties'),
        _Section(title: '8. Responsabilités'),
        _Section(title: '9. Propriété intellectuelle'),
        _Section(title: '10. Modifications'),
        
        Text('Dernière mise à jour: 30 Oct 2025'),
      ],
    ),
  ),
)
```

**Features**:
- Numbered sections
- Bold headings
- Regular text paragraphs
- Last updated date
- Print/share button (optional)

---

### 12. Privacy Policy Screen
**File**: `lib/screens/privacy_policy_screen.dart`

**Required Sections** (Legal compliance):
1. **Données collectées**: Name, email, phone, address, payment info
2. **Utilisation des données**: Orders, communications, analytics
3. **Partage des données**: Payment processors, delivery partners
4. **Cookies et tracking**: Analytics tools used
5. **Sécurité**: How data is protected
6. **Droits des utilisateurs**: Access, modify, delete data
7. **Conservation**: How long data is kept
8. **Contact**: Data protection officer email

**Design**: Similar to Terms & Conditions
- Scrollable text
- Clear headings
- Easy to read
- Last updated date

---

### 13. Settings Screen
**File**: `lib/screens/settings_screen.dart`

**Layout Pattern**: Grouped list (iOS style)

**Sections**:

#### 1. Compte
```dart
ListTile(title: 'Modifier le profil', trailing: chevron)
ListTile(title: 'Adresses de livraison', trailing: chevron)
ListTile(title: 'Changer le mot de passe', trailing: chevron)
```

#### 2. Notifications
```dart
SwitchListTile(title: 'Notifications push', value: true)
SwitchListTile(title: 'Commandes', value: true)
SwitchListTile(title: 'Promotions', value: false)
SwitchListTile(title: 'Nouveautés', value: true)
```

#### 3. Préférences
```dart
ListTile(title: 'Langue', subtitle: 'Français', trailing: chevron)
ListTile(title: 'Devise', subtitle: 'FCFA', trailing: chevron)
SwitchListTile(title: 'Mode sombre', value: false)
```

#### 4. Aide & Support
```dart
ListTile(title: 'Centre d\'aide', trailing: chevron)
ListTile(title: 'Nous contacter', trailing: chevron)
ListTile(title: 'Signaler un problème', trailing: chevron)
```

#### 5. Légal
```dart
ListTile(title: 'Conditions générales', trailing: chevron)
ListTile(title: 'Politique de confidentialité', trailing: chevron)
ListTile(title: 'À propos', trailing: chevron)
```

#### 6. Compte (Bottom section)
```dart
ListTile(
  title: Text('Se déconnecter', style: red),
  leading: Icon(Icons.logout, color: red),
)
ListTile(
  title: Text('Supprimer mon compte', style: red),
  leading: Icon(Icons.delete_forever, color: red),
)
```

**Footer**:
```dart
Center(
  child: Column([
    Text('Version 1.0.0'),
    Text('© 2025 Bolide'),
  ]),
)
```

---

## 🎨 UI/UX Best Practices Summary

### General Principles
1. **Consistency**: Use same colors, fonts, spacing across all screens
2. **Feedback**: Show loading states, success/error messages
3. **Navigation**: Clear back buttons, breadcrumbs where needed
4. **Accessibility**: Proper contrast, tap targets min 44x44
5. **Performance**: Lazy loading, image caching, pagination

### Color Scheme (Bolide)
- **Primary**: Black (#000000)
- **Accent**: Orange (#FF9500)
- **Background**: White (#FFFFFF)
- **Surface**: Grey[50] (#F5F5F5)
- **Error**: Red (#F44336)
- **Success**: Green (#4CAF50)

### Typography
- **Headings**: Bold, 18-24px
- **Body**: Regular, 14-16px
- **Captions**: 12px, grey
- **Buttons**: Bold, 16px

### Spacing
- **Screen padding**: 16px
- **Card margins**: 8-16px
- **Element spacing**: 8-24px
- **Section spacing**: 32px

### Components
- **Buttons**: Rounded corners (8px), min height 48px
- **Cards**: Rounded (12px), subtle shadow or border
- **Inputs**: Grey background, rounded (8px), icon prefix
- **Images**: Rounded (8-12px), loading placeholder

---

## 📁 File Structure

```
lib/
├── screens/
│   ├── order_detail_screen.dart
│   ├── search_results_screen.dart
│   ├── notifications_screen.dart
│   ├── edit_profile_screen.dart
│   ├── addresses_screen.dart
│   ├── address_form_screen.dart
│   ├── product_reviews_screen.dart
│   ├── write_review_screen.dart
│   ├── promo_codes_screen.dart
│   ├── faq_detail_screen.dart
│   ├── about_us_screen.dart
│   ├── terms_conditions_screen.dart
│   ├── privacy_policy_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── filter_sort_modal.dart
│   ├── timeline_step.dart
│   ├── notification_card.dart
│   ├── address_card.dart
│   ├── review_card.dart
│   └── promo_card.dart
└── models/
    ├── order.dart
    ├── notification.dart
    ├── address.dart
    ├── review.dart
    └── promo_code.dart
```

---

## 🚀 Implementation Priority

### Phase 1 (Critical)
1. ✅ Order Detail Screen - Complete order flow
2. ✅ Search Results Screen - Core shopping experience
3. ✅ Addresses Screen - Checkout requirement

### Phase 2 (High Value)
4. ✅ Edit Profile Screen - User account management
5. ✅ Notifications Screen - User engagement
6. ✅ Filter/Sort Modal - Improve search UX

### Phase 3 (Polish)
7. ✅ Settings Screen - App preferences
8. ✅ Product Reviews Screen - Social proof
9. ✅ Promo Codes Screen - Marketing

### Phase 4 (Legal/Info)
10. ✅ Terms & Conditions - Legal requirement
11. ✅ Privacy Policy - Legal requirement
12. ✅ About Us - Brand identity
13. ✅ FAQ Detail - Support

---

## 📚 Resources & References

### Research Sources
- **Smashing Magazine**: Search, Sort & Filter patterns
- **Medium (Thierry Meier)**: Mobile filtering best practices
- **Halo Lab**: Profile page design guidelines
- **Setproduct**: Settings UI patterns
- **Baymard Institute**: E-commerce UX research
- **Mobbin**: Mobile app design inspiration
- **Material Design**: Component guidelines
- **iOS Human Interface**: Design principles

### Key Takeaways
1. **Search**: Auto-complete, recent searches, clear filters
2. **Filter**: Slide-over preferred over full screen
3. **Sort**: Simple radio buttons, 5-7 options max
4. **Notifications**: Group by date, swipe actions, unread indicator
5. **Profile**: Photo upload with options, inline validation
6. **Addresses**: Default badge, edit/delete actions, validation
7. **Settings**: Grouped lists, switches for toggles
8. **Reviews**: Star ratings, helpful votes, images

---

## ✅ Next Steps

1. **Create screen files** following this guide
2. **Implement navigation** from existing screens
3. **Add to routing** in main.dart
4. **Test on devices** (iOS & Android)
5. **Iterate based on feedback**

---

**Version**: 1.0  
**Last Updated**: 30 Oct 2025  
**Author**: Bolide Development Team
