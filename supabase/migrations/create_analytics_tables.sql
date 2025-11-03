-- Analytics Events Table
-- Stores all analytics events tracked in the app
CREATE TABLE IF NOT EXISTS analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_name TEXT NOT NULL,
  event_params JSONB DEFAULT '{}'::jsonb,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  platform TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Analytics User Properties Table
-- Stores user-specific properties for analytics
CREATE TABLE IF NOT EXISTS analytics_user_properties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  property_name TEXT NOT NULL,
  property_value TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, property_name)
);

-- Indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_analytics_events_user_id ON analytics_events(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_events_event_name ON analytics_events(event_name);
CREATE INDEX IF NOT EXISTS idx_analytics_events_timestamp ON analytics_events(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_analytics_events_params ON analytics_events USING gin(event_params);
CREATE INDEX IF NOT EXISTS idx_analytics_user_properties_user_id ON analytics_user_properties(user_id);

-- Enable Row Level Security
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_user_properties ENABLE ROW LEVEL SECURITY;

-- RLS Policies for analytics_events
-- Users can insert their own events
CREATE POLICY "Users can insert own analytics events"
  ON analytics_events
  FOR INSERT
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Users can view their own events
CREATE POLICY "Users can view own analytics events"
  ON analytics_events
  FOR SELECT
  USING (auth.uid() = user_id OR user_id IS NULL);

-- Admin can view all events (optional - uncomment and adjust based on your needs)
-- Note: Only enable this if you have an admin role system in your profiles table
-- CREATE POLICY "Admins can view all analytics events"
--   ON analytics_events
--   FOR SELECT
--   USING (
--     EXISTS (
--       SELECT 1 FROM profiles
--       WHERE profiles.id = auth.uid()
--       AND profiles.is_admin = true  -- Adjust this based on your actual admin field
--     )
--   );

-- RLS Policies for analytics_user_properties
-- Users can manage their own properties
CREATE POLICY "Users can manage own properties"
  ON analytics_user_properties
  FOR ALL
  USING (auth.uid() = user_id);

-- Optional: Create a view for analytics dashboard
CREATE OR REPLACE VIEW analytics_dashboard AS
SELECT 
  event_name,
  COUNT(*) as event_count,
  COUNT(DISTINCT user_id) as unique_users,
  DATE_TRUNC('day', timestamp) as event_date
FROM analytics_events
GROUP BY event_name, DATE_TRUNC('day', timestamp);

-- Grant access to authenticated users
GRANT SELECT ON analytics_dashboard TO authenticated;

-- Comments for documentation
COMMENT ON TABLE analytics_events IS 'Stores all analytics events tracked in the Bolide app';
COMMENT ON TABLE analytics_user_properties IS 'Stores user-specific analytics properties';
COMMENT ON COLUMN analytics_events.event_name IS 'Name of the tracked event (e.g., product_view, add_to_cart)';
COMMENT ON COLUMN analytics_events.event_params IS 'JSON object containing event parameters';
COMMENT ON COLUMN analytics_events.platform IS 'Platform where event occurred (android, ios, web, etc.)';
