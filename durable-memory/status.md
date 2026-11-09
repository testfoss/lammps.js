# Testfoss lammps.js status

## Exact pins

- lammps.js: `c6e5499716c87ba688d60e9b90edbc49d5fb748c`, package version 1.6.2, branch `testfoss-demo`.
- Emscripten manifest: 4.0.18.
- emsdk repository used for reproducible installation: `1693ce7359fc9694f198694f902a2cc061239b86`.
- LAMMPS tag in the untouched `cpp/build.py`: `stable_30Sep2026_update1`; the lab observed commit `098ffdefa525cabc82272925de02e9884f58c657`.
- Browser host: `lmctl-ai/lmwebtest@2920befd355eacc654697820d690db074e94dce3`.
- LMS runner: `@lmctl-ai/lmctl@0.2.454`.
- Actions use full commit SHAs with `contents: read` and no persisted checkout credentials.

## Build, test, package, and browser commands

The workflow uses Node.js 24 and runs from the repository root:

```sh
npm ci
source "$HOME/emsdk/emsdk_env.sh"
export EMSDK_PATH="$HOME/emsdk"
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

The emsdk installation first checks out `1693ce7359fc9694f198694f902a2cc061239b86` and runs `emsdk install 4.0.18` and `emsdk activate 4.0.18`. The workflow timeout is 180 minutes because all four C++/Wasm variants are compiled in one job.

`npm test` builds and tests the default engine. The next three build commands add atomify-serial, KOKKOS, and threaded Atomify. The final full Vitest run exercises every available variant. `npm run verify:pack` performs a dry-run package check and rejects missing exports or stub Wasm; it requires all four variants and does not publish or create a committed tarball.

The existing Pages example is built with its unchanged `file:../..` dependency. `testfoss/browser/pages.lms` runs a short real LJ simulation through `lmwebtest playwright`, checks engine output and browser errors, and writes only ignored local results. No deployment or npm publication follows.

## Prior local evidence and current boundary

The earlier isolated lab run at the same source pin recorded 161 passing tests and 3 intentional guards skipped after all variants were built, followed by successful package verification. That run used a local `MAKE_JOBS=2` patch to control C++ parallelism.

The public Testfoss track deliberately does not carry that patch. The pristine pinned `cpp/build.py` uses `os.cpu_count()` directly; `MAKE_JOBS` is not a supported override. CI therefore relies on the runner's available CPU count and has a long timeout rather than modifying upstream build logic.

## Limitations and licensing

- The workflow builds all variants but the browser check uses the default engine only. KOKKOS browser behavior is covered by engine tests, not claimed as a separate Pages browser result.
- Upstream compiler warnings, the pthread `ALLOW_MEMORY_GROWTH` warning, and dependency audit findings are not broadly patched.
- The existing Pages demo is the browser integration target; the separate three.js and notebook deployments are not built by this track.
- The upstream `LICENSE` is GNU GPLv2, while upstream `package.json` declares `MIT`. This conflict is unresolved upstream metadata. Both are preserved byte-for-byte; review licensing before redistribution.
- No tarballs, `dist`, C++ build trees, tool checkouts, `node_modules`, screenshots, logs, secrets, deployment credentials, or publication steps are committed.
