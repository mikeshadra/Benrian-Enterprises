/* =========================================================================
   CONFIG.JS — Supabase connection settings
   =========================================================================
   Both index.html and admin.html read these two constants. The names must
   stay EXACTLY as written (SUPABASE_URL, SUPABASE_ANON_KEY, all capitals).

   Get both values from the Supabase dashboard:
   Project Settings -> API (Project URL + publishable/anon key).
   The key MUST come from the same project as the URL.

   The publishable/anon key is safe to expose publicly — access control is
   enforced by the Row Level Security policies in schema.sql.
   ========================================================================= */

const SUPABASE_URL = "https://qiuoycnqrkbzldcqbhxd.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpdW95Y25xcmtiemxkY3FiaHhkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1OTkzMzUsImV4cCI6MjEwNTE3NTMzNX0.sbCLpXKmITGHsxCVQUJe_vgNf4_zPvv66n9bJnT2wmk";
