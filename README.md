# 🔎 Learn to Research
Open-source Flutter trivia game that teaches real-world research skills. Play from **Noob Student → Master's → PhD → Postdoc → Professor** with questions, ordering tasks, fake-source spotting, citation fixing and mock peer review. Optional global leaderboard via Supabase. MIT licensed.

## Setup
```bash
git clone <https://github.com/haniyaa007/learn-to-research.git> && cd learn_to_research
flutter create --org com.yourname --project-name learn_to_research --platforms=android,ios .
flutter pub get
flutter run                      # offline mode, no leaderboard
```
`flutter create .` generates the `android/` and `ios/` folders without touching `lib/`.

## Leaderboard (Supabase, free tier)
1. Create a project at supabase.com. 2. Run `supabase/schema.sql` in the SQL Editor.
3. Copy Project URL + anon key (Settings → API; the anon key is safe to ship thanks to RLS).
```bash
flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=xxxx
```
Use the same `--dart-define` flags on release builds. Scores are client-submitted and spoofable; for strict anti-cheat use an Edge Function.

## Deploy to Google Play
1. Play Console developer account ($25 once). 2. Set a unique `applicationId` in `android/app/build.gradle`.
3. Create a keystore: `keytool -genkey -v -keystore upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload` and reference it in `android/key.properties` (gitignored).
4. `flutter build appbundle --release --dart-define=...` → upload `build/app/outputs/bundle/release/app-release.aab`.
5. Fill the store listing, content rating, Data safety form, and add a privacy policy URL. New personal accounts need a 14-day closed test with 12 testers before production.

## Deploy to the App Store
1. Apple Developer Program ($99/yr), Mac with Xcode. 2. `open ios/Runner.xcworkspace`, set Bundle ID + Team, signing.
3. `flutter build ipa --release --dart-define=...` then upload via Transporter/Xcode Organizer.
4. In App Store Connect: screenshots, description, age rating, privacy "nutrition labels", privacy policy URL; submit for review.

## Before launch checklist
App icon (`flutter_launcher_icons`), splash screen, privacy policy (nicknames and scores are collected), custom art/sounds in `assets/`, and more questions.

## Assets
Avatars (`assets/avatars/*.png`) and sound effects (`assets/audio/*.wav`) are procedurally generated placeholders; replace files with the same names to upgrade the art/audio. Each level draws 8 random questions from a 15-question bank per character.

## Contributing
See CONTRIBUTING.md.
