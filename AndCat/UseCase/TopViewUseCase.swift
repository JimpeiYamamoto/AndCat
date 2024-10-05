import Foundation

public protocol TopViewUseCaseType {
    func fetchPokemonList(offset: Int) async -> TopViewUseCaseModel.FetchResult
}

public final class TopViewUseCase: TopViewUseCaseType {
    // 必要に応じてデータ永続化に利用するRepositoryなども保持する
    private let pokemonRepository: PokemonRepositoryType

    public init(pokemonRepository: PokemonRepositoryType) {
        self.pokemonRepository = pokemonRepository
    }

    public func fetchPokemonList(offset: Int) async -> TopViewUseCaseModel.FetchResult {
        do {
            let pokemon = try await pokemonRepository.getPokemonList(offset: offset)
            return .success(.init(name: pokemon.name))
        } catch {
            return .showErrorView
        }
    }
}

public enum TopViewUseCaseModel {
    public enum FetchResult {
        case success(Pokemon)
        case showErrorView

        public struct Pokemon: Equatable {
            let name: String
        }
    }
}

extension TopViewUseCase {
    public static let shared = TopViewUseCase(pokemonRepository: PokemonRepository.shared)
}
