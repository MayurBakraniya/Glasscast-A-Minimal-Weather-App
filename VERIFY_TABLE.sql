-- Verify and Fix favorite_cities table
-- Run this in Supabase SQL Editor to check your table structure

-- Step 1: Check if table exists and see its structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'favorite_cities'
ORDER BY ordinal_position;

-- Step 2: If the table has wrong column names, drop and recreate
-- (Only run this if Step 1 shows wrong column names)

-- DROP TABLE IF EXISTS public.favorite_cities CASCADE;

-- CREATE TABLE public.favorite_cities (
--   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
--   user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
--   city_name TEXT NOT NULL,
--   lat DOUBLE PRECISION NOT NULL,
--   lon DOUBLE PRECISION NOT NULL,
--   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
-- );

-- Step 3: Verify RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename = 'favorite_cities';

-- Step 4: Check policies
SELECT policyname, cmd, qual, with_check
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename = 'favorite_cities';
