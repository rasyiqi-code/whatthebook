# Supabase RLS Policy Fix for Reviews Table

The delete review operation is failing because of Row Level Security (RLS) policies. Here are the SQL commands to fix this:

## 1. Enable RLS on reviews table (if not already enabled)
```sql
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
```

## 2. Create/Update RLS Policy for DELETE operations
```sql
-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Users can delete their own reviews" ON reviews;

-- Create new policy for DELETE
CREATE POLICY "Users can delete their own reviews" ON reviews
FOR DELETE USING (auth.uid() = user_id);
```

## 3. Ensure other policies exist for full CRUD
```sql
-- Policy for SELECT (read reviews)
DROP POLICY IF EXISTS "Reviews are viewable by everyone" ON reviews;
CREATE POLICY "Reviews are viewable by everyone" ON reviews
FOR SELECT USING (true);

-- Policy for INSERT (create reviews)
DROP POLICY IF EXISTS "Users can insert their own reviews" ON reviews;
CREATE POLICY "Users can insert their own reviews" ON reviews
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy for UPDATE (edit reviews)
DROP POLICY IF EXISTS "Users can update their own reviews" ON reviews;
CREATE POLICY "Users can update their own reviews" ON reviews
FOR UPDATE USING (auth.uid() = user_id);
```

## 4. Alternative: Disable RLS temporarily for testing
If you want to test without RLS (not recommended for production):
```sql
ALTER TABLE reviews DISABLE ROW LEVEL SECURITY;
```

## 5. Check current policies
```sql
SELECT * FROM pg_policies WHERE tablename = 'reviews';
```

## 6. Verify the fix
After applying the policies, try deleting a review again. The operation should work properly.

## Common Issues:
1. **RLS not enabled** → Enable RLS first
2. **Missing DELETE policy** → Create the DELETE policy
3. **Wrong user_id column** → Make sure the policy uses the correct column name
4. **auth.uid() not working** → Check if the user is properly authenticated

Run these SQL commands in your Supabase SQL editor to fix the delete review functionality. 