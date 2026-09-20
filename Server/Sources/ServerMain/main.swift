import Foundation
import HTTPClientLive
import Hummingbird
import RatesCache
import RatesCore
import RatesTransport
import RatesUpstreamAPI

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

let configuration = ServerConfiguration(environment: ProcessInfo.processInfo.environment)

let remote = RemoteRatesLoader(
    url: configuration.upstreamURL,
    client: URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
)
let cached = CachingRatesLoader(ttl: .seconds(60), clock: ContinuousClock(), loader: remote.load)
let resilient = StaleOnErrorRatesLoader(loader: cached.load)
let solve = SolveDirectRates(target: "USD", loadRates: resilient.load)

let app = Application(
    router: RatesRoutes.router(solve: solve.execute),
    configuration: .init(address: .hostname("0.0.0.0", port: configuration.port))
)
try await app.runService()
