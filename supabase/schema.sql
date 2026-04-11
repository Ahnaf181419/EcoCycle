-- EcoCycle Supabase Database Schema
-- Run this in the Supabase SQL Editor after creating your project

-- ============================================================
-- 1. PROFILES TABLE
-- ============================================================
CREATE TABLE public.profiles (
  uid UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL,
  display_name TEXT NOT NULL,
  photo_url TEXT,
  role TEXT NOT NULL DEFAULT 'citizen' CHECK (role IN ('citizen', 'moderator', 'admin')),
  points INTEGER NOT NULL DEFAULT 0,
  redeemed_points INTEGER NOT NULL DEFAULT 0,
  classification_count INTEGER NOT NULL DEFAULT 0,
  correct_count INTEGER NOT NULL DEFAULT 0,
  is_private BOOLEAN NOT NULL DEFAULT false,
  follower_count INTEGER NOT NULL DEFAULT 0,
  following_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (uid, username, email, display_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- 2. SUBMISSIONS TABLE
-- ============================================================
CREATE TABLE public.submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(uid) ON DELETE CASCADE,
  username TEXT NOT NULL,
  image_url TEXT NOT NULL,
  storage_path TEXT NOT NULL,
  image_hash TEXT,
  category TEXT,
  subcategory TEXT,
  confidence DOUBLE PRECISION CHECK (confidence IS NULL OR (confidence >= 0.0 AND confidence <= 1.0)),
  primary_approach TEXT NOT NULL DEFAULT 'gemini' CHECK (primary_approach IN ('gemini', 'tflite', 'ensemble', 'manual')),
  state TEXT NOT NULL DEFAULT 'SUBMITTED'
    CHECK (state IN ('SUBMITTED','CLASSIFIED','VERIFIED','REWARDED','DISPUTED','RESOLVED','REJECTED','FLAGGED_DUPLICATE')),
  points_awarded INTEGER NOT NULL DEFAULT 0,
  idempotency_key TEXT NOT NULL UNIQUE,
  flagged_reason TEXT,
  duplicate_of UUID REFERENCES public.submissions(id) ON DELETE SET NULL,
  classified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 3. CLASSIFICATIONS TABLE
-- ============================================================
CREATE TABLE public.classifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_id UUID NOT NULL REFERENCES public.submissions(id) ON DELETE CASCADE,
  approach TEXT NOT NULL CHECK (approach IN ('gemini', 'tflite', 'ensemble', 'manual')),
  category TEXT NOT NULL,
  subcategory TEXT,
  confidence DOUBLE PRECISION NOT NULL CHECK (confidence >= 0.0 AND confidence <= 1.0),
  model_version TEXT NOT NULL,
  raw_response JSONB,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 4. DISPUTES TABLE
-- ============================================================
CREATE TABLE public.disputes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_id UUID NOT NULL REFERENCES public.submissions(id) ON DELETE CASCADE,
  submitter_id UUID NOT NULL REFERENCES public.profiles(uid) ON DELETE CASCADE,
  original_category TEXT NOT NULL,
  original_confidence DOUBLE PRECISION NOT NULL CHECK (original_confidence >= 0.0 AND original_confidence <= 1.0),
  secondary_category TEXT,
  secondary_confidence DOUBLE PRECISION CHECK (secondary_confidence IS NULL OR (secondary_confidence >= 0.0 AND secondary_confidence <= 1.0)),
  resolved_category TEXT,
  resolved_by UUID REFERENCES public.profiles(uid) ON DELETE SET NULL,
  resolution TEXT,
  resolution_note TEXT,
  status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','APPROVED','OVERRIDDEN','REJECTED')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  resolved_at TIMESTAMPTZ
);

-- ============================================================
-- 5. REWARDS TABLE
-- ============================================================
CREATE TABLE public.rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(uid) ON DELETE CASCADE,
  submission_id UUID REFERENCES public.submissions(id) ON DELETE SET NULL,
  points INTEGER NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('CLASSIFICATION','REDEMPTION','DISPUTE_BONUS')),
  idempotency_key TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 6. FOLLOWS TABLE
-- ============================================================
CREATE TABLE public.follows (
  follower_id UUID NOT NULL REFERENCES public.profiles(uid) ON DELETE CASCADE,
  followee_id UUID NOT NULL REFERENCES public.profiles(uid) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (follower_id, followee_id),
  CHECK (follower_id != followee_id)
);

