# Andi AI Search API Documentation

Documentation site for the Andi AI Search API, built on [Mintlify](https://mintlify.com) and hosted at [docs.andiai.com](https://docs.andiai.com).

## Development

Install the [Mintlify CLI](https://www.npmjs.com/package/mint) (requires Node.js v20.17.0+ LTS):

```bash
npm i -g mint
```

Run the local dev server:

```bash
mint dev
```

Preview at `http://localhost:3000`.

## Validation

```bash
mint validate        # Validate documentation builds
mint broken-links    # Check internal links
```

## Testing

API tests verify that documented parameters, response formats, and error handling match the live API.

**Prerequisites:** `jq` (`brew install jq`)

**Setup:**

```bash
cp .env.example .env    # Then add your API key
```

**Run tests:**

```bash
./tests/run-tests.sh              # All suites
./tests/run-tests.sh auth errors  # Specific suites
./tests/run-tests.sh --list       # List available suites
```

Mintlify validation (`mint validate`, `mint broken-links`, `mint openapi-check`) runs automatically at the end if the `mint` CLI is installed.

## SEO

- **OG image**: `docs.json` → `thumbnails` sets the background (`images/og-default.png`). Mintlify auto-generates OG images with logo, title, and description overlay.
- **Metatags**: `docs.json` → `seo.metatags` sets `og:site_name` and `twitter:site`.
- **Organization JSON-LD**: `organization-schema.js` — injected on every page via Mintlify custom scripts. Links docs.andiai.com into the Andi entity graph.
- **Robots**: `robots.txt` — overrides Mintlify default. Explicitly allows AI crawlers (GPTBot, ClaudeBot, PerplexityBot).
- **Analytics**: `posthog-analytics.js` — loads PostHog via custom script (the Mintlify `integrations.posthog` config doesn't work on the deployed site).

Per-page SEO in frontmatter:
- `keywords`: YAML array for Mintlify internal search
- `noindex: true`: Prevent indexing (for stub pages)

## Publishing

Changes pushed to `main` auto-deploy via the Mintlify GitHub app.
