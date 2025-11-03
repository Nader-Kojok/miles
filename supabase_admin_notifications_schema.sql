-- Admin notifications history table
create table if not exists public.admin_notifications (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  message text not null,
  type text not null check (type in ('order_update', 'promotion', 'price_drop', 'back_in_stock', 'custom')),
  target_type text not null check (target_type in ('all', 'specific', 'segment')),
  target_user_ids uuid[],
  target_segment text,
  image_url text,
  action_url text,
  scheduled_for timestamp with time zone,
  onesignal_id text,
  sent_by uuid references public.profiles(id) on delete set null not null,
  status text default 'sent' check (status in ('sent', 'scheduled', 'failed')),
  recipients_count integer default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Indexes
create index if not exists admin_notifications_sent_by_idx on public.admin_notifications(sent_by);
create index if not exists admin_notifications_created_at_idx on public.admin_notifications(created_at desc);
create index if not exists admin_notifications_status_idx on public.admin_notifications(status);
create index if not exists admin_notifications_type_idx on public.admin_notifications(type);

-- RLS Policies
alter table public.admin_notifications enable row level security;

-- Only admins can view admin notifications
create policy "Admins can view admin notifications"
  on public.admin_notifications for select
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and is_admin = true
    )
  );

-- Only admins can insert admin notifications
create policy "Admins can insert admin notifications"
  on public.admin_notifications for insert
  with check (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and is_admin = true
    )
  );

-- Function to get notification statistics
create or replace function get_notification_stats()
returns json
language plpgsql
security definer
as $$
declare
  result json;
begin
  select json_build_object(
    'total_sent', count(*),
    'total_recipients', coalesce(sum(recipients_count), 0),
    'by_type', (
      select json_object_agg(type, count)
      from (
        select type, count(*) as count
        from public.admin_notifications
        group by type
      ) t
    ),
    'by_status', (
      select json_object_agg(status, count)
      from (
        select status, count(*) as count
        from public.admin_notifications
        group by status
      ) t
    )
  ) into result
  from public.admin_notifications;
  
  return result;
end;
$$;
