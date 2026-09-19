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

function showConnectionBanner(message, isError){
  const existing = document.getElementById('supabaseStatusBanner');
  if(existing) existing.remove();
  const banner = document.createElement('div');
  banner.id = 'supabaseStatusBanner';
  // En haut de l'écran (pas en bas) et auto-masqué après quelques secondes,
  // pour ne plus jamais rester au-dessus d'un bouton et bloquer les clics.
  banner.style.cssText = 'position:fixed;top:0;left:0;right:0;z-index:9999;padding:10px 16px;' +
    'font-family:sans-serif;font-size:12.5px;text-align:center;color:#fff;box-shadow:0 2px 10px rgba(0,0,0,.15);' +
    (isError ? 'background:#C0392B;' : 'background:#1F7A4D;');
  banner.innerHTML = message + ' <span style="text-decoration:underline;cursor:pointer;margin-left:10px;white-space:nowrap;" onclick="document.getElementById(\'supabaseStatusBanner\').remove()">fermer</span>';
  document.body.appendChild(banner);
  // Disparition automatique : n'occupe jamais durablement la place d'un bouton.
  setTimeout(()=>{ const b = document.getElementById('supabaseStatusBanner'); if(b) b.remove(); }, isError ? 12000 : 5000);
}

(function initSupabase(){
  if(SUPABASE_URL.startsWith('REMPLACEZ') || SUPABASE_ANON_KEY.startsWith('REMPLACEZ')){
    showConnectionBanner('⚠️ Supabase non configuré : ouvrez script.js et remplacez SUPABASE_URL / SUPABASE_ANON_KEY.', true);
    return;
  }
  if(typeof window.supabase === 'undefined'){
    showConnectionBanner('❌ La librairie Supabase ne s\'est pas chargée (vérifiez que la ligne <script src=".../supabase-js@2"> est bien présente et chargée AVANT script.js dans index.html).', true);
    return;
  }
  supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

  supabaseClient
    .from('settings')
    .select('key')
    .limit(1)
    .then(({ data, error }) => {
      if(error){
        showConnectionBanner('⚠️ Connexion Supabase établie, mais la table "settings" n\'a pas été trouvée (' + error.message + '). Avez-vous exécuté supabase-schema.sql dans le SQL Editor ?', true);
      } else {
        showConnectionBanner('✅ Connexion Supabase réussie — la base de données répond correctement.', false);
      }
    });
})();

// ============================================================================
// La suite (comptes réels, produits depuis la base, commandes, paiement) sera
// ajoutée ici à l'étape suivante, une fois la connexion confirmée.
// ============================================================================
