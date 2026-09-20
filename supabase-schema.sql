-- ============================================================================
-- Bellsonpro-Academy — Schéma Supabase (Phase 1 : base de données + paiement)
-- Version SÛRE : peut être exécutée plusieurs fois sans erreur, même si
-- certaines tables/règles existent déjà d'un essai précédent.
-- À coller dans : Supabase → SQL Editor → New query → Run
-- ============================================================================

create extension if not exists "pgcrypto";

-- ----------------------------------------------------------------------------
-- PROFILS CLIENTS
-- ----------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  prenom text not null,
  nom text not null,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;

drop policy if exists "Un utilisateur voit/modifie son propre profil" on public.profiles;
create policy "Un utilisateur voit/modifie son propre profil"
  on public.profiles for select using (auth.uid() = id);

drop policy if exists "Un utilisateur met à jour son propre profil" on public.profiles;
create policy "Un utilisateur met à jour son propre profil"
  on public.profiles for update using (auth.uid() = id);

drop policy if exists "Création de profil à l'inscription" on public.profiles;
create policy "Création de profil à l'inscription"
  on public.profiles for insert with check (auth.uid() = id);

-- ----------------------------------------------------------------------------
-- PRODUITS
-- ----------------------------------------------------------------------------
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  category text not null,
  level text not null,
  title text not null,
  short_desc text not null,
  long_desc text not null,
  format text not null default 'PDF',
  price integer not null,
  file_path text,
  cover_emoji text default '📄',
  is_popular boolean not null default false,
  is_new boolean not null default false,
  created_at timestamptz not null default now()
);
alter table public.products enable row level security;

drop policy if exists "Les produits sont visibles par tout le monde" on public.products;
create policy "Les produits sont visibles par tout le monde"
  on public.products for select using (true);

drop policy if exists "Seuls les admins créent des produits" on public.products;
create policy "Seuls les admins créent des produits"
  on public.products for insert with check (
    exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );

drop policy if exists "Seuls les admins modifient des produits" on public.products;
create policy "Seuls les admins modifient des produits"
  on public.products for update using (
    exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );

drop policy if exists "Seuls les admins suppriment des produits" on public.products;
create policy "Seuls les admins suppriment des produits"
  on public.products for delete using (
    exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );

-- ----------------------------------------------------------------------------
-- COMMANDES
-- ----------------------------------------------------------------------------
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  customer_email text not null,
  customer_name text not null,
  total integer not null,
  status text not null default 'en_attente',
  payment_method text,
  cinetpay_transaction_id text,
  created_at timestamptz not null default now(),
  paid_at timestamptz
);
alter table public.orders enable row level security;

drop policy if exists "Un utilisateur voit ses propres commandes" on public.orders;
create policy "Un utilisateur voit ses propres commandes"
  on public.orders for select using (auth.uid() = user_id);

drop policy if exists "Les admins voient toutes les commandes" on public.orders;
create policy "Les admins voient toutes les commandes"
  on public.orders for select using (
    exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );

drop policy if exists "Un utilisateur crée sa propre commande" on public.orders;
create policy "Un utilisateur crée sa propre commande"
  on public.orders for insert with check (auth.uid() = user_id or user_id is null);
-- NB : le statut "payé" n'est modifiable que par la fonction Edge (service_role),
-- jamais par le navigateur — aucune policy "update" côté client, volontairement.

-- ----------------------------------------------------------------------------
-- LIGNES DE COMMANDE
-- ----------------------------------------------------------------------------
create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid not null references public.products(id),
  price integer not null
);
alter table public.order_items enable row level security;

drop policy if exists "Visible si la commande parente est visible" on public.order_items;
create policy "Visible si la commande parente est visible"
  on public.order_items for select using (
    exists (
      select 1 from public.orders o
      where o.id = order_id and (o.user_id = auth.uid()
        or exists (select 1 from public.profiles where id = auth.uid() and is_admin = true))
    )
  );

drop policy if exists "Ajout de lignes à sa propre commande" on public.order_items;
create policy "Ajout de lignes à sa propre commande"
  on public.order_items for insert with check (
    exists (select 1 from public.orders o where o.id = order_id and (o.user_id = auth.uid() or o.user_id is null))
  );

-- ----------------------------------------------------------------------------
-- MESSAGES DE CONTACT
-- ----------------------------------------------------------------------------
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text not null,
  subject text,
  message text not null,
  created_at timestamptz not null default now()
);
alter table public.messages enable row level security;

drop policy if exists "Tout le monde peut envoyer un message" on public.messages;
create policy "Tout le monde peut envoyer un message"
  on public.messages for insert with check (true);

drop policy if exists "Seuls les admins lisent les messages" on public.messages;
create policy "Seuls les admins lisent les messages"
  on public.messages for select using (
    exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );

-- ----------------------------------------------------------------------------
-- RÉGLAGES (réseaux sociaux, etc.)
-- ----------------------------------------------------------------------------
create table if not exists public.settings (
  key text primary key,
  value jsonb not null
);
alter table public.settings enable row level security;

drop policy if exists "Les réglages sont lisibles par tout le monde" on public.settings;
create policy "Les réglages sont lisibles par tout le monde"
  on public.settings for select using (true);

drop policy if exists "Seuls les admins modifient les réglages" on public.settings;
create policy "Seuls les admins modifient les réglages"
  on public.settings for all using (
    exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );

insert into public.settings (key, value) values (
  'social_links',
  '{"facebook":"https://facebook.com/bellsonproacademy","tiktok":"https://tiktok.com/@bellsonproacademy","youtube":"https://youtube.com/@bellsonproacademy","whatsapp":"https://wa.me/22500000000","instagram":"https://instagram.com/bellsonproacademy"}'
) on conflict (key) do nothing;

-- ----------------------------------------------------------------------------
-- COMMENT DÉSIGNER VOTRE PROPRE COMPTE COMME ADMINISTRATEUR
-- ----------------------------------------------------------------------------
-- 1. Inscrivez-vous normalement sur le site une fois qu'il sera branché à Supabase.
-- 2. Revenez ici et exécutez (en remplaçant l'e-mail) :
--
-- update public.profiles set is_admin = true
-- where id = (select id from auth.users where email = 'votre-email@exemple.com');
-- ============================================================================
