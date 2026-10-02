# Cap'n Proto Standard Libary Files

These files are the underpinning of much of the RPC and code generation portions of the library.

They were copied directly from https://github.com/sandstorm-io/capnproto/tree/41264ae6deb85ee9d9756e88293c856f7e9fe9d9/c%2B%2B/src/capnp.

`schemas/stream.capnp` (at the repository root) is from Cap'n Proto v1.1.0:
https://github.com/capnproto/capnproto/blob/v1.1.0/c%2B%2B/src/capnp/stream.capnp
Its full Cloudflare MIT notice is retained in the schema, the checked-in generated binding, and `LICENSE.stream.md` in the npm package.
The normal `make build` compiles `stream.capnp.ts` to JavaScript and declarations,
like the other standard bindings. This binding enables
the schema's backwards-compatible empty-result RPC representation only. It does not
implement streaming flow control, serialized TypeScript server dispatch, or failure poisoning.
