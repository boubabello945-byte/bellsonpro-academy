// ============================================================================
// Bellsonpro-Academy — Connexion à Supabase
// ============================================================================
// Ce fichier initialise le client Supabase. Il ne fait QUE la connexion pour
// l'instant — le reste du site (panier, comptes, produits) continue de
// fonctionner avec les données locales tant que l'intégration complète n'est
// pas branchée dans script principal.
//
// ⚠️ ÉTAPE OBLIGATOIRE : remplacez les deux valeurs ci-dessous par celles de
// VOTRE projet Supabase (Project Settings → API dans le tableau de bord) :
// ============================================================================

const SUPABASE_URL = 'https://zaqzhiulkmztrybpqjnq.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_INhIJQjd4RE3Qvifa-V-GQ_mJaK3GDb';

let supabaseClient = null;

(function initSupabase(){
  if(SUPABASE_URL.startsWith('REMPLACEZ') || SUPABASE_ANON_KEY.startsWith('REMPLACEZ')){
    console.warn(
      '[Bellsonpro-Academy] Supabase n\'est pas encore configuré.\n' +
      'Ouvrez script.js et remplacez SUPABASE_URL et SUPABASE_ANON_KEY par les ' +
      'valeurs de votre projet (Project Settings → API dans le tableau de bord Supabase).'
    );
    return;
  }
  if(typeof window.supabase === 'undefined'){
    console.error('[Bellsonpro-Academy] La librairie Supabase ne s\'est pas chargée (vérifiez la connexion internet ou le CDN).');
    return;
  }
  supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  console.log('[Bellsonpro-Academy] Client Supabase initialisé.');

  // Petit test de connexion (facultatif) : vérifie que la table "settings"
  // créée par supabase-schema.sql est bien accessible.
  supabaseClient
    .from('settings')
    .select('key')
    .limit(1)
    .then(({ data, error }) => {
      if(error){
        console.error('[Bellsonpro-Academy] Connexion Supabase établie, mais la requête de test a échoué :', error.message);
        console.error('→ Vérifiez que vous avez bien exécuté supabase-schema.sql dans le SQL Editor.');
      } else {
        console.log('[Bellsonpro-Academy] Connexion Supabase OK, base de données accessible ✓', data);
      }
    });
})();

// ============================================================================
// La suite (comptes réels, produits depuis la base, commandes, paiement) sera
// ajoutée ici à l'étape suivante, une fois la connexion confirmée.
// ============================================================================
