/* ==========================================================================
   MOG backend configuration
   --------------------------------------------------------------------------
   Leave `url` blank and the app runs on local demo data, which is what it does
   today. Fill both in and it talks to the real project instead.

   `anonKey` is the publishable key. It is safe in client code — every table it
   can reach is governed by the Row Level Security policies in
   supabase/migrations/. It is NOT the service-role key, which must never
   appear in a browser or in this repository.

   Nothing here is filled in yet on purpose: the migrations have not been
   applied, so there is nothing to point at.
   ========================================================================== */

window.MOG_BACKEND = {
  url: '',        // e.g. https://fxbkvcrfbbcmrrupdcjt.supabase.co
  anonKey: ''     // publishable anon key
};
