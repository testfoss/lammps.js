# Testfoss lammps.js engine and browser demo

This additive track uses pristine `lammps.js` source at `c6e5499716c87ba688d60e9b90edbc49d5fb748c`, Emscripten 4.0.18, and the LAMMPS tag selected by the unchanged `cpp/build.py`. It does not carry the isolated lab's `MAKE_JOBS` build patch.

## Reproduce

Install the Emscripten SDK at the exact repository revision used by the lab, then activate the manifest version:

```sh
git clone https://github.com/emscripten-core/emsdk.git "$HOME/emsdk"
git -C "$HOME/emsdk" checkout --detach 1693ce7359fc9694f198694f902a2cc061239b86
"$HOME/emsdk/emsdk" install 4.0.18
"$HOME/emsdk/emsdk" activate 4.0.18
source "$HOME/emsdk/emsdk_env.sh"
export EMSDK_PATH="$HOME/emsdk"
```

Use Node.js 24 and npm. Build and test every engine variant before verifying the complete package:

```sh
npm ci
npm test
npm run test:atomify-serial
npm run build:kokkos
npm run build:atomify
npx vitest run
npm run verify:pack
```

`verify:pack` requires all four Wasm modules to be real, non-stub builds; running only the default build is insufficient. These are expensive C++ builds and the pristine script chooses its own parallelism with `os.cpu_count()`.

Build the existing Pages example against the locally built root package and drive it through the pinned browser host:

```sh
npm --prefix examples/pages ci
npm --prefix examples/pages run build
testfoss/scripts/install-browser-tools.sh --with-deps chromium
testfoss/scripts/run-pages-browser.sh
```

The final command serves the production Pages build on port 4173 and runs `browser/pages.lms` via `lmscript` and `lmwebtest playwright`. It substitutes a short 20-step LJ input in the editable demo and checks 108 created atoms, normal Loop time, 20 completed steps, cross-origin isolation, and uncaught browser errors. The example's existing `file:../..` dependency means this is the locally built engine, not a registry package. Results go to ignored `testfoss/results/`.

The tool bootstrap pins `@lmctl-ai/lmctl@0.2.454` and `lmctl-ai/lmwebtest@2920befd355eacc654697820d690db074e94dce3`. Set `LAMMPS_PAGES_PORT` or `LAMMPS_PAGES_URL` to override the preview location.

## License metadata warning

The upstream `LICENSE` file is GNU GPLv2 while upstream `package.json` declares `MIT`. That inconsistency is preserved and documented, not resolved by this demo. Review the upstream licensing before redistribution. Neither file is modified by the Testfoss track.
