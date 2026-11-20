# Contributing
All questions live in `assets/questions.json` — no Dart needed. Add to a persona's `questions` list:
- `mcq`, `fake`, `citation`, `review`: `{"type","q","options":[...],"answer":<index>,"why"}`
- `order`: `{"type":"order","q","items":[correct order...],"why"}`

Each level draws a random subset, so bigger pools = more replay value. Goal: 15–20 per persona.
Run `flutter analyze && flutter test` before opening a PR. Be kind; cite sources in `why` where possible.
