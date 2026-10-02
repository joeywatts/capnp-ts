# Inherited method type compatibility

This branch fixes generated imports for methods inherited through multiple schema files,
respects the declaring module of explicit parameter/result types, and packages the
standard `StreamResult` binding. It leaves wire IDs and method ordinals unchanged.

Validation after `npm ci --ignore-scripts` (Node 20+, Cap'n Proto compiler installed):

```sh
make clean
make test
scripts/check-compat-packages.sh
```

The integration regression covers a three-file inheritance chain and inherited streaming
method result identity and dispatch. The package check builds npm tarballs, installs them
into a temporary project, generates all fixtures and then leaves individually, strictly
checks declarations, verifies canonical constructor identity, and checks the shipped
standard-schema license. It does not install unbuilt monorepo Git sources.

The binding provides only the standard schema's backwards-compatible empty-result RPC
representation. Calls still await ordinary RPC completion. TypeScript server dispatch is
not made serial for streaming methods; an error does not poison subsequent calls on that
capability; automatic sender flow control is not implemented. These need a separate
runtime design and implementation, with ordering, failure, disconnect and resource-limit
regressions. No complete streaming conformance is claimed here.

`schemas/stream.capnp` comes unchanged from Cap'n Proto v1.1.0. Its Cloudflare MIT notice
is retained in the schema, generated TypeScript binding, and runtime package license file.
The existing project license and upstream attribution are unchanged.
