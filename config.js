// ============================================
// Laliguras Supabase Configuration
// ============================================
// Get these from: https://supabase.com → your project → Settings → API
//
// IMPORTANT: The anon/public key is safe to commit publicly.
// It only allows what Row-Level Security policies permit.
// (Don't paste the service_role key here — that's secret.)
// ============================================

window.LALIGURAS_CONFIG = {
  // Find at: Project Settings → API → Project URL
  SUPABASE_URL: 'https://qglmbwjghcienyssltmf.supabase.co',

  // Find at: Project Settings → API → Project API keys → anon public
  SUPABASE_ANON_KEY: 'sb_publishable_hOWjqEghaSlpKI3fKNouzw_QSQb2g8o',

  // Restaurant settings
  RESTAURANT_NAME: 'Laliguras',
  RESTAURANT_NAME_KR: '라리구라스',
  LOCATION: 'Hwaseong',
  LOCATION_KR: '화성',
  ESTABLISHED: 2026,

  // The base URL where the menu is hosted (used by QR generator)
  MENU_URL: 'https://hwaseong-laliguras.vercel.app/'
};
