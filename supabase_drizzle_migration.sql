-- =========================================================================
-- SUPABASE POSTGRESQL MIGRATION (Scoped by User ID for Auth integration)
-- =========================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. DROP OLD TABLES (If applying over the previous un-scoped schema)
DROP TABLE IF EXISTS public.transactions CASCADE;
DROP TABLE IF EXISTS public.investigations CASCADE;
DROP TABLE IF EXISTS public.flagged_wallets CASCADE;

-- 2. CREATE NEW AUTHORIZED TABLES
-- Wallet Searches (Now scoped to `user_id` linked to Supabase Auth)
CREATE TABLE public.wallet_searches (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    wallet_address TEXT NOT NULL,
    blockchain_type TEXT NOT NULL, -- 'ETH' or 'BTC'
    risk_score INTEGER DEFAULT 0,
    risk_level TEXT,
    balance TEXT,
    total_tx INTEGER,
    status TEXT DEFAULT 'completed',
    analysis_payload JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Transactions (Linked both to search AND `user_id` for extra security filtering)
CREATE TABLE public.transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    search_id UUID REFERENCES public.wallet_searches(id) ON DELETE CASCADE,
    tx_hash TEXT NOT NULL,
    from_address TEXT NOT NULL,
    to_address TEXT NOT NULL,
    value TEXT,
    is_suspicious BOOLEAN DEFAULT false,
    block_timestamp TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Flagged Wallets (Intelligence data specific to the authenticated user's organization or profile)
CREATE TABLE public.flagged_wallets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    wallet_address TEXT NOT NULL,
    threat_category TEXT NOT NULL,
    threat_name TEXT, 
    risk_level TEXT DEFAULT 'HIGH',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, wallet_address) -- Ensure users don't flag the same wallet twice
);

-- 3. ENABLE ROW LEVEL SECURITY (RLS) FOR ALL TABLES
ALTER TABLE public.wallet_searches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.flagged_wallets ENABLE ROW LEVEL SECURITY;

-- 4. CREATE SECURITY POLICIES (Users can ONLY view/insert their own data)
-- For Wallet Searches
CREATE POLICY "Users can insert their own searches" ON public.wallet_searches 
    FOR INSERT WITH CHECK (auth.uid() = user_id);
    
CREATE POLICY "Users can view their own searches" ON public.wallet_searches 
    FOR SELECT USING (auth.uid() = user_id);

-- For Transactions
CREATE POLICY "Users can insert their own tx logs" ON public.transactions 
    FOR INSERT WITH CHECK (auth.uid() = user_id);
    
CREATE POLICY "Users can view their own tx logs" ON public.transactions 
    FOR SELECT USING (auth.uid() = user_id);

-- For Flagged Wallets
CREATE POLICY "Users can manage custom flagged wallets" ON public.flagged_wallets 
    FOR ALL USING (auth.uid() = user_id);

-- 5. REALTIME INTEGRATION (Ensure UI stays snappy)
BEGIN;
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime FOR TABLE 
    public.wallet_searches, 
    public.flagged_wallets,
    public.monitor_logs; -- Assuming monitor_logs was kept from earlier
COMMIT;
