-- =============================================================================
-- Crestline Hardware — Supabase schema
-- Run this once in your project's SQL Editor (Supabase dashboard → SQL Editor
-- → New query → paste all of this → Run). Safe to run only once; re-running
-- will error on "already exists" — that's fine, it means it's already set up.
-- =============================================================================

create extension if not exists "pgcrypto";

-- -----------------------------------------------------------------------------
-- store_info: a single-row table holding shop details, hours and categories
-- -----------------------------------------------------------------------------
create table store_info (
  id int primary key default 1,
  name text not null default 'Crestline Hardware',
  tagline text not null default 'Everything for the job, in stock and ready',
  phone_display text not null default '+254 700 000 000',
  whatsapp_number text not null default '254700000000',
  email text not null default 'info@crestlinehardware.co.ke',
  address text not null default 'Moi North Lake Road, Naivasha, Kenya',
  map_embed_src text not null default 'https://www.google.com/maps?q=Naivasha%2C%20Kenya&output=embed',
  maps_directions_url text not null default 'https://www.google.com/maps/search/?api=1&query=Naivasha+Hardware',
  currency text not null default 'KSh',
  hours jsonb not null default '[]'::jsonb,
  categories jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now(),
  constraint single_row check (id = 1)
);

-- -----------------------------------------------------------------------------
-- products: the catalogue
-- -----------------------------------------------------------------------------
create table products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null,
  unit text not null default 'per piece',
  price numeric(10,2) not null default 0,
  discount_price numeric(10,2),
  in_stock boolean not null default true,
  description text default '',
  image_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index products_category_idx on products (category);
create index products_in_stock_idx on products (in_stock);

-- keep updated_at current on every edit
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger products_set_updated_at
  before update on products
  for each row execute function set_updated_at();

create trigger store_info_set_updated_at
  before update on store_info
  for each row execute function set_updated_at();

-- -----------------------------------------------------------------------------
-- Row Level Security — anyone can read, only a logged-in admin can write
-- -----------------------------------------------------------------------------
alter table products enable row level security;
alter table store_info enable row level security;

create policy "Public can read products"
  on products for select
  using (true);

create policy "Authenticated users can manage products"
  on products for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "Public can read store info"
  on store_info for select
  using (true);

create policy "Authenticated users can manage store info"
  on store_info for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- -----------------------------------------------------------------------------
-- Storage bucket for product photos
-- -----------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do nothing;

create policy "Public can view product images"
  on storage.objects for select
  using (bucket_id = 'product-images');

create policy "Authenticated users can upload product images"
  on storage.objects for insert
  with check (bucket_id = 'product-images' and auth.role() = 'authenticated');

create policy "Authenticated users can update product images"
  on storage.objects for update
  using (bucket_id = 'product-images' and auth.role() = 'authenticated');

create policy "Authenticated users can delete product images"
  on storage.objects for delete
  using (bucket_id = 'product-images' and auth.role() = 'authenticated');

-- -----------------------------------------------------------------------------
-- Seed data — starter store info + 16 sample products across 8 categories.
-- Edit or delete these later from the admin panel; they're just here so the
-- site isn't empty on first load.
-- -----------------------------------------------------------------------------
insert into store_info (id, name, tagline, phone_display, whatsapp_number, email, address, map_embed_src, maps_directions_url, currency, hours, categories)
values (
  1,
  'Crestline Hardware',
  'Everything for the job, in stock and ready',
  '+254 700 000 000',
  '254700000000',
  'info@crestlinehardware.co.ke',
  'Moi North Lake Road, Naivasha, Kenya',
  'https://www.google.com/maps?q=Naivasha%2C%20Kenya&output=embed',
  'https://www.google.com/maps/search/?api=1&query=Naivasha+Hardware',
  'KSh',
  '[{"day":"Monday – Friday","time":"8:00 AM – 6:30 PM"},{"day":"Saturday","time":"8:00 AM – 5:00 PM"},{"day":"Sunday","time":"10:00 AM – 2:00 PM"}]'::jsonb,
  '["Power Tools","Hand Tools","Building Materials","Plumbing","Electrical","Paint & Finishing","Fasteners","Safety Gear"]'::jsonb
)
on conflict (id) do nothing;

insert into products (name, category, unit, price, discount_price, in_stock, description) values
('Cordless Drill Driver 18V', 'Power Tools', 'per piece', 8500, 7200, true, '18V cordless drill with two batteries and fast charger.'),
('Angle Grinder 115mm', 'Power Tools', 'per piece', 4200, null, true, '750W angle grinder for cutting and finishing metal.'),
('Claw Hammer 16oz', 'Hand Tools', 'per piece', 650, null, true, 'Steel shank claw hammer with rubber grip.'),
('Adjustable Wrench Set (3pc)', 'Hand Tools', 'per set', 1450, 1200, true, '8-inch, 10-inch and 12-inch adjustable wrenches.'),
('Portland Cement 50kg', 'Building Materials', 'per bag', 780, null, true, 'General purpose cement for construction work.'),
('Steel Reinforcement Bar 12mm', 'Building Materials', 'per length', 950, null, false, '12mm deformed steel bar, 12m length.'),
('PVC Pipe 4-inch', 'Plumbing', 'per length', 1100, null, true, '4-inch drainage PVC pipe, 6m length.'),
('Ball Valve 1-inch', 'Plumbing', 'per piece', 550, 420, true, 'Brass ball valve for water supply lines.'),
('Circuit Breaker 20A', 'Electrical', 'per piece', 480, null, true, 'Single pole MCB circuit breaker, 20 amp.'),
('Electrical Cable 2.5mm (100m)', 'Electrical', 'per roll', 6200, 5500, true, 'Twin and earth copper cable, 100 metre roll.'),
('Emulsion Paint 4L', 'Paint & Finishing', 'per tin', 2100, null, true, 'Interior matte emulsion paint, washable finish.'),
('Paint Roller Kit', 'Paint & Finishing', 'per set', 850, 650, false, '9-inch roller, tray and two roller sleeves.'),
('Wood Screws Assorted (200pc)', 'Fasteners', 'per box', 550, null, true, 'Assorted sizes, countersunk head, zinc plated.'),
('Anchor Bolts 10mm (50pc)', 'Fasteners', 'per box', 1350, null, true, 'Expansion anchor bolts for concrete fixing.'),
('Safety Helmet', 'Safety Gear', 'per piece', 750, null, true, 'Adjustable hard hat, meets site safety standards.'),
('Work Gloves (pair)', 'Safety Gear', 'per pair', 320, 250, true, 'Reinforced palm gloves for general site work.');
