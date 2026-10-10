-- Digital Library: run once in Supabase SQL Editor.
-- This adds the fields used by the connected storefront.
alter table public.orders
  add column if not exists province text,
  add column if not exists notes text,
  add column if not exists total_amount numeric(12,2),
  add column if not exists status text not null default 'pending',
  add column if not exists created_at timestamptz not null default now();

-- Enable RLS on both tables.
alter table public.books enable row level security;
alter table public.orders enable row level security;

-- Public visitors can read active books only.
drop policy if exists "Public can read active books" on public.books;
create policy "Public can read active books"
on public.books for select
to anon, authenticated
using (is_active = true);

-- Visitors can submit orders, but cannot read orders back.
drop policy if exists "Public can submit orders" on public.orders;
create policy "Public can submit orders"
on public.orders for insert
to anon, authenticated
with check (
  customer_name is not null and length(trim(customer_name)) > 0
  and phone is not null and length(trim(phone)) > 0
  and address is not null and length(trim(address)) > 0
  and items is not null
);

-- Important: do not create public SELECT/UPDATE/DELETE policies on orders.
-- Manage and read orders only from the Supabase dashboard for now.
