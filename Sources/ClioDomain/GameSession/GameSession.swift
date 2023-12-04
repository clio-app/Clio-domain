//
//  GameSession.swift
//  clio-app
//
//  Created by Thiago Henrique on 17/10/23.
//

import Foundation
import ClioEntities
import Mixpanel

final public class GameSession: ObservableObject {
    public enum GameState: Equatable {
        case start
        case midle
        case final
    }

    @Published public var gameState: GameState = .start
    @Published public var gameFlowParameters = GameFlowParameters()
    @Published public var alertError = AlertError()
    @Published public var themeManager = ThemeManager()
    @Published public var profileImageManager = ProfileImageManager()
    private var startPlayerRoundTime: DispatchTime!

    /// Move to another file if necessary
    var minimumPlayers: Int = 3
    
    public init() {}
    
    // MARK: - PlayersView Functions
    public func addPlayerInSession(name: String, image: String) {
        if gameFlowParameters.players.count > 4 {
            alertError = AlertError(
                showAlert: true,
                errorMessage: NSLocalizedString("Já foi atingido o máximo de jogadores", comment: "max players reached")
            )
            return
        }
        if name.isEmpty || name.hasPrefix(" ") {
            alertError = AlertError(showAlert: true, errorMessage: NSLocalizedString("Opa! O nome do jogador não pode estar vazio.", comment: "name is blank"))
            return
        }

        let newUser = User(id: UUID(), name: name, picture: image, artefacts: nil)
        gameFlowParameters.players.append(newUser)
    }

    public func removePlayerInSession(_ player: User) {
        if let index = gameFlowParameters.players.firstIndex(of: player) {
            gameFlowParameters.players.remove(at: index)
        }
    }

    public func canStartGame() -> Bool {
        return gameFlowParameters.players.count < minimumPlayers
    }

    public func hasReachedPlayerLimit() -> Bool {
        return gameFlowParameters.players.count > 4
    }

    // MARK: - Raffle Theme Functions
    public func randomizeThemes() {
        gameFlowParameters.sessionTheme = themeManager.themes.randomElement()!
    }


    public func selectFirstRoundPrompt() {
        // Parse the JSON data into a Swift dictionary
        if let firstPrompt = themeManager.themePhrases[gameFlowParameters.sessionTheme]?.randomElement() {
            gameFlowParameters.firstRoundPrompt = firstPrompt
        }
    }

    // MARK: Change game state logic
    public func changeGameState(to newState: GameState) {
        DispatchQueue.main.async {
            self.gameState = newState
        }
    }
    
    public func restartGame() {
        gameFlowParameters.didPlay = []
        gameFlowParameters.emojisIndexReaction = []
        changeGameState(to: .start)
    }
    
    public func fullResetGame() {
        gameFlowParameters.didPlay = []
        gameFlowParameters.players = []
        gameFlowParameters.emojisIndexReaction = []
        gameFlowParameters.currenPlayer = nil
        changeGameState(to: .start)
    }
    
    // MARK: - Select Player Functions
    public func getRandomPlayer(currentPlayer: User? = nil) -> User? {
        let filteredList = gameFlowParameters.players.filter({ player in
            !gameFlowParameters.didPlay.contains(where: {$0.id == player.id})
        })
        if let currentUser = currentPlayer {
            if let newUser = filteredList.filter({ $0 != currentUser}).randomElement() {
                return newUser
            }
        }
        let newUser = filteredList.randomElement()
        return newUser

    }

    public func addPlayerInRound(player: User) {
        gameFlowParameters.currenPlayer = player
        startPlayerRoundTime = .now()
    }
    
    private func addPlayerToDidPlay() {
        guard let player = gameFlowParameters.currenPlayer else { return }
        let endPlayerRoundTime: DispatchTime = .now()
        let roundElapsedTime = Double(endPlayerRoundTime.uptimeNanoseconds - startPlayerRoundTime.uptimeNanoseconds) / 1_000_000_000
        
        Mixpanel.mainInstance().track(
            event: "Player Round Time",
            properties: [
                "Seconds": roundElapsedTime,
                "isFirstPlayer": gameFlowParameters.didPlay.isEmpty
            ]
        )
        
        gameFlowParameters.didPlay.append(player)
        if gameFlowParameters.didPlay.count == (gameFlowParameters.players.count - 1) {
            changeGameState(to: .final)
        }
    }
    
    // MARK: Artifacts Functions
    public func getCurrentTheme() -> String {
        if let description = gameFlowParameters.currenPlayer?.artefact?.description {
            return description
        }
        return gameFlowParameters.firstRoundPrompt
    }
    
    public func sendArtifact(picture: Data? = nil, description: String? = nil, reactionEmojiIndex: Int? = nil) {
        if let pictureArtifact = picture {
            sendPhoto(imageData: pictureArtifact)
        }
        if let descriptionArtifact = description {
            sendDescription(description: descriptionArtifact)
        }
        if let emojiIndex = reactionEmojiIndex {
            sendEmojiIndex(emojiIndex: emojiIndex)
        }
    }
    
    private func sendPhoto(imageData data: Data) {
        guard (gameFlowParameters.currenPlayer != nil) else { return }
        switch gameState {
        case .start:
            gameFlowParameters.currenPlayer!.artefact = .init(
                masterId: gameFlowParameters.currenPlayer!.id, picture: data, description: nil
            )
            changeGameState(to: .midle)
        case .midle:
            gameFlowParameters.currenPlayer!.artefact?.picture = data
        case .final:
            return
        }
        addPlayerToDidPlay()
    }
    
    private func sendDescription(description: String) {
        if let currenPlayer = gameFlowParameters.currenPlayer {
            gameFlowParameters.currenPlayer?.artefact = .init(masterId: currenPlayer.id)
            gameFlowParameters.currenPlayer?.artefact?.description = description
        }
        if gameState == .final {
            addPlayerToDidPlay()
        }
    }
    
    private func sendEmojiIndex(emojiIndex: Int) {
        gameFlowParameters.emojisIndexReaction.append(emojiIndex)
    }
    
    public func getEmojiName(index: Int) -> String? {
        let emojiIndex = gameFlowParameters.emojisIndexReaction[index]
        if emojiIndex != 0 {
            return "Emoji\(emojiIndex)"
        }
        return nil
    }
    
    public func getLastImage() -> Data? {
        if gameFlowParameters.didPlay.count > 0 {
            let lastIndex = gameFlowParameters.didPlay.count - 1
            let lastUser = gameFlowParameters.didPlay[lastIndex]
            return lastUser.artefact?.picture
        }
        return nil
    }
}



