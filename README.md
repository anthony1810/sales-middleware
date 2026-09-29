# sales-middleware

A small Swift server with one endpoint, `GET /rates`. It consumes the upstream currency
pairs, derives the missing inverse rates, solves every currency's conversion chain with a
breadth-first search, and returns one direct-to-USD rate per currency. It exists so that no
client app ever duplicates the conversion logic.

## Run it

```
swift run --package-path Server
```

No setup is needed: the port defaults to 8080 and the upstream URL defaults to the real
backend. Environment variables `PORT` and `UPSTREAM_URL` override both.

```
curl http://localhost:8080/rates
```

Expected shape (values as strings, so exact decimals survive the wire):

```json
{ "rates": { "USD": "1", "EUR": "1.18", "GBP": "1.3216", "INR": "0.0119...", ... } }
```

## Test it

```
swift test --package-path RatesCore
swift test --package-path HTTPClient
swift test --package-path Server
```

All of the above are offline and fast. The live end-to-end check against the real upstream
runs on demand:

```
swift test --package-path RatesAPIEndToEndTests
```

Open `sales-middleware.xcworkspace` to work with every package in one Xcode window.

## Packages

- `RatesCore`: the pure solver. `RateTable`, derived inverses, breadth-first search,
  `SolveDirectRates`. Exact `Decimal` math, no framework imports.
- `Server`: `RatesUpstreamAPI` (endpoint mapping), `RatesCache` (60 second cache and
  stale-on-error fallback), `RatesTransport` (the only target importing Hummingbird), and
  `ServerMain` (the composition root).
- `HTTPClient` and `TestSupport`: shared infrastructure modules.
- `RatesAPIEndToEndTests`: the on-demand live check.

## CI/CD

Every push runs all offline suites on Linux (`swift:6.1` container) with warnings treated
as errors, and builds the release binary to prove each commit produces a runnable server.
The end-to-end job runs only when triggered by hand.

## The companion app

`sales-ios` is the iOS client. It calls `GET /rates` and never converts a currency itself,
which is the whole reason this service exists. Start this server before opening the app if
you want to see US dollar amounts; without it the app still works and says "USD unavailable"
instead. On a physical device set `RATES_BASE_URL` to your Mac's IP in the app's scheme,
because `localhost` there means the phone.

## Decisions worth explaining

**Breadth-first search, from USD outwards.** The upstream gives eight pairs in mixed
directions. Rather than walking from each currency towards USD, the solver reverses every
edge and walks outwards from USD once. That visits each currency a single time, in O(V+E),
and the first path found is the one with the fewest conversions, which keeps the rounding
chain short.

**Derived inverses, never overwriting.** The upstream lists `EUR -> USD` but not
`USD -> EUR`. Missing directions are added as `1/rate`. A direction the upstream actually
provided is always kept, because their number is authoritative and ours is derived.

**Non-positive rates are dropped at the door.** A zero or negative rate would produce an
infinity or a negative price through `1/rate`. `RateTable` filters them on construction, so
no later stage has to defend against it.

**`Decimal` everywhere, and rates leave as strings.** Written as a Swift literal, `1.18`
becomes `1.1799999999999997952`. Amounts stay exact `Decimal` inside, and the response sends
them as JSON strings so the client can parse them exactly too. A review suggested decoding
upstream numbers straight into `Decimal`; that was declined, because `JSONDecoder` routes
through `Double` and would reintroduce the error this design removes.

**One cache, three behaviours.** `CachingRatesLoader` holds the solved table for 60 seconds,
collapses concurrent misses into a single upstream request, and `StaleOnErrorRatesLoader`
serves the last good table if the upstream fails. A client asking twice in a second causes
one upstream call, and a brief upstream outage does not become an outage here.

**Hummingbird lives in one target.** `RatesTransport` is the only place that imports it.
Everything else, including the solver, is plain Swift. Swapping the web framework would
touch one target.

**No Docker and no hosting.** The reviewer runs `swift run` and it works. A free hosting
service can be asleep or deleted by the time this is read, so a live URL would be a risk
rather than a convenience. A release build runs on every commit to prove the binary still
works.
