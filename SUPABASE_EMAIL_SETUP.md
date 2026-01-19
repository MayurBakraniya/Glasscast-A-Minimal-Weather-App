# Supabase Email Confirmation Setup

## Issue: "Email not found" after Sign Up

If you're experiencing issues where you can sign up but then can't log in with the same credentials, it's likely due to Supabase email confirmation settings.

## Solution: Disable Email Confirmation (For Development)

For development and testing, you can disable email confirmation:

1. Go to your Supabase project dashboard
2. Navigate to **Authentication** → **Settings**
3. Scroll down to **Email Auth** section
4. Find **"Enable email confirmations"**
5. **Turn OFF** email confirmations
6. Click **Save**

## Alternative: Keep Email Confirmation Enabled

If you want to keep email confirmation enabled:

1. After signing up, check your email inbox
2. Click the confirmation link in the email
3. Then try logging in again

## Testing the Fix

After disabling email confirmation:

1. Sign up with a new email
2. You should be automatically signed in
3. Sign out
4. Sign in with the same credentials
5. It should work without issues

## Production Considerations

For production apps:
- Keep email confirmation enabled for security
- Users will need to confirm their email before first login
- The app now shows helpful messages when email confirmation is needed

## Current App Behavior

The app now:
- ✅ Automatically signs you in if email confirmation is disabled
- ✅ Shows a message if email confirmation is required
- ✅ Provides a "Resend Confirmation Email" button
- ✅ Shows clear error messages for login issues