-- ============================================================
-- 7. AUDIT LOG TABLE
-- ============================================================
CREATE TABLE public.audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type TEXT NOT NULL,
  actor_id UUID NOT NULL,
  actor_role TEXT NOT NULL,
  target_type TEXT NOT NULL,
  target_id TEXT NOT NULL,
  details JSONB NOT NULL DEFAULT '{}',
  timestamp TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 8. CONFIG TABLE
-- ============================================================
CREATE TABLE public.config (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL
);

-- Seed default config
INSERT INTO public.config (key, value) VALUES ('system', '{
  "confidenceThreshold": 0.7,
  "pointsPerCategory": {"organic": 10, "recyclable": 15, "hazardous": 20, "general": 5},
  "duplicateTimeWindowHours": 24,
  "maxDailySubmissions": 50,
  "leaderboardCacheSeconds": 300
}') ON CONFLICT (key) DO NOTHING;

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================
CREATE OR REPLACE FUNCTION public.increment_profile_points(
  user_id UUID,
  amount INTEGER
)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET points = points + amount,
      classification_count = classification_count + 1
  WHERE public.profiles.uid = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.increment_correct_count(
  p_user_id UUID
)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles SET correct_count = correct_count + 1 WHERE uid = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.atomic_increment_follow(
  p_follower_id UUID,
  p_followee_id UUID
)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles SET following_count = following_count + 1 WHERE uid = p_follower_id;
  UPDATE public.profiles SET follower_count = follower_count + 1 WHERE uid = p_followee_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.atomic_decrement_follow(
  p_follower_id UUID,
  p_followee_id UUID
)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles SET following_count = GREATEST(following_count - 1, 0) WHERE uid = p_follower_id;
  UPDATE public.profiles SET follower_count = GREATEST(follower_count - 1, 0) WHERE uid = p_followee_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.atomic_redeem_points(
  p_user_id UUID,
  p_points INTEGER,
  p_idempotency_key TEXT
)
RETURNS JSONB AS $$
DECLARE
  v_available INTEGER;
  v_profile RECORD;
BEGIN
  SELECT points, redeemed_points INTO v_profile FROM public.profiles WHERE uid = p_user_id FOR UPDATE;
  v_available := v_profile.points - v_profile.redeemed_points;
  IF v_available < p_points THEN
    RETURN jsonb_build_object('error', 'Insufficient points', 'available', v_available);
  END IF;
  UPDATE public.profiles SET redeemed_points = redeemed_points + p_points WHERE uid = p_user_id;
  INSERT INTO public.rewards (user_id, points, type, idempotency_key)
    VALUES (p_user_id, -p_points, 'REDEMPTION', p_idempotency_key)
    ON CONFLICT (idempotency_key) DO NOTHING;
  RETURN jsonb_build_object('availableBalance', v_available - p_points);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_submissions_user_id ON public.submissions(user_id);
CREATE INDEX idx_submissions_created_at ON public.submissions(created_at DESC);
CREATE INDEX idx_submissions_state ON public.submissions(state);
CREATE INDEX idx_submissions_idempotency_key ON public.submissions(idempotency_key);
CREATE INDEX idx_submissions_image_hash ON public.submissions(image_hash);

CREATE INDEX idx_classifications_submission_id ON public.classifications(submission_id);

CREATE INDEX idx_disputes_status ON public.disputes(status);
CREATE INDEX idx_disputes_submitter_id ON public.disputes(submitter_id);
CREATE INDEX idx_disputes_submission_id ON public.disputes(submission_id);

CREATE INDEX idx_rewards_user_id ON public.rewards(user_id);
CREATE INDEX idx_rewards_created_at ON public.rewards(created_at DESC);
CREATE INDEX idx_rewards_idempotency_key ON public.rewards(idempotency_key);

CREATE INDEX idx_follows_follower_id ON public.follows(follower_id);
CREATE INDEX idx_follows_followee_id ON public.follows(followee_id);

CREATE INDEX idx_audit_log_timestamp ON public.audit_log(timestamp DESC);
CREATE INDEX idx_audit_log_actor_id ON public.audit_log(actor_id);

