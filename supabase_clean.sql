CREATE TABLE IF NOT EXISTS public.investigations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    wallet_address TEXT NOT NULL,
    blockchain_type TEXT NOT NULL,
    risk_score INTEGER DEFAULT 0,
    risk_level TEXT,
    balance TEXT, 
    total_tx INTEGER,
    status TEXT DEFAULT 'completed',
    analysis_payload JSONB,
    investigator_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.flagged_wallets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    wallet_address TEXT UNIQUE NOT NULL,
    threat_category TEXT NOT NULL,
    threat_name TEXT, 
    risk_level TEXT DEFAULT 'HIGH',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.monitor_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    severity TEXT NOT NULL,
    incident_msg TEXT NOT NULL,
    affected_wallet TEXT,
    tx_value TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

BEGIN;
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime FOR TABLE 
    public.monitor_logs, 
    public.investigations;
COMMIT;

ALTER TABLE public.investigations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.flagged_wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.monitor_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public Read Access" ON public.investigations FOR SELECT USING (true);
CREATE POLICY "Public Insert Access" ON public.investigations FOR INSERT WITH CHECK (true);

CREATE POLICY "Public Read Access Flagged" ON public.flagged_wallets FOR SELECT USING (true);
CREATE POLICY "Public Insert Access Flagged" ON public.flagged_wallets FOR INSERT WITH CHECK (true);

CREATE POLICY "Public Read Access Logs" ON public.monitor_logs FOR SELECT USING (true);
CREATE POLICY "Public Insert Access Logs" ON public.monitor_logs FOR INSERT WITH CHECK (true);

CREATE OR REPLACE VIEW high_risk_scans AS
SELECT * FROM public.investigations 
WHERE risk_score > 70 
ORDER BY created_at DESC;
