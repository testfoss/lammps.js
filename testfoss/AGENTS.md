# Testfoss fork instructions

## Source boundary

- Testfoss source is pinned at `c6e5499716c87ba688d60e9b90edbc49d5fb748c` on branch `testfoss-demo`.
- Keep upstream source, manifests and lockfiles, C++/LAMMPS build files, `AGENTS.md`, `CLAUDE.md`, and existing workflows unchanged.
- Additions are limited to the appended README section, `durable-memory/**`, `testfoss/**`, and `.github/workflows/testfoss.yml`. The root `AGENTS.md` remains the upstream symlink to `CLAUDE.md`.
- Do not commit tarballs, `dist`, build trees, `node_modules`, tool caches, screenshots, or logs. No secrets, deployment, or publication are part of this track.
- Preserve the GPLv2 `LICENSE` and the `MIT` package manifest declaration unchanged. Their conflict is documented without silently resolving it.

## Reproduction

Use Emscripten 4.0.18 from emsdk repository revision `1693ce7359fc9694f198694f902a2cc061239b86`. Do not carry the lab's `MAKE_JOBS` patch; the pristine build script chooses parallelism itself.

```sh
npm ci
npm test
npm run test:atomify-serial
npm run build:kokkos
npm run build:atomify
npx vitest run
npm run verify:pack
npm --prefix examples/pages ci
npm --prefix examples/pages run build
testfoss/scripts/install-browser-tools.sh --with-deps chromium
testfoss/scripts/run-pages-browser.sh
```

Set `EMSDK_PATH` to the SDK directory for engine commands. Browser tools are pinned to `@lmctl-ai/lmctl@0.2.454` and `lmctl-ai/lmwebtest@2920befd355eacc654697820d690db074e94dce3`. Every browser job invokes `lmwebtest` through a `.lms` program with `cli="lmwebtest playwright"`.
