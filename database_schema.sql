-- ========================================================
-- CRYPTOTRACE - SUPABASE DATABASE CONFIGURATION & SCHEMA
-- ========================================================

/*
  INSTRUCTIONS:
  1. Go to your Supabase Project Settings > API.
  2. Copy the credentials below and save them in your .env files.
  3. Run the SQL schema below in the Supabase SQL Editor.

  --- SUPABASE CREDENTIALS ---
  PROJECT_URL: https://your-project-id.supabase.co
  PUBLISHABLE_KEY (API Key): your-anon-public-key
  ANON_KEY (Legacy): your-anon-public-key
  -----------------------------
*/

-- 1. Investigations Table
-- Stores the results of every wallet scan
CREATE TABLE IF NOT EXISTS public.investigations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    wallet_address TEXT NOT NULL,
    blockchain_type TEXT NOT NULL, -- 'ETH' or 'BTC'
    risk_score INTEGER DEFAULT 0,
    balance TEXT,
    total_tx INTEGER,
    status TEXT DEFAULT 'completed',
    analysis_data JSONB, -- Stores the full analysis payload
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Transactions Table
-- Stores specific transaction details linked to an investigation
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    investigation_id UUID REFERENCES public.investigations(id) ON DELETE CASCADE,
    tx_hash TEXT NOT NULL,
    from_address TEXT NOT NULL,
    to_address TEXT NOT NULL,
    value TEXT,
    block_timestamp TIMESTAMP WITH TIME ZONE,
    is_suspicious BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Flagged Wallets Table (Intelligence)
-- A database of known bad actors (Hackers, Mixers, etc.)
CREATE TABLE IF NOT EXISTS public.flagged_wallets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    wallet_address TEXT UNIQUE NOT NULL,
    category TEXT NOT NULL, -- e.g., 'Mixer', 'Lazarus Group', 'Exchange Hot Wallet'
    owner_name TEXT,
    risk_level TEXT DEFAULT 'HIGH', -- 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Monitor Logs Table
-- For real-time updates in the Live Monitoring dashboard
CREATE TABLE IF NOT EXISTS public.monitor_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    type TEXT NOT NULL, -- 'CRITICAL', 'WARNING', 'INFO'
    message TEXT NOT NULL,
    target_wallet TEXT,
    amount TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. Enable Realtime
-- This allows the React frontend to listen for new alerts as they happen
ALTER PUBLICATION supabase_realtime ADD TABLE public.monitor_logs;
ALTER PUBLICATION supabase_realtime ADD TABLE public.investigations;

-- 6. Indices for performance
CREATE INDEX IF NOT EXISTS idx_investigations_wallet ON public.investigations(wallet_address);
CREATE INDEX IF NOT EXISTS idx_flagged_wallets_address ON public.flagged_wallets(wallet_address);
CREATE INDEX IF NOT EXISTS idx_transactions_investigation ON public.transactions(investigation_id);

-- ========================================================
-- END OF SCHEMA
-- ========================================================
