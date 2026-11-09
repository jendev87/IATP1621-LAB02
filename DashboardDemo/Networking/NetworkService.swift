//
//  NetworkService.swift
//  DashboardDemo
//
//  Low-level URLSession & decoding
//

import Foundation

/// Errors that can occur during network requests and response decoding.
enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(String)
    case underlying(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The requested URL is invalid."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .httpError(let statusCode):
            return "Server returned an error status code: \(statusCode)."
        case .decodingError(let message):
            return "Failed to decode the response: \(message)"
        case .underlying(let message):
            return message
        }
    }
}

/// Protocol defining low-level networking operations.
protocol NetworkServiceProtocol: Sendable {
    func fetchData<T: Decodable & Sendable>(from url: URL) async throws -> T
    func request<T: Decodable & Sendable>(_ request: URLRequest) async throws -> T
}

/// Concrete implementation of `NetworkServiceProtocol` using URLSession.
final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func fetchData<T: Decodable & Sendable>(from url: URL) async throws -> T {
        let request = URLRequest(url: url)
        return try await self.request(request)///the argument is passed without naming,because the signature has "_ " as argument label for the callers
    }

    func request<T: Decodable & Sendable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
}

// MARK: - Mock Network Service for Previews / Unit Tests
final class MockNetworkService: NetworkServiceProtocol, @unchecked Sendable {
    var resultToReturn: Any?
    var errorToThrow: Error?

    init(resultToReturn: Any? = nil, errorToThrow: Error? = nil) {
        self.resultToReturn = resultToReturn
        self.errorToThrow = errorToThrow
    }

    func fetchData<T: Decodable & Sendable>(from url: URL) async throws -> T {
        if let error = errorToThrow {
            throw error
        }
        if let result = resultToReturn as? T {
            return result
        }
        throw NetworkError.invalidResponse
    }

    func request<T: Decodable & Sendable>(_ request: URLRequest) async throws -> T {
        if let error = errorToThrow {
            throw error
        }
        if let result = resultToReturn as? T {
            return result
        }
        throw NetworkError.invalidResponse
    }
}
