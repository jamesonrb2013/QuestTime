-- QuestTime cloud accounts and save data
-- Run this in Supabase SQL Editor after creating a FREE project.
-- Safe browser access is enforced by Row Level Security: users can only access their own rows.

create table if not exists public.questtime_saves (
  user_id uuid primary key references auth.users(id) on delete cascade,
  save_data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  constraint questtime_save_data_is_object check (jsonb_typeof(save_data) = 'object')
);

alter table public.questtime_saves enable row level security;

drop policy if exists "Users can read their own QuestTime save" on public.questtime_saves;
create policy "Users can read their own QuestTime save"
  on public.questtime_saves for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can create their own QuestTime save" on public.questtime_saves;
create policy "Users can create their own QuestTime save"
  on public.questtime_saves for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their own QuestTime save" on public.questtime_saves;
create policy "Users can update their own QuestTime save"
  on public.questtime_saves for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create or replace function public.questtime_set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists questtime_saves_updated_at on public.questtime_saves;
create trigger questtime_saves_updated_at
  before update on public.questtime_saves
  for each row execute function public.questtime_set_updated_at();

grant select, insert, update on public.questtime_saves to authenticated;
revoke all on public.questtime_saves from anon;
