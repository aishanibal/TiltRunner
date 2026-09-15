# TiltRunner server

REST API backend for the TiltRunner leaderboard. Uses the Firebase Admin SDK
to read/write the `scores` collection in the same Firestore database the app
uses, but with server credentials instead of the client SDK.

## Endpoints

- `POST /scores` — body `{ "name": string, "score": integer }`, returns `{ "id": string }`
- `GET /scores/top?limit=10` — returns the top scores, highest first

## Local setup

1. In the Firebase console: Project settings → Service accounts → **Generate new private key**. This downloads a JSON file.
2. Save it as `server/serviceAccountKey.json` (already gitignored — never commit this file).
3. Install dependencies and run:

```bash
cd server
npm install
npm run dev
```

4. Test it:

```bash
curl -X POST localhost:3000/scores -H 'Content-Type: application/json' -d '{"name":"AB","score":42}'
curl localhost:3000/scores/top
```

## Deploying

Set `FIREBASE_SERVICE_ACCOUNT_BASE64` as an environment variable on the host
(instead of shipping `serviceAccountKey.json`):

```bash
base64 -i serviceAccountKey.json | tr -d '\n'
```

Paste the output as the env var's value on whatever platform you deploy to
(Render, Railway, etc.), along with `PORT` if the platform requires you to
set it explicitly.
