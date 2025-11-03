-- =============================================
-- Vehicle Database Schema Migration
-- Add vehicles and user_vehicles tables
-- =============================================

-- ---------------------------------------------
-- 1. Table vehicles (Vehicle catalog)
-- ---------------------------------------------
create table if not exists public.vehicles (
  id uuid default gen_random_uuid() primary key,
  chassis_number text unique, -- VIN number
  make text not null, -- Manufacturer (e.g., Hyundai, Toyota)
  model text not null, -- Model name (e.g., Santa Fe, Camry)
  motorization text, -- Engine specification (e.g., "Essence - 3.3 4WD (199 KW / 270 CV)")
  year int, -- Manufacturing year
  type text, -- Vehicle type (SUV, Sedan, etc.)
  engine_type text, -- Engine type (V6, I4, etc.)
  fuel_type text, -- Fuel type (Essence, Diesel, Hybride, etc.)
  transmission text, -- Transmission type (Automatique, Manuelle)
  displacement text, -- Engine displacement (e.g., "3.3L")
  series_number text, -- Serial number
  manufacture_location text, -- Manufacturing location
  image_url text, -- Vehicle image
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table public.vehicles enable row level security;

-- Indexes for efficient querying
create index if not exists vehicles_make_idx on public.vehicles(make);
create index if not exists vehicles_model_idx on public.vehicles(model);
create index if not exists vehicles_make_model_idx on public.vehicles(make, model);
create index if not exists vehicles_chassis_number_idx on public.vehicles(chassis_number);

-- ---------------------------------------------
-- 2. Table user_vehicles (User's garage)
-- ---------------------------------------------
create table if not exists public.user_vehicles (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  vehicle_id uuid references public.vehicles(id) on delete cascade not null,
  nickname text, -- Optional nickname for the vehicle (e.g., "My Santa Fe")
  is_primary boolean default false, -- Is this the primary vehicle
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user_id, vehicle_id)
);

-- Enable RLS
alter table public.user_vehicles enable row level security;

-- Index
create index if not exists user_vehicles_user_id_idx on public.user_vehicles(user_id);
create index if not exists user_vehicles_vehicle_id_idx on public.user_vehicles(vehicle_id);

-- ---------------------------------------------
-- 3. RLS Policies for vehicles
-- ---------------------------------------------
-- Everyone can view active vehicles
create policy "Vehicles are viewable by everyone"
  on public.vehicles for select
  to anon, authenticated
  using (is_active = true);

-- ---------------------------------------------
-- 4. RLS Policies for user_vehicles
-- ---------------------------------------------
-- Users can view their own vehicles
create policy "Users can view own vehicles"
  on public.user_vehicles for select
  to authenticated
  using (auth.uid() = user_id);

-- Users can add vehicles to their garage
create policy "Users can insert own vehicles"
  on public.user_vehicles for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Users can update their vehicles
create policy "Users can update own vehicles"
  on public.user_vehicles for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Users can delete vehicles from their garage
create policy "Users can delete own vehicles"
  on public.user_vehicles for delete
  to authenticated
  using (auth.uid() = user_id);

-- ---------------------------------------------
-- 5. Function to ensure single primary vehicle per user
-- ---------------------------------------------
create or replace function public.ensure_single_primary_vehicle()
returns trigger as $$
begin
  if new.is_primary = true then
    update public.user_vehicles
    set is_primary = false
    where user_id = new.user_id and id != new.id;
  end if;
  return new;
end;
$$ language plpgsql;

create trigger ensure_single_primary_vehicle_trigger
  before insert or update on public.user_vehicles
  for each row execute procedure public.ensure_single_primary_vehicle();

-- ---------------------------------------------
-- 6. Sample vehicle data
-- ---------------------------------------------
insert into public.vehicles (make, model, motorization, year, type, engine_type, fuel_type, transmission, displacement, series_number, manufacture_location, image_url) values
  (
    'Hyundai',
    'Santa Fe',
    'Essence - 3.3 4WD (199 KW / 270 CV)',
    2014,
    'SUV',
    'V6',
    'Essence',
    'Automatique',
    '3.3L',
    '123456',
    'Ulsan, Corée du Sud',
    'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800'
  ),
  (
    'Hyundai',
    'Santa Fe',
    'Diesel - 2.2 CRDi (147 KW / 200 CV)',
    2015,
    'SUV',
    'I4',
    'Diesel',
    'Automatique',
    '2.2L',
    '234567',
    'Ulsan, Corée du Sud',
    'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800'
  ),
  (
    'Toyota',
    'Camry',
    'Essence - 2.5L (133 KW / 181 CV)',
    2020,
    'Sedan',
    'I4',
    'Essence',
    'Automatique',
    '2.5L',
    '345678',
    'Georgetown, Kentucky, USA',
    'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800'
  ),
  (
    'Honda',
    'Accord',
    'Essence - 1.5T (143 KW / 194 CV)',
    2021,
    'Sedan',
    'I4 Turbo',
    'Essence',
    'CVT',
    '1.5L',
    '456789',
    'Marysville, Ohio, USA',
    'https://images.unsplash.com/photo-1590362891991-f776e747a588?w=800'
  );

-- =============================================
-- Verification queries
-- =============================================

-- Check vehicles table
select count(*) as total_vehicles from public.vehicles;

-- Check if tables were created
select 
  tablename 
from pg_tables 
where schemaname = 'public' 
  and tablename in ('vehicles', 'user_vehicles')
order by tablename;
