-- schema.sql
-- CozyReads (Supabase Postgres)

-- =========================
-- EXTENSIONS
-- =========================
create extension if not exists pgcrypto;

-- =========================
-- ENUMS
-- =========================
do $$ begin
create type item_type as enum ('book', 'fanfic');
exception when duplicate_object then null;
end $$;

do $$ begin
create type reading_status as enum ('to_read', 'reading', 'finished');
exception when duplicate_object then null;
end $$;

do $$ begin
create type part_type as enum ('main', 'prequel', 'sequel', 'spin_off');
exception when duplicate_object then null;
end $$;

-- =========================
-- ITEMS
-- =========================
create table if not exists items (
                                     id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,

    type item_type not null,
    status reading_status not null default 'to_read',

    title text not null,
    author text not null,

    -- Book
    genre text,
    cover_url text,
    total_pages integer,

    -- Fanfic
    fandom text,
    is_hiatus boolean default false,
    total_chapters integer,

    -- Fanfic relations
    part part_type not null default 'main',
    related_to uuid,

    tags text[] default '{}',

    -- Rating
    rating_sum integer default 0,
    rating_count integer default 0,
    rating_avg numeric(3,2) default 0,

    created_at timestamptz default now(),
    updated_at timestamptz default now(),

    constraint unique_user_item unique (user_id, title, author),
    constraint pages_nonneg check (total_pages is null or total_pages >= 0),
    constraint chapters_nonneg check (total_chapters is null or total_chapters >= 0)
    );

-- =========================
-- SELF FK (related_to)
-- =========================
do $$ begin
alter table items
    add constraint items_related_to_fkey
        foreign key (related_to) references items(id)
            on delete set null;
exception when duplicate_object then null;
end $$;

create index if not exists idx_items_related_to on items(related_to);
create index if not exists idx_items_type on items(type);

-- =========================
-- MIGRATION: tags → columns
-- =========================

-- 1️⃣ PART: tag → column
update items
set part = replace(t.tag, 'part:', '')::part_type
from (
    select id, unnest(tags) as tag
    from items
    ) t
where items.id = t.id
  and t.tag like 'part:%';

-- 2️⃣ RELATED: tag → column (solo si el ID existe)
update items
set related_to = replace(t.tag, 'related:', '')::uuid
from (
    select id, unnest(tags) as tag
    from items
    ) t
where items.id = t.id
  and t.tag like 'related:%'
  and exists (
    select 1
    from items x
    where x.id = replace(t.tag, 'related:', '')::uuid
    );

-- 3️⃣ CLEAN TAGS (remove structural tags)
update items
set tags = (
    select coalesce(array_agg(tag), '{}')
    from unnest(tags) tag
    where tag not like 'part:%'
      and tag not like 'related:%'
);

-- =========================
-- READING RUNS
-- =========================
create table if not exists reading_runs (
                                            id uuid primary key default gen_random_uuid(),
    item_id uuid not null references items(id) on delete cascade,
    user_id uuid not null references auth.users(id) on delete cascade,

    run_number integer not null,
    is_active boolean default true,

    progress_pages integer default 0,
    progress_chapters integer default 0,

    start_time timestamptz default now(),
    end_time timestamptz,

    rating integer check (rating between 1 and 5),
    review text,

    created_at timestamptz default now(),

    constraint unique_run_per_item unique (item_id, run_number),
    constraint pages_progress_nonneg check (progress_pages >= 0),
    constraint chapters_progress_nonneg check (progress_chapters >= 0)
    );

-- =========================
-- QUOTES
-- =========================
create table if not exists quotes (
                                      id uuid primary key default gen_random_uuid(),
    item_id uuid not null references items(id) on delete cascade,
    run_id uuid not null references reading_runs(id) on delete cascade,
    quote_text text not null,
    created_at timestamptz default now()
    );

-- =========================
-- UPDATED_AT
-- =========================
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
return new;
end;
$$ language plpgsql;

drop trigger if exists trg_updated_at on items;
create trigger trg_updated_at
    before update on items
    for each row execute function set_updated_at();
