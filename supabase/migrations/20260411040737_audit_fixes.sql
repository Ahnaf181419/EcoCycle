-- Migration: Audit fix session
-- Run this in the Supabase SQL Editor

-- 1. New atomic helper functions
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

-- 2. Missing index
CREATE INDEX IF NOT EXISTS idx_disputes_submission_id ON public.disputes(submission_id);
