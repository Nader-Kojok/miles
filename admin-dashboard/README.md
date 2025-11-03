# 🚗 Bolide Admin Dashboard

Tableau de bord d'administration web pour gérer l'application mobile Bolide (marketplace de pièces détachées automobiles).

## 📋 Stack Technique

- **Framework**: Next.js 16 (App Router)
- **Language**: TypeScript
- **UI**: shadcn/ui + Tailwind CSS
- **Backend**: Supabase (PostgreSQL + Auth)
- **Date**: date-fns
- **Charts**: Recharts

## ✨ Fonctionnalités

### 🔐 Authentification
- Connexion sécurisée par email/mot de passe
- Sessions persistantes avec Supabase Auth
- Protection des routes avec middleware

### 📊 Tableau de bord
- Vue d'ensemble des statistiques clés
- Total des produits, commandes, utilisateurs
- Chiffre d'affaires total
- Commandes récentes

### 📦 Gestion des produits
- ✅ Liste complète des produits avec recherche et filtres
- ✅ Ajout de nouveaux produits
- ✅ Modification des produits existants
- ✅ Suppression de produits
- ✅ Gestion des images (URL)
- ✅ Statut (actif/inactif, en stock, en vedette)
- ✅ Prix, stock, SKU, marque
- ✅ Catégorisation des produits

### 🗂️ Gestion des catégories
- ✅ Liste des catégories
- ✅ Ordre d'affichage
- ✅ Suppression de catégories

### 🛒 Gestion des commandes
- ✅ Liste de toutes les commandes
- ✅ Informations client et montants
- ✅ Mise à jour du statut des commandes
- ✅ Suivi du paiement

## 🚀 Installation

### 1. Variables d'environnement

Le fichier `.env.local` est déjà configuré avec vos identifiants Supabase :

```bash
NEXT_PUBLIC_SUPABASE_URL=https://uerwlrpatvumjdksfgbj.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...
```

### 2. Installation des dépendances

```bash
cd admin-dashboard
npm install
```

### 3. Lancer le serveur de développement

```bash
npm run dev
```

Ouvrez [http://localhost:3000](http://localhost:3000) dans votre navigateur.

## 🔑 Première connexion

### Créer un compte admin

Vous devez créer un compte admin dans Supabase :

1. Allez sur [votre projet Supabase](https://supabase.com/dashboard/project/uerwlrpatvumjdksfgbj)
2. Cliquez sur **Authentication** > **Users**
3. Cliquez sur **Add user** > **Create new user**
4. Entrez un email et mot de passe
5. Confirmez la création

Ensuite, connectez-vous sur le dashboard avec ces identifiants.

## 📂 Structure du projet

```
admin-dashboard/
├── app/
│   ├── dashboard/
│   │   ├── page.tsx              # Dashboard principal
│   │   ├── layout.tsx            # Layout avec sidebar
│   │   ├── products/             # Gestion des produits
│   │   │   ├── page.tsx          # Liste des produits
│   │   │   ├── new/page.tsx      # Nouveau produit
│   │   │   ├── [id]/page.tsx     # Modifier produit
│   │   │   ├── product-form.tsx  # Formulaire produit
│   │   │   └── products-table.tsx
│   │   ├── orders/               # Gestion des commandes
│   │   │   ├── page.tsx
│   │   │   └── orders-table.tsx
│   │   └── categories/           # Gestion des catégories
│   │       ├── page.tsx
│   │       └── categories-table.tsx
│   └── login/
│       └── page.tsx              # Page de connexion
├── components/
│   ├── ui/                       # Composants shadcn/ui
│   └── sidebar.tsx               # Navigation latérale
├── lib/
│   ├── supabase/
│   │   ├── client.ts             # Client Supabase (browser)
│   │   └── server.ts             # Client Supabase (server)
│   ├── types/
│   │   └── database.ts           # Types TypeScript
│   └── utils.ts                  # Utilitaires
└── middleware.ts                 # Protection des routes

```

## 🎨 Personnalisation

### Changer les couleurs

Les couleurs sont définies dans `app/globals.css` et peuvent être modifiées via les variables CSS :

```css
:root {
  --primary: ...
  --secondary: ...
}
```

### Ajouter une nouvelle page

1. Créez un nouveau dossier dans `app/dashboard/`
2. Ajoutez un fichier `page.tsx`
3. Ajoutez la route dans `components/sidebar.tsx`

## 🔒 Sécurité

- Toutes les routes sont protégées par le middleware
- Les requêtes Supabase utilisent RLS (Row Level Security)
- Les sessions sont gérées côté serveur
- Les mots de passe sont hashés par Supabase Auth

## 📱 Compatibilité mobile

Le dashboard est entièrement responsive et fonctionne sur :
- 💻 Desktop
- 📱 Mobile
- 📱 Tablet

## 🚀 Déploiement

### Vercel (Recommandé)

1. Push votre code sur GitHub
2. Importez le projet sur [Vercel](https://vercel.com)
3. Ajoutez les variables d'environnement
4. Déployez !

### Netlify

```bash
npm run build
# Upload le dossier .next/ sur Netlify
```

## 🛠️ Développement futur

- [ ] Upload d'images via Supabase Storage
- [ ] Statistiques avancées avec graphiques
- [ ] Gestion des utilisateurs de l'app
- [ ] Système de notifications
- [ ] Export de données (CSV, Excel)
- [ ] Filtres et recherche avancés
- [ ] Gestion des codes promo
- [ ] Rapports de vente

## 📝 Notes

- Le dashboard partage la même base de données Supabase que l'application mobile Flutter
- Toutes les modifications sont synchronisées en temps réel
- Les produits créés ici apparaissent immédiatement dans l'app mobile

## 🆘 Support

Pour toute question ou problème :
1. Vérifiez que Supabase est accessible
2. Vérifiez les logs dans la console du navigateur
3. Vérifiez les variables d'environnement
