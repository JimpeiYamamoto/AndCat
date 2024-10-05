import Foundation

public protocol PokemonRepositoryType {
    func getPokemonList(offset: Int) async throws -> Pokemon
}

public final class PokemonRepository: PokemonRepositoryType {

    public init() {}

    public func getPokemonList(offset: Int) async throws -> Pokemon {
        // ローカルからFetchする処理書く
        return .init(name: "フシギダネ")
    }
}

extension PokemonRepository {
    public static let shared = PokemonRepository()
}
