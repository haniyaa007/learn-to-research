-- Run in Supabase: SQL Editor -> New query
create table if not exists public.scores (
  id uuid primary key default gen_random_uuid(),
  nickname text not null check (char_length(nickname) between 2 and 20),
  persona text not null,
  score int not null check (score between 0 and 500),
  created_at timestamptz not null default now()
);
alter table public.scores enable row level security;
create policy "anyone can read scores" on public.scores for select using (true);
create policy "anyone can insert valid scores" on public.scores for insert with check (true);
-- No update/delete policies: rows are immutable from the app.
-- NOTE: client-side scores can be spoofed. For strict anti-cheat, move inserts to an Edge Function.
