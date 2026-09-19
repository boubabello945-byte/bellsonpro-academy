# Bellsonpro-Academy

Plateforme de vente de ressources scientifiques (mathématiques, physique, chimie, sciences de
l'ingénieur, informatique scientifique, météorologie et climatologie) — cours, exercices corrigés,
livres numériques, fiches de révision, etc.

## Contenu de ce dossier

Le site est un **fichier HTML unique et autonome** : `index.html`. Il contient tout (mise en page,
styles, scripts) — il n'y a pas d'autre fichier CSS/JS/image à part celui-ci, donc rien d'autre à
copier pour l'héberger.

Les données de démonstration (produits, comptes, commandes) sont stockées dans le `localStorage` du
navigateur du visiteur. C'est un prototype front-end complet, sans backend : voir la section
« Limites et prochaines étapes » plus bas.

## Héberger sur GitHub Pages

1. Créez un nouveau dépôt sur GitHub (public, pour que GitHub Pages soit gratuit).
2. Ajoutez ce fichier `index.html` à la racine du dépôt (c'est important : GitHub Pages sert
   automatiquement `index.html` s'il est à la racine, sous forme de page d'accueil).
3. Poussez (commit + push) sur la branche par défaut (`main` en général).
4. Dans GitHub : **Settings → Pages**.
5. Sous « Build and deployment » → Source : choisissez **Deploy from a branch**.
6. Branche : `main`, dossier : `/ (root)`. Cliquez sur **Save**.
7. Attendez 1 à 2 minutes : GitHub affiche l'URL publique, du type :
   `https://<votre-nom-utilisateur>.github.io/<nom-du-depot>/`

### Avec Git en ligne de commande

```bash
git init
git add index.html README.md
git commit -m "Site Bellsonpro-Academy"
git branch -M main
git remote add origin https://github.com/<votre-nom-utilisateur>/<nom-du-depot>.git
git push -u origin main
```

Puis activez GitHub Pages comme décrit ci-dessus.

### Sans ligne de commande

Vous pouvez aussi tout faire depuis l'interface web de GitHub : « Add file » → « Upload files » →
déposez `index.html` (et ce `README.md` si vous voulez) → « Commit changes ». Puis activez Pages
comme à l'étape 4.

## Accès administrateur (démonstration)

La page `#/admin` du site est protégée par un mot de passe de démonstration : `admin123`.
Pensez à le changer avant toute mise en ligne publique sérieuse (voir variable `DB_KEYS.adminPass`
dans le script, ou modifiez-le directement une fois connecté si l'interface le permet).

## Limites et prochaines étapes

Ce site est une démonstration front-end complète et interactive, mais sans serveur réel :

- Les données (produits, commandes, comptes) sont stockées en `localStorage`, donc **propres à
  chaque navigateur** — elles ne sont pas partagées entre visiteurs et peuvent être effacées si
  l'utilisateur vide son cache.
- Les paiements (Orange Money, MTN MoMo, carte bancaire) sont simulés : aucune vraie transaction
  n'est effectuée.
- Il n'y a pas de vrai stockage sécurisé de fichiers PDF ni de vraie authentification côté serveur.

Pour une mise en production réelle, il faudra brancher un backend (Node/Express, Laravel, Django,
ou un service comme Supabase/Firebase) pour la base de données, l'authentification, le stockage de
fichiers et l'intégration réelle des passerelles de paiement.
