# Profile vs Settings Reorganization

## Problem
The Profile and Settings (Paramètres) pages were confusing because they shared many similar elements, making it unclear which page served what purpose.

## Research & Best Practices

Based on UX research from leading design resources:

### Key Principle: Separation of Concerns

**Profile = USER Data (Personal)**
- Personal information that defines WHO you are
- User-generated content and activity
- Things that belong to the user specifically

**Settings = APP Configuration (Technical)**
- How the application behaves
- Preferences for app functionality
- System-level configurations

### Industry Standards

For e-commerce apps (like Bolide), the recommended structure is:

1. **Profile/Account Page** should contain:
   - Personal info (name, email, phone, avatar)
   - Addresses (delivery/shipping)
   - Orders and purchase history
   - Saved items/wishlists
   - User activity

2. **Settings Page** should contain:
   - Notifications preferences
   - Language & currency
   - Theme/appearance
   - Security settings
   - Help & support resources
   - Legal information

## Implementation

### Profile Screen (Profil)
**Visual Identity:** Person icon 👤

**Structure:**
```
├── MES INFORMATIONS (My Information)
│   ├── Modifier mon profil (Name, phone, email, photo)
│   ├── Mes adresses (Delivery addresses)
│   └── Mes commandes (Order history)
│
├── PARAMÈTRES DE L'APPLICATION (App Settings)
│   ├── Paramètres (Link to Settings screen)
│   ├── Aide et support (FAQ, Contact)
│   └── À propos (About, Legal)
│
└── Déconnexion (Logout button)
```

### Settings Screen (Paramètres)
**Visual Identity:** Gear icon ⚙️
**Banner:** "Configurez votre expérience d'application"

**Structure:**
```
├── NOTIFICATIONS
│   ├── Notifications push
│   ├── Commandes (Order updates)
│   ├── Promotions (Special offers)
│   └── Nouveautés (News and features)
│
├── PRÉFÉRENCES (Preferences)
│   ├── Langue (Language)
│   ├── Devise (Currency)
│   └── Mode sombre (Dark mode)
│
├── AIDE & SUPPORT
│   ├── Centre d'aide (FAQ)
│   ├── Nous contacter (Contact support)
│   └── Signaler un problème (Report issue)
│
├── LÉGAL
│   ├── Conditions générales (Terms)
│   ├── Politique de confidentialité (Privacy)
│   └── À propos (About)
│
└── ACTIONS DU COMPTE
    ├── Se déconnecter (Logout)
    └── Supprimer mon compte (Delete account)
```

## Visual Distinctions

### Profile Screen
- **Icon:** Person icon (👤)
- **Color scheme:** User-focused with avatar prominence
- **Layout:** User card at top with avatar
- **Sections:** Clearly labeled "MES INFORMATIONS" and "PARAMÈTRES DE L'APPLICATION"
- **Subtitles:** Descriptive subtitles for each menu item

### Settings Screen
- **Icon:** Gear icon (⚙️)
- **Info banner:** Blue banner explaining "Configure your app experience"
- **Color scheme:** Technical/systematic
- **Layout:** Organized by configuration categories
- **Sections:** Technical groupings (Notifications, Preferences, etc.)

## User Benefits

1. **Clear Mental Model**
   - Users know where to find personal data (Profile)
   - Users know where to configure app behavior (Settings)

2. **Reduced Cognitive Load**
   - No more confusion about which page to use
   - Distinct visual identities (person vs gear icon)
   - Clear section headers and descriptions

3. **Efficient Navigation**
   - Logical grouping of related items
   - Cross-links between pages where appropriate
   - Descriptive subtitles guide users

4. **Industry Compliance**
   - Follows patterns used by successful apps (Amazon, Airbnb, Booking.com)
   - Familiar to users from other e-commerce experiences

## Removed Items

- ❌ **Moyens de paiement** (Payment methods) - not needed for MVP
- ❌ **Favoris** (Favorites) - not implemented yet

## Technical Changes

### Files Modified
1. `lib/screens/profile_screen.dart`
   - Added section headers
   - Added subtitles to menu items
   - Reorganized menu structure
   - Added person icon to AppBar

2. `lib/screens/settings_screen.dart`
   - Removed duplicate "COMPTE" section
   - Added info banner at top
   - Connected to FAQ and About screens
   - Implemented proper logout flow
   - Added gear icon to AppBar

## References

- [Designing profile, account, and setting pages for better UX](https://medium.com/design-bootcamp/designing-profile-account-and-setting-pages-for-better-ux-345ef4ca1490)
- [App Settings UI Design: Usability Tips & Best Practices](https://www.setproduct.com/blog/settings-ui-design)
- Amazon, Airbnb, Booking.com app patterns
