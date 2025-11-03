-- Notifications table for push notifications
create table if not exists public.notifications (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  body text not null,
  type text not null check (type in ('order_update', 'promotion', 'price_drop', 'back_in_stock', 'custom')),
  user_id uuid references public.profiles(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  order_id uuid references public.orders(id) on delete set null,
  data jsonb default '{}'::jsonb,
  is_read boolean default false,
  sent_at timestamp with time zone default timezone('utc'::text, now()) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- FCM tokens table to store device tokens
create table if not exists public.fcm_tokens (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  token text not null unique,
  device_type text check (device_type in ('ios', 'android', 'web')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Indexes for performance
create index if not exists notifications_user_id_idx on public.notifications(user_id);
create index if not exists notifications_created_at_idx on public.notifications(created_at desc);
create index if not exists notifications_is_read_idx on public.notifications(is_read);
create index if not exists fcm_tokens_user_id_idx on public.fcm_tokens(user_id);
create index if not exists fcm_tokens_token_idx on public.fcm_tokens(token);

-- RLS Policies
alter table public.notifications enable row level security;
alter table public.fcm_tokens enable row level security;

-- Users can only see their own notifications
create policy "Users can view their own notifications"
  on public.notifications for select
  using (auth.uid() = user_id);

-- Users can update their own notifications (mark as read)
create policy "Users can update their own notifications"
  on public.notifications for update
  using (auth.uid() = user_id);

-- Admins can insert notifications (will be handled via admin dashboard API)
create policy "Admins can insert notifications"
  on public.notifications for insert
  with check (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and is_admin = true
    )
  );

-- Users can manage their own FCM tokens
create policy "Users can manage their own FCM tokens"
  on public.fcm_tokens for all
  using (auth.uid() = user_id);

-- Function to mark all notifications as read
create or replace function mark_all_notifications_read(p_user_id uuid)
returns void
language plpgsql
security definer
as $$
begin
  update public.notifications
  set is_read = true
  where user_id = p_user_id and is_read = false;
end;
$$;

-- Function to delete old notifications (cleanup)
create or replace function delete_old_notifications()
returns void
language plpgsql
security definer
as $$
begin
  delete from public.notifications
  where created_at < now() - interval '90 days';
end;
$$;
