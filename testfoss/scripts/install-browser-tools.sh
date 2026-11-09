#!/usr/bin/env bash
set -euo pipefail

TESTFOSS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS="$TESTFOSS_ROOT/.tools"
LMCTL_VERSION="0.2.454"
LMWEBTEST_SHA="2920befd355eacc654697820d690db074e94dce3"

mkdir -p "$TOOLS/bin"
if [ ! -x "$TOOLS/lmctl/node_modules/.bin/lmscript" ]; then
  npm install --prefix "$TOOLS/lmctl" --no-audit --no-fund "@lmctl-ai/lmctl@$LMCTL_VERSION"
fi
if [ ! -d "$TOOLS/lmwebtest/.git" ]; then
  git clone https://github.com/lmctl-ai/lmwebtest.git "$TOOLS/lmwebtest"
fi
git -C "$TOOLS/lmwebtest" checkout --detach "$LMWEBTEST_SHA"
npm --prefix "$TOOLS/lmwebtest" ci --no-audit --no-fund
cat > "$TOOLS/bin/lmwebtest" <<EOF
#!/usr/bin/env bash
exec node "$TOOLS/lmwebtest/src/cli.js" "\$@"
EOF
chmod +x "$TOOLS/bin/lmwebtest"
export PATH="$TOOLS/lmctl/node_modules/.bin:$TOOLS/bin:$PATH"
if [ "$#" -eq 0 ]; then
  set -- chromium
fi
"$TOOLS/lmwebtest/node_modules/.bin/playwright" install "$@"
lmscript --version
lmwebtest --version
lmwebtest playwright --lmcode-signatures > /dev/null
