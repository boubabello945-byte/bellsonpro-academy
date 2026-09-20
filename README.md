# Bellsonpro-Academy

Plateforme de vente de ressources scientifiques (mathématiques, physique, chimie, sciences de
l'ingénieur, informatique scientifique, météorologie et climatologie) — cours, exercices corrigés,
livres numériques, fiches de révision, etc.

## ⚠️ Fichiers à mettre TOUS sur GitHub

Le site n'est plus un fichier unique : il a besoin de **deux fichiers de code** à la racine du
dépôt pour fonctionner correctement. N'en oubliez aucun :

| Fichier | Obligatoire ? | Rôle |
|---|---|---|
| `index.html` | ✅ Oui | Le site complet (pages, style, logique boutique/panier/admin) |
| `script.js` | ✅ Oui | Connexion à Supabase (base de données) — chargé par `index.html` |
| `supabase-schema.sql` | ⚠️ À exécuter dans Supabase, pas sur GitHub | Crée les tables de la base de données (à coller une fois dans le SQL Editor de Supabase, pas un fichier du site) |
| `README.md` | Optionnel | Ce document (aide-mémoire, n'affecte pas le site) |
| `CONTINUATION.md` | Optionnel | Historique du projet, pour reprendre le fil plus tard |

**Le plus important : `index.html` ET `script.js` doivent être déposés ensemble, à la racine du
dépôt (pas dans un sous-dossier).** Si `script.js` manque, le site s'affichera mais le bandeau de
connexion à la base de données ne s'affichera pas correctement.

## Héberger sur GitHub Pages (étapes complètes)

1. Créez un dépôt sur GitHub (public).
2. **Add file → Upload files**, et glissez EXACTEMENT ces fichiers : `index.html`, `script.js`
   (et si vous voulez, `README.md`, `CONTINUATION.md` — ils ne gênent rien).
3. **Commit changes**.
4. Dans le dépôt : **Settings → Pages**.
5. Source : **Deploy from a branch** → Branche `main` → Dossier `/ (root)` → **Save**.
6. Attendez 1 à 2 minutes. L'URL du site s'affiche en haut de cette page Settings → Pages, du
   type : `https://<votre-nom-utilisateur>.github.io/<nom-du-depot>/`

## État actuel du site (ce qui fonctionne vraiment)

- **Boutique complète** : 6 domaines scientifiques, fiches produit, panier, comptes clients.
- **Paiement réel manuel** : la page de paiement affiche votre numéro Orange Money
  (`+237 698 143 537`) et un bouton qui ouvre WhatsApp avec un message pré-rempli pour que le
  client vous envoie sa preuve de paiement. Vous validez ensuite la commande depuis
  **Administration → Commandes → Valider le paiement**, ce qui débloque le téléchargement pour
  le client.
- **Ajout de documents à vendre** : depuis **Administration → Produits → Ajouter un produit**,
  vous pouvez téléverser un PDF et une image de couverture.
- **Connexion à Supabase** : `script.js` connecte le site à une vraie base de données Supabase
  (tables créées via `supabase-schema.sql`). Pour l'instant cette connexion sert de fondation
  pour la suite (comptes partagés entre visiteurs, etc.) — elle n'est pas encore utilisée pour
  stocker les produits/commandes au quotidien : ceux-ci restent dans le `localStorage` du
  navigateur de chaque visiteur (voir limites ci-dessous).
- **Réseaux sociaux à jour** : Facebook, TikTok, YouTube, WhatsApp, e-mail — modifiables aussi
  depuis Administration → Réseaux sociaux, sans toucher au code.

## Accès administrateur

Page **Administration**, mot de passe par défaut : `admin123`.
⚠️ Pensez à le changer si le site devient public à grande échelle (actuellement stocké en clair
dans le navigateur, prévu pour une démo — pas pour une sécurité de production).

## Limites connues et prochaines étapes possibles

- Les produits, commandes et comptes sont actuellement stockés en `localStorage`, donc **propres
  à chaque navigateur** : un produit ajouté depuis votre téléphone n'apparaît pas automatiquement
  chez un visiteur qui ouvre le site sur son propre appareil.
- Les gros fichiers PDF peuvent dépasser la capacité de stockage du navigateur (quelques Mo au
  total) — privilégier des PDF légers pour l'instant.
- Le paiement est **manuel et vérifié par vous** (pas de paiement automatique type CinetPay pour
  l'instant) — volontairement choisi pour être simple à démarrer sans compte tiers à configurer.
- Prochaine étape logique si le site grandit : faire lire/écrire les produits et commandes
  directement dans Supabase (au lieu du `localStorage`) pour que tout le monde voie la même
  boutique, la même base de commandes, partout.

## Contenu du fichier .sql

`supabase-schema.sql` n'est **pas un fichier du site** — il ne va pas sur GitHub. C'est un script
à coller une seule fois dans **Supabase → SQL Editor → New query → Run**, pour créer les tables
de la base de données. Il peut être ré-exécuté sans risque si besoin (script conçu pour être
rejouable).
