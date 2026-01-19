-- Fix favorite_cities table structure
-- Run this in Supabase SQL Editor

-- IMPORTANT: First run VERIFY_TABLE.sql to check your current table structure!

-- Step 1: Drop the existing table if it has wrong structure
-- WARNING: This will delete all existing favorite cities!
DROP TABLE IF EXISTS public.favorite_cities CASCADE;

-- Step 2: Create the table with correct column names
CREATE TABLE public.favorite_cities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  city_name TEXT NOT NULL,
  lat DOUBLE PRECISION NOT NULL,
  lon DOUBLE PRECISION NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 3: Enable Row Level Security
ALTER TABLE public.favorite_cities ENABLE ROW LEVEL SECURITY;

-- Step 4: Create policies for user-specific access
CREATE POLICY "Users can view own cities"
  ON public.favorite_cities FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cities"
  ON public.favorite_cities FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own cities"
  ON public.favorite_cities FOR DELETE
  USING (auth.uid() = user_id);

-- Step 5: Verify the table structure
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'favorite_cities' 
AND table_schema = 'public'
ORDER BY ordinal_position;
