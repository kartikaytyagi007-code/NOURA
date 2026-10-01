# Authentication provider configuration

Status in M1: email/password, verification, recovery, session restore, refresh and sign-out are
implemented and tested with development mocks. They have **not** been verified against a live
Supabase project. Google and Apple use Supabase OAuth (browser + PKCE, decision D-011). The code is
integrated, but the providers need owner accounts before they can be verified.

## Common (every environment)

1. **Supabase project per environment** (staging, production). Use separate keys.
2. **Asymmetric JWT signing keys** (Dashboard → Project Settings → JWT Signing Keys). The API
   accepts only ES256/RS256/EdDSA tokens through JWKS (D-007).
3. **Redirect URLs** (Dashboard → Authentication → URL Configuration): add
   `noura://auth-callback` to the allow-list. The app sends it as `redirectTo` for email
   confirmation, password recovery and OAuth.
4. **Password policy**: minimum 8 characters, letters and digits (matches `supabase/config.toml`).
   Keep email confirmation on.
5. **Email templates and SMTP**: configure a production SMTP sender. Supabase's built-in sender is
   rate limited and meant for testing only.
6. **Mobile build config**: `NOURA_SUPABASE_URL` and `NOURA_SUPABASE_PUBLISHABLE_KEY` (the
   _publishable_ key only). Never use the secret or service-role key; the app refuses keys that
   look privileged.

## Google

1. Google Cloud Console → APIs & Services → Credentials → create an **OAuth client ID** of type
   _Web application_. Add the authorized redirect URI
   `https://<project-ref>.supabase.co/auth/v1/callback` (locally:
   `http://127.0.0.1:54321/auth/v1/callback`).
2. Configure the OAuth consent screen (app name, support email, privacy policy URL).
3. Supabase Dashboard → Authentication → Providers → Google: enable it and paste the client ID and
   secret. Locally, set `SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID` / `_SECRET` in `supabase/.env`
   and set `enabled = true` under `[auth.external.google]`.
4. Build the app with `NOURA_GOOGLE_SIGN_IN_ENABLED=true`.
5. Later native sign-in (not in M1) also needs Android and iOS OAuth client IDs (SHA-1 of the signing
   certificate, iOS bundle id `app.noura.noura`), listed in Supabase as additional client IDs.

## Apple

Requires a paid Apple Developer account.

1. Certificates, Identifiers & Profiles → the App ID `app.noura.noura` → enable **Sign in with
   Apple**.
2. Create a **Services ID** (this is the OAuth client ID for web/browser flows) and configure its
   return URL `https://<project-ref>.supabase.co/auth/v1/callback`.
3. Create a **Sign in with Apple key** (.p8). Supabase needs a client secret JWT generated from the
   key ID, team ID, Services ID and key. It expires after at most 6 months, so rotate it on a
   schedule. Never commit the .p8 (it is gitignored).
4. Supabase Dashboard → Authentication → Providers → Apple: enable it, add the Services ID (and the
   app bundle ID for native sign-in later) and the secret.
5. Build the app with `NOURA_APPLE_SIGN_IN_ENABLED=true`. App Store rules require Sign in with Apple
   on iOS when other third-party sign-in options are offered.

## Deep link

- Android: an intent filter for `noura://auth-callback` in `android/app/src/main/AndroidManifest.xml`.
- iOS: the `noura` URL scheme in `ios/Runner/Info.plist`.
- If the scheme changes, update both, plus `NOURA_AUTH_REDIRECT_URL` and the Supabase allow-list.
