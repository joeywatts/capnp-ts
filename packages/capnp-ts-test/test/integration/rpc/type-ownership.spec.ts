import tap from "tap";
import { Conn } from "capnp-ts";
import { StreamResult } from "capnp-ts/src/std/stream.capnp.js";
import { Base } from "./type-ownership/base.capnp.js";
import { Leaf } from "./type-ownership/leaf.capnp.js";
import { Events } from "./type-ownership/streaming.capnp.js";
import { DerivedEvents } from "./type-ownership/derived-stream.capnp.js";
import { TestTransport } from "./test-transport.js";

void tap.test("three-file inherited method retains its declaring types and identity", async (t) => {
  t.setTimeout(5000);
  t.equal(Leaf.Client.methods[0].interfaceId, Base.Client.interfaceId);
  t.equal(Leaf.Client.methods[0].methodId, 0);
  t.equal(Leaf.Client.methods[0].ParamsClass, Base.Client.methods[0].ParamsClass);
  const [clientT, serverT] = TestTransport.pair();
  const server = new Conn(serverT, { main: new Leaf.Server({ ping: (_p, r) => r.setValue(37) }) });
  const client = new Conn(clientT);
  try {
    t.equal((await client.bootstrap(Leaf).ping()).getValue(), 37);
  } finally {
    client.close();
    server.close();
  }
});

void tap.test("inherited streaming uses the canonical imported result type", async (t) => {
  t.setTimeout(5000);
  t.equal(Events.Client.methods[0].ResultsClass, StreamResult);
  t.equal(DerivedEvents.Client.methods[0].ResultsClass, StreamResult);
  t.equal(DerivedEvents.Client.methods[0].interfaceId, Events.Client.interfaceId);
  let calls = 0;
  const [clientT, serverT] = TestTransport.pair();
  const server = new Conn(serverT, {
    main: new DerivedEvents.Server({
      activated: () => {
        calls++;
      },
    }),
  });
  const client = new Conn(clientT);
  try {
    await client.bootstrap(DerivedEvents).activated();
    t.equal(calls, 1);
  } finally {
    client.close();
    server.close();
  }
});
