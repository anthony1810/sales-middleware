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
The end-to-end job runs only when triggered by hand. There is no hosted deployment, on
purpose: this submission is reviewed later, a free hosting service may be asleep or gone by
then, and `swift run` always works. Full design decisions are documented at the end of the
project.
