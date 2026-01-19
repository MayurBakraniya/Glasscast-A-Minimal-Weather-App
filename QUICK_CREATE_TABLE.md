# ⚡ QUICK FIX: Create Table in Supabase

## The Problem
Error: `Could not find the table 'public.favorite_cities' in the schema cache`

This means the table doesn't exist in your Supabase database yet.

## ✅ Solution (2 Minutes)

### Step 1: Open Supabase
1. Go to https://supabase.com
2. Sign in
3. Click on your project

### Step 2: Open SQL Editor
1. Look at the **left sidebar**
2. Click on **"SQL Editor"** (it has a database icon)
3. Click **"New Query"** button (top right)

### Step 3: Copy This SQL
Copy **ALL** of this code:

```sql
CREATE TABLE public.favorite_cities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  city_name TEXT NOT NULL,
  lat DOUBLE PRECISION NOT NULL,
  lon DOUBLE PRECISION NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.favorite_cities ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own cities"
  ON public.favorite_cities FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cities"
  ON public.favorite_cities FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own cities"
  ON public.favorite_cities FOR DELETE
  USING (auth.uid() = user_id);
```

### Step 4: Paste and Run
1. Paste the SQL into the editor
2. Click the **"Run"** button (or press `Cmd + Enter`)
3. Wait for "Success" message

### Step 5: Verify
1. Click **"Table Editor"** in left sidebar
2. You should see **"favorite_cities"** in the list
3. Click on it to see the columns

### Step 6: Test App
1. Close and restart your app
2. Go to Search tab
3. Error should be gone! ✅

---

## 🎯 Visual Guide

```
Supabase Dashboard
    │
    ├─ SQL Editor ← Click here
    │   │
    │   ├─ New Query ← Click this
    │   │
    │   └─ Paste SQL code
    │       │
    │       └─ Click "Run" button
    │
    └─ Table Editor ← Check here after
        │
        └─ favorite_cities ← Should appear here
```

---

## ❌ Still Not Working?

### Check These:
1. ✅ Are you in the correct Supabase project?
2. ✅ Did you click "Run" after pasting the SQL?
3. ✅ Did you see a "Success" message?
4. ✅ Did you refresh the Table Editor page?

### If Table Still Doesn't Appear:
1. Go back to SQL Editor
2. Run this to check:
```sql
SELECT * FROM information_schema.tables 
WHERE table_name = 'favorite_cities';
```
3. If it returns empty, the table wasn't created - try the SQL again

---

## 📱 After Creating Table

Once the table is created:
- ✅ The error will stop appearing
- ✅ You can add cities to favorites
- ✅ Favorites will be saved to Supabase
- ✅ Favorites will sync across devices

**The app will work perfectly once the table exists!**
