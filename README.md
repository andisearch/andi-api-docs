# Andi Search API Documentation

Documentation site for the Andi Search API, built on [Mintlify](https://mintlify.com) and hosted at [docs.andiai.com](https://docs.andiai.com).

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

## Publishing

Changes pushed to `main` auto-deploy via the Mintlify GitHub app.
