-- Run this once in your Supabase project's SQL Editor (Supabase dashboard -> SQL Editor -> New query -> paste all -> Run)

create extension if not exists pgcrypto;

create table if not exists settings (
  key text primary key,
  value text
);

create table if not exists divisions (
  slug text primary key,
  name text not null,
  units jsonb not null,
  passcode text not null
);

create table if not exists registrations (
  id uuid primary key default gen_random_uuid(),
  division_slug text references divisions(slug),
  name text not null,
  mobile text not null,
  whatsapp text,
  unit text,
  designation text,
  created_at timestamptz default now()
);

create table if not exists voice_announcement (
  id int primary key default 1,
  title text,
  mime text,
  data text,
  updated_at timestamptz default now()
);

-- Row Level Security: open to the anon key, since there is no separate server.
-- The app's passcodes and master password are the only gate on the admin views;
-- see the README for what this does and does not protect against.
alter table settings enable row level security;
alter table divisions enable row level security;
alter table registrations enable row level security;
alter table voice_announcement enable row level security;

create policy "settings read" on settings for select using (true);
create policy "settings write" on settings for insert with check (true);
create policy "settings update" on settings for update using (true);

create policy "divisions read" on divisions for select using (true);
create policy "divisions update" on divisions for update using (true);

create policy "registrations read" on registrations for select using (true);
create policy "registrations insert" on registrations for insert with check (true);

create policy "voice read" on voice_announcement for select using (true);
create policy "voice write" on voice_announcement for insert with check (true);
create policy "voice update" on voice_announcement for update using (true);

-- Seed data: master password + all 25 divisions with their units and a starting passcode.
-- Change these passcodes from the dashboard (or right here) after setup.
insert into settings (key, value) values ('master_password', 'admin-2026')
  on conflict (key) do nothing;

insert into divisions (slug, name, units, passcode) values
('saham','SAHAM','["BIDAYA SOUQ","HIJARI","KHABURA","MUKHAILIF","SAHAM EAST","SAHAM SOUQ"]'::jsonb,'4821'),
('falaj','FALAJ','["FALAJ TOWN","GAIL SHIBOOL","SOHAR SANAYIYA","SOHAR TARIFF","SOHAR TOWN"]'::jsonb,'3390'),
('liwa','LIWA','["ASRAR","LIWA SOUQ","SHINAS R/A"]'::jsonb,'7654'),
('buraimi','BURAIMI','["ALI SAIF","BURAIMI - KHADHRA","BURAIMI MAHALA","BURAIMI MARKET","BURAIMI SARA"]'::jsonb,'2210'),
('khasab','KHASAB','["KHASAB IRANI SOUQ","KHASAB NEW SOUQ","KHASAB SANAYYA"]'::jsonb,'5083'),
('barka-east','BARKA EAST','["AL MURAYSI","BARAKA MAIN ROAD","HYSALAM","NAKHAL","RUMAYS"]'::jsonb,'6749'),
('muladda','MULADDA','["KHADHRAH","OM-AL SAWADI","SHUAIBA","SUWAIQ","TAREEF","THARMATH"]'::jsonb,'1937'),
('rustaq','RUSTAQ','["AWABI","RUSTAQ BP","RUSTAQ SOUQ"]'::jsonb,'8402'),
('barka-west','BARKA WEST','["BARAKA SANAYA","BARAKA SOUQ","BARKA LULU","SUMHAN","UQDAH"]'::jsonb,'5561'),
('ruwi','RUWI','["AL FALAH","HAMRIYYA","HIGH STREET","QURM","RUWI REX ROAD","WADI KABEER"]'::jsonb,'2098'),
('mutrah','MUTRAH','["DARSAIT","MUTRAH SOUQ","OMAN HOUSE","SIDAB"]'::jsonb,'7734'),
('al-khuwair','AL KHUWAIR','["AL KHUWAIR SOUQ","BILAD BOUSHER","GHUBRA EAST","GHUBRA WEST","PANORAMA MALL","ZAWAWI"]'::jsonb,'3156'),
('azaiba','AZAIBA','["ANSAB","GHALA NORTH","GHALA SOUTH","SIBIC"]'::jsonb,'9042'),
('wadi-hatat','WADI HATAT','["AMIRAT","QURIYATH","WADI HATAT NO. 6","WADI HATAT SOUQ"]'::jsonb,'4487'),
('nizwa','NIZWA','["ADAM","BAHLA","FIRQ","KARSHA","NIZWA TOWN"]'::jsonb,'6023'),
('ibri','IBRI','["AL ARAQI","IBRI MAIN ROAD","IBRI MURTAFA","IBRI SOUQ","YANQUL"]'::jsonb,'1875'),
('jaalan','JAALAN','["AL KAMIL","AL WAFI","BU ALI","SHAABIYA"]'::jsonb,'5390'),
('sur','SUR','["BILAD","SHARIYA","SUR SOUQ"]'::jsonb,'2764'),
('raysut','RAYSUT','["AL WADI","AWQAD","GHARBIYA","SALALA MALL"]'::jsonb,'8619'),
('darbat','DARBAT','["AL QARDH","DAHARIZ","HAFA","MIRBAT","NO 5-SALALAH","TAQA"]'::jsonb,'3345'),
('al-salam','AL SALAM','["NEW SALALAH","POWER HOUSE-SALALAH","SALALAH TOWN","ZAWIYA"]'::jsonb,'7012'),
('razat','RAZAT','["AL SAADA","JARBEEB","SAHALNOOT","SHABIYAT","THUMRAIT"]'::jsonb,'4958'),
('al-hail','AL HAIL','["CITY CENTRE","HAIL NORTH","HAIL SOUTH","RUSAYL","SEEB SOUQ"]'::jsonb,'6281'),
('maabela','MAABELA','["AL KHOUDH SOUQ","ALKHOUDH 6","MAABELA BP","MOBELA SOUTH","SANAIYYA"]'::jsonb,'1503'),
('samail','SAMAIL','["FANJA","JIFNAIN","MISFA","SAMAYL SOUQ"]'::jsonb,'9377')
on conflict (slug) do nothing;
