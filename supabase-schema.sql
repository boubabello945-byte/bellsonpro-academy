-- ============================================================================
-- Bellsonpro-Academy — Schéma Supabase (Phase 1 : base de données + paiement)
-- À coller dans : Supabase → SQL Editor → New query → Run
-- ============================================================================

-- Extension utile pour générer des identifiants
create extension if not exists "pgcrypto";

-- ----------------------------------------------------------------------------
-- PROFILS CLIENTS (complète auth.users géré automatiquement par Supabase Auth)
-- ----------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  prenom text not null,
  nom text not null,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Un utilisateur voit/modifie son propre profil"
  on public.profiles for select using (auth.uid() = id);
create policy "Un utilisateur met à jour son propre profil"
  on public.profiles for update using (auth.uid() = id);
create policy "Création de profil à l'inscription"
  on public.profiles for insert with check (auth.uid() = id);

-- ----------------------------------------------------------------------------
-- PRODUITS
-- ----------------------------------------------------------------------------
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  category text not null,          -- mathematiques | physique | chimie | ingenieur | informatique | meteorologie
  level text not null,
  title text not null,
  short_desc text not null,
  long_desc text not null,
  format text not null default 'PDF',
  price integer not null,          -- en FCFA
  file_path text,                  -- chemin dans le bucket privé "product-files"
  cover_emoji text default '📄',
  is_popular boolean not null default false,
  is_new boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.products enable row level security;

create policy "Les produits sont visibles par tout le monde"
  on public.products for select using (true);
create policy "Seuls les admins créent des produits"
  on public.products for insert with check (
    exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );
create policy "Seuls les admins modifient des produits"
  on public.products for update using (
    exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );
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
  total integer not null,                  -- en FCFA
  status text not null default 'en_attente', -- en_attente | payé | échoué
  payment_method text,                     -- orange_money | mtn_momo | moov_money | carte
  cinetpay_transaction_id text,
  created_at timestamptz not null default now(),
  paid_at timestamptz
);

alter table public.orders enable row level security;

create policy "Un utilisateur voit ses propres commandes"
  on public.orders for select using (auth.uid() = user_id);
create policy "Les admins voient toutes les commandes"
  on public.orders for select using (
    exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );
create policy "Un utilisateur crée sa propre commande"
  on public.orders for insert with check (auth.uid() = user_id or user_id is null);
-- NB : la mise à jour du statut "payé" se fait uniquement via la fonction Edge
-- (rôle "service_role", qui contourne la RLS) après vérification du paiement CinetPay.
-- Aucune policy "update" n'est ouverte au client : le statut ne peut pas être
-- falsifié depuis le navigateur.

-- ----------------------------------------------------------------------------
-- LIGNES DE COMMANDE
-- ----------------------------------------------------------------------------
create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid not null references public.products(id),
  price integer not null -- prix au moment de l'achat (historique, même si le prix change après)
);

alter table public.order_items enable row level security;

create policy "Visible si la commande parente est visible"
  on public.order_items for select using (
    exists (
      select 1 from public.orders o
      where o.id = order_id and (o.user_id = auth.uid()
        or exists (select 1 from public.profiles where id = auth.uid() and is_admin = true))
    )
  );
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

create policy "Tout le monde peut envoyer un message"
  on public.messages for insert with check (true);
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

create policy "Les réglages sont lisibles par tout le monde"
  on public.settings for select using (true);
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
