/* 
  ==========================================================================
  CRYPTOTRACE - SUPABASE DATABASE MASTER SETUP
  ==========================================================================
  
  -- [ PROVIDER CREDENTIALS ] --
  --------------------------------------------------------------------------
  PROJECT URL:     https://your-project-url.supabase.co
  PUBLISHABLE KEY: your-public-anon-key
  ANON KEY:        your-public-anon-key
  --------------------------------------------------------------------------

  INSTRUCTIONS:
  1. Copy ALL content below.
  2. Go to your Supabase Dashboard -> SQL Editor.
  3. Create a "New Query", paste this code, and click "Run".
*/

-- 1. SETUP BASE TABLES
--------------------------------------------------------------------------

-- Table: Investigations (Main wallet scan records)
CREATE TABLE IF NOT EXISTS public.investigations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    wallet_address TEXT NOT NULL,
    blockchain_type TEXT NOT NULL, -- 'ETH' or 'BTC'
    risk_score INTEGER DEFAULT 0,
    risk_level TEXT, -- 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
    balance TEXT,
    total_tx INTEGER,
    status TEXT DEFAULT 'completed',
    analysis_payload JSONB, -- Stores the full visual graph and tx history
    investigator_id TEXT, -- Optional: for multi-user support
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Table: Flagged Intelligence (Dark Web Threat Database)
CREATE TABLE IF NOT EXISTS public.flagged_wallets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    wallet_address TEXT UNIQUE NOT NULL,
    threat_category TEXT NOT NULL, -- 'Mixer', 'Hacker', 'Exchange', 'Scam'
    threat_name TEXT, 
    risk_level TEXT DEFAULT 'HIGH',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Table: Live Alerts (Real-time monitoring feed)
CREATE TABLE IF NOT EXISTS public.monitor_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    severity TEXT NOT NULL, -- 'CRITICAL', 'WARNING', 'INFO'
    incident_msg TEXT NOT NULL,
    affected_wallet TEXT,
    tx_value TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. ENABLE REALTIME CAPABILITIES
--------------------------------------------------------------------------
-- This allows the React dashboard to "listen" for new alerts instantly.

BEGIN;
  -- Drop existing publication if it exists to avoid errors on re-run
  DROP PUBLICATION IF EXISTS supabase_realtime;
  
  -- Create new publication for the tables we want to track live
  CREATE PUBLICATION supabase_realtime FOR TABLE 
    public.monitor_logs, 
    public.investigations;
COMMIT;

-- 3. PERMISSIONS & SECURITY
--------------------------------------------------------------------------
-- Enable Row Level Security (RLS)
ALTER TABLE public.investigations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.flagged_wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.monitor_logs ENABLE ROW LEVEL SECURITY;

-- Create Public Read/Write Policies (For development - You can restrict these later)
CREATE POLICY "Public Read Access" ON public.investigations FOR SELECT USING (true);
CREATE POLICY "Public Insert Access" ON public.investigations FOR INSERT WITH CHECK (true);

CREATE POLICY "Public Read Access Flagged" ON public.flagged_wallets FOR SELECT USING (true);
CREATE POLICY "Public Insert Access Flagged" ON public.flagged_wallets FOR INSERT WITH CHECK (true);

CREATE POLICY "Public Read Access Logs" ON public.monitor_logs FOR SELECT USING (true);
CREATE POLICY "Public Insert Access Logs" ON public.monitor_logs FOR INSERT WITH CHECK (true);


-- 4. HELPER VIEWS (Optional)
--------------------------------------------------------------------------
-- View to see high risk scans only
CREATE OR REPLACE VIEW high_risk_scans AS
SELECT * FROM public.investigations 
WHERE risk_score > 70 
ORDER BY created_at DESC;

-- ==========================================================================
-- SETUP COMPLETE
-- ==========================================================================
