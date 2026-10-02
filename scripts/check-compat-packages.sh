#!/bin/sh
# Run after make build. Validate the actual distributable packages, not workspace links.
set -eu
root=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
probe=$(mktemp -d)
trap 'rm -rf "$probe"' EXIT HUP INT TERM
cd "$root"
npm pack --workspace capnp-ts --pack-destination "$probe" --quiet
npm pack --workspace capnpc-ts --pack-destination "$probe" --quiet
printf '%s\n' '{"private":true}' > "$probe/package.json"
npm install --prefix "$probe" --ignore-scripts --no-audit --no-fund "$probe/"*.tgz
mkdir "$probe/generic"
cp packages/capnp-ts-test/test/integration/rpc/type-ownership/*.capnp "$probe/generic/"
capnp compile --src-prefix="$probe/generic" "-o$probe/node_modules/.bin/capnpc-ts:$probe/generic" "$probe/generic/"*.capnp
# Indirect standard import spellings are not necessarily present in leaf-only requests.
capnp compile --src-prefix="$probe/generic" "-o$probe/node_modules/.bin/capnpc-ts:$probe/generic" "$probe/generic/derived-stream.capnp"
capnp compile --src-prefix="$probe/generic" "-o$probe/node_modules/.bin/capnpc-ts:$probe/generic" "$probe/generic/leaf.capnp"
node "$root/node_modules/typescript/bin/tsc" --ignoreConfig --noEmit --strict --skipLibCheck false \
  --target ES2022 --module Node16 --moduleResolution Node16 --lib ES2022,DOM,ESNext.Disposable "$probe/generic/"*.d.ts
node - "$probe" <<'JS'
const assert = require('node:assert/strict');
const {createRequire} = require('node:module');
const requirePacked = createRequire(process.argv[2] + '/package.json');
const {StreamResult} = requirePacked('capnp-ts/src/std/stream.capnp.js');
const {DerivedEvents} = requirePacked('./generic/derived-stream.capnp.js');
const {Base} = requirePacked('./generic/base.capnp.js');
const {Leaf} = requirePacked('./generic/leaf.capnp.js');
assert.equal(DerivedEvents.Client.methods[0].ResultsClass, StreamResult);
assert.equal(Leaf.Client.methods[0].ParamsClass, Base.Client.methods[0].ParamsClass);
assert.match(require('node:fs').readFileSync(requirePacked.resolve('capnp-ts/LICENSE.stream.md'), 'utf8'), /Copyright.*Cloudflare/);
console.log('Packed runtime/compiler install, strict declarations, leaf-only generation, type identity and license checks passed.');
JS
