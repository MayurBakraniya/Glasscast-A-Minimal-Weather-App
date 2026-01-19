# Step-by-Step: Create favorite_cities Table in Supabase

## Method 1: Using SQL Editor (Recommended)

### Step 1: Open Supabase Dashboard
1. Go to [supabase.com](https://supabase.com)
2. Sign in to your account
3. Select your project (or create a new one if you don't have one)

### Step 2: Open SQL Editor
1. In the left sidebar, click **SQL Editor**
2. Click **New Query** button (top right)

### Step 3: Copy and Paste This SQL
Copy the entire SQL below and paste it into the SQL Editor:

```sql
-- Create favorite_cities table
CREATE TABLE public.favorite_cities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  city_name TEXT NOT NULL,
  lat DOUBLE PRECISION NOT NULL,
  lon DOUBLE PRECISION NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.favorite_cities ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can view their own cities
CREATE POLICY "Users can view own cities"
  ON public.favorite_cities FOR SELECT
  USING (auth.uid() = user_id);

-- Create policy: Users can insert their own cities
CREATE POLICY "Users can insert own cities"
  ON public.favorite_cities FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create policy: Users can delete their own cities
CREATE POLICY "Users can delete own cities"
  ON public.favorite_cities FOR DELETE
  USING (auth.uid() = user_id);
```

### Step 4: Run the SQL
1. Click the **Run** button (or press `Cmd + Enter` on Mac / `Ctrl + Enter` on Windows)
2. Wait for it to complete (should show "Success" message)

### Step 5: Verify Table Was Created
1. In the left sidebar, click **Table Editor**
2. You should now see `favorite_cities` in the list
3. Click on it to see the table structure

---

## Method 2: Using Table Editor (Alternative)

### Step 1: Open Table Editor
1. In Supabase dashboard, click **Table Editor** in left sidebar
2. Click **New Table** button

### Step 2: Create Table
1. **Table name**: `favorite_cities`
2. Click **Create table**

### Step 3: Add Columns
Click **Add Column** for each column below:

1. **id**
   - Type: `uuid`
   - Default value: `gen_random_uuid()`
   - Primary key: ✅ (check this)
   - Nullable: ❌ (uncheck)

2. **user_id**
   - Type: `uuid`
   - Foreign key: ✅
   - References: `auth.users(id)`
   - On delete: `CASCADE`
   - Nullable: ❌

3. **city_name**
   - Type: `text`
   - Nullable: ❌

4. **lat**
   - Type: `double precision`
   - Nullable: ❌

5. **lon**
   - Type: `double precision`
   - Nullable: ❌

6. **created_at**
   - Type: `timestamptz`
   - Default value: `now()`
   - Nullable: ❌

### Step 4: Enable RLS
1. Click on the table name `favorite_cities`
2. Go to **Policies** tab
3. Click **Enable RLS** if not already enabled

### Step 5: Create Policies
Click **New Policy** for each:

1. **Policy Name**: "Users can view own cities"
   - Allowed operation: `SELECT`
   - Policy definition: `auth.uid() = user_id`

2. **Policy Name**: "Users can insert own cities"
   - Allowed operation: `INSERT`
   - Policy definition: `auth.uid() = user_id`

3. **Policy Name**: "Users can delete own cities"
   - Allowed operation: `DELETE`
   - Policy definition: `auth.uid() = user_id`

---

## Troubleshooting

### If you see "relation already exists" error:
The table already exists. Run this to drop it first:
```sql
DROP TABLE IF EXISTS public.favorite_cities CASCADE;
```
Then run the CREATE TABLE SQL again.

### If you don't see the table after creating:
1. Refresh the page (F5 or Cmd+R)
2. Check you're in the correct project
3. Look in **Table Editor** → should see `favorite_cities`

### If you see permission errors:
Make sure you're the project owner or have admin access.

---

## Verify Table Structure

After creating, run this to verify:

```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'favorite_cities' 
AND table_schema = 'public'
ORDER BY ordinal_position;
```

You should see:
- id (uuid)
- user_id (uuid)
- city_name (text)
- lat (double precision)
- lon (double precision)
- created_at (timestamp with time zone)

---

**Once the table is created, restart your app and try adding a favorite city again!**
