-- policies.sql
-- CozyReads RLS policies (FIXED – no recursion)

-- =========================
-- ENABLE RLS
-- =========================
alter table items enable row level security;
alter table item_parts enable row level security;
alter table reading_runs enable row level security;
alter table quotes enable row level security;

-- =========================
-- ITEMS (🔥 FIXED)
-- =========================
drop policy if exists "Items select own" on items;
drop policy if exists "Items insert own" on items;
drop policy if exists "Items update own" on items;
drop policy if exists "Items delete own" on items;

-- ✅ SIMPLE, SAFE, NO RECURSION
create policy "Items select own"
on items
for select
                                   using (user_id = auth.uid());

create policy "Items insert own"
on items
for insert
with check (user_id = auth.uid());

create policy "Items update own"
on items
for update
                      using (user_id = auth.uid());

create policy "Items delete own"
on items
for delete
using (user_id = auth.uid());

-- =========================
-- ITEM PARTS
-- =========================
drop policy if exists "Item parts select own" on item_parts;
drop policy if exists "Item parts insert own" on item_parts;
drop policy if exists "Item parts update own" on item_parts;
drop policy if exists "Item parts delete own" on item_parts;

create policy "Item parts select own"
on item_parts
for select
                                   using (
                                   exists (
                                   select 1
                                   from items
                                   where items.id = item_parts.item_id
                                   and items.user_id = auth.uid()
                                   )
                                   );

create policy "Item parts insert own"
on item_parts
for insert
with check (
  exists (
    select 1
    from items
    where items.id = item_parts.item_id
      and items.user_id = auth.uid()
  )
);

create policy "Item parts update own"
on item_parts
for update
                      using (
                      exists (
                      select 1
                      from items
                      where items.id = item_parts.item_id
                      and items.user_id = auth.uid()
                      )
                      );

create policy "Item parts delete own"
on item_parts
for delete
using (
  exists (
    select 1
    from items
    where items.id = item_parts.item_id
      and items.user_id = auth.uid()
  )
);

-- =========================
-- READING RUNS
-- =========================
drop policy if exists "Runs select own" on reading_runs;
drop policy if exists "Runs insert own" on reading_runs;
drop policy if exists "Runs update own" on reading_runs;
drop policy if exists "Runs delete own" on reading_runs;

create policy "Runs select own"
on reading_runs
for select
                                   using (user_id = auth.uid());

create policy "Runs insert own"
on reading_runs
for insert
with check (
  user_id = auth.uid()
  and exists (
    select 1 from items
    where items.id = reading_runs.item_id
      and items.user_id = auth.uid()
  )
);

create policy "Runs update own"
on reading_runs
for update
                      using (user_id = auth.uid());

create policy "Runs delete own"
on reading_runs
for delete
using (user_id = auth.uid());

-- =========================
-- QUOTES
-- =========================
drop policy if exists "Quotes select own" on quotes;
drop policy if exists "Quotes insert own" on quotes;
drop policy if exists "Quotes update own" on quotes;
drop policy if exists "Quotes delete own" on quotes;

create policy "Quotes select own"
on quotes
for select
                                   using (
                                   exists (
                                   select 1
                                   from items
                                   where items.id = quotes.item_id
                                   and items.user_id = auth.uid()
                                   )
                                   );

create policy "Quotes insert own"
on quotes
for insert
with check (
  exists (
    select 1
    from items
    where items.id = quotes.item_id
      and items.user_id = auth.uid()
  )
);

create policy "Quotes update own"
on quotes
for update
                      using (
                      exists (
                      select 1
                      from items
                      where items.id = quotes.item_id
                      and items.user_id = auth.uid()
                      )
                      );

create policy "Quotes delete own"
on quotes
for delete
using (
  exists (
    select 1
    from items
    where items.id = quotes.item_id
      and items.user_id = auth.uid()
  )
);
