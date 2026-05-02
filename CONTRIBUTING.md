# Contributing

Changes must pass the full check before merge:

```bash
make check
```

This runs `fmt-check` (nixfmt), `lint` (deadnix + statix), and `flake-check`. Lint is strict: no suppression of W20/W04; fix repeated keys and use `inherit` where appropriate.