CREATE INDEX idx_profiles_points ON public.profiles(points DESC);
CREATE INDEX idx_profiles_username ON public.profiles(username);

-- ============================================================
-- UPDATED_AT TRIGGER (auto-update updated_at on row change)
-- ============================================================
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER submissions_updated_at
  BEFORE UPDATE ON public.submissions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

-- PROFILES
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profiles are viewable by everyone"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = uid);

CREATE POLICY "Users can delete their own profile"
  ON public.profiles FOR DELETE
  USING (auth.uid() = uid);

-- SUBMISSIONS
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Submissions viewable by owner or public profiles"
  ON public.submissions FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert submissions"
  ON public.submissions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own submissions"
  ON public.submissions FOR UPDATE
  USING (auth.uid() = user_id);

-- CLASSIFICATIONS
ALTER TABLE public.classifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Classifications are viewable by everyone"
  ON public.classifications FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert classifications"
  ON public.classifications FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- DISPUTES
ALTER TABLE public.disputes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Disputes viewable by owner or moderators"
  ON public.disputes FOR SELECT
  USING (
    auth.uid() = submitter_id
    OR EXISTS (
      SELECT 1 FROM public.profiles
      WHERE uid = auth.uid() AND role IN ('moderator', 'admin')
    )
  );

CREATE POLICY "Authenticated users can insert disputes"
  ON public.disputes FOR INSERT
  WITH CHECK (auth.uid() = submitter_id);

CREATE POLICY "Moderators can update disputes"
  ON public.disputes FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE uid = auth.uid() AND role IN ('moderator', 'admin')
    )
  );

-- REWARDS
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own rewards"
  ON public.rewards FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "System can insert rewards"
  ON public.rewards FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- FOLLOWS
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Follows are viewable by everyone"
  ON public.follows FOR SELECT
  USING (true);

CREATE POLICY "Users can insert their own follows"
  ON public.follows FOR INSERT
  WITH CHECK (auth.uid() = follower_id);

CREATE POLICY "Users can delete their own follows"
  ON public.follows FOR DELETE
  USING (auth.uid() = follower_id);

-- AUDIT LOG
ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Audit log viewable by admins only"
  ON public.audit_log FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE uid = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "System can insert audit log entries"
  ON public.audit_log FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- CONFIG
ALTER TABLE public.config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Config is readable by everyone"
  ON public.config FOR SELECT
  USING (true);

CREATE POLICY "Only admins can update config"
  ON public.config FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE uid = auth.uid() AND role = 'admin'
    )
  );

-- ============================================================
-- RPC FUNCTIONS FOR EFFICIENT COUNTS
-- ============================================================
CREATE OR REPLACE FUNCTION public.count_users()
RETURNS TABLE(count BIGINT) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::BIGINT FROM public.profiles;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.count_submissions()
RETURNS TABLE(count BIGINT) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::BIGINT FROM public.submissions;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.count_pending_disputes()
RETURNS TABLE(count BIGINT) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::BIGINT FROM public.disputes WHERE status = 'PENDING';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- REALTIME PUBLICATIONS
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
ALTER PUBLICATION supabase_realtime ADD TABLE public.submissions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.classifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.disputes;
ALTER PUBLICATION supabase_realtime ADD TABLE public.rewards;
ALTER PUBLICATION supabase_realtime ADD TABLE public.follows;
ALTER PUBLICATION supabase_realtime ADD TABLE public.audit_log;

-- ============================================================
-- STORAGE BUCKET
-- ============================================================
-- Run in the SQL editor or create via Supabase Dashboard:
-- INSERT INTO storage.buckets (id, name, public)
--   VALUES ('submissions', 'submissions', true)
--   ON CONFLICT (id) DO NOTHING;

-- Storage policies for the submissions bucket:
-- CREATE POLICY "Authenticated users can upload"
--   ON storage.objects FOR INSERT
--   WITH CHECK (bucket_id = 'submissions' AND auth.uid() IS NOT NULL);

-- CREATE POLICY "Anyone can view submissions"
--   ON storage.objects FOR SELECT
--   USING (bucket_id = 'submissions');

-- CREATE POLICY "Users can delete their own uploads"
--   ON storage.objects FOR DELETE
--   USING (bucket_id = 'submissions' AND auth.uid()::text = storage.foldername[1]);
