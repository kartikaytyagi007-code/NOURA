# Authentication provider configuration

NOURA signs users in with **phone number + one-time SMS code only** (decision D-033). There are no
passwords, no email accounts, and no Google/Apple sign-in. The first successful code verification
creates the account; after that the same two steps sign the user back in.

Status: the flow is implemented and tested against the development mock (which accepts only the
code `123456`). It has **not** been verified against a live Supabase project or a real SMS gateway.

## How sessions work

- `supabase_flutter` stores the session on the device and refreshes the access token
  (`jwt_expiry`, 1 hour) with the refresh token. The user stays signed in across restarts for as
  long as the session can be refreshed.
- The session ends when the user signs out, the refresh token is revoked or stops working, or a
  configured session limit is reached. The app then returns to the welcome screen with
  "Your session ended. Verify your number again to continue." and the user requests a new code.
- A hard maximum session length (`[auth.sessions] timebox` / `inactivity_timeout`) is a Supabase
  paid-plan feature and is not set. Choosing one is a release decision.

## Common (every environment)

1. **Supabase project per environment** (staging, production). Use separate keys.
2. **Asymmetric JWT signing keys** (Dashboard → Project Settings → JWT Signing Keys). The API
   accepts only ES256/RS256/EdDSA tokens through JWKS (D-007). Nothing in the API depends on the
   sign-in method.
3. **Providers** (Dashboard → Authentication → Sign In / Providers):
   - **Phone: enabled**, with an SMS provider (below). Keep "Confirm phone" on.
   - **Email: disabled.** Also turn off "Allow new users to sign up" for email.
   - Google, Apple and every other provider: disabled.
4. **SMS OTP settings**: 6-digit code, short expiry (Supabase default 60 seconds is fine; up to a
   few minutes is reasonable for slow Indian SMS delivery). Keep the SMS rate limits on
   (Dashboard → Authentication → Rate Limits). Consider CAPTCHA (`[auth.captcha]`) to limit SMS
   pumping fraud before a public launch.
5. **Mobile build config**: `NOURA_SUPABASE_URL` and `NOURA_SUPABASE_PUBLISHABLE_KEY` (the
   _publishable_ key only). Never use the secret or service-role key; the app refuses keys that
   look privileged. No redirect URL or deep link is needed any more.

## SMS provider

Supabase sends codes through Twilio, Twilio Verify, MessageBird, Vonage or Textlocal, or through a
**Send SMS hook** for any other gateway (for example an Indian provider such as MSG91). The provider
credentials live only in Supabase, never in the app or this repository.

1. Create an account with the chosen provider and buy/register a sender.
2. **India (TRAI DLT):** commercial SMS to Indian numbers must use a DLT-registered entity, sender
   ID (header) and message template. Register the template text from `supabase/config.toml`
   (`[auth.sms] template`) exactly, or SMS to Indian numbers will be dropped.
3. Supabase Dashboard → Authentication → Providers → Phone: choose the provider and paste its
   credentials. Locally, set e.g. `SUPABASE_AUTH_SMS_TWILIO_AUTH_TOKEN` in `supabase/.env` and set
   `enabled = true` under `[auth.sms.twilio]`.
4. Every code sent costs money. Watch the provider's spend dashboard and keep rate limits on.

## Local development without SMS

- `NOURA_USE_MOCKS=true` (development debug builds only): no Supabase, no SMS; the code is `123456`.
- Against the local Supabase stack: `supabase/config.toml` maps the fake number `+91 90000 00001`
  to the code `123456` under `[auth.sms.test_otp]`. Never configure test numbers on a hosted
  project.
