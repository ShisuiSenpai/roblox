--[[
	Match Controller - Multiplayer Typing Race Manager
	
	SETUP:
	Place this Script in ServerScriptService
	
	Manages:
	- Player matchmaking (minimum 2 players)
	- Synchronized rounds
	- Same sentence for all players
	- Winner determination
	- Leaderboard data
--]]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- Configuration
local MIN_PLAYERS = 2        -- Minimum players to start match
local MAX_PLAYERS = 6        -- Maximum players
local LOBBY_WAIT_TIME = 10   -- Seconds to wait in lobby
local ROUND_DELAY = 3        -- Delay between rounds

-- Sentences pool (same as client)
local SENTENCES = {
	"The quick brown fox jumps over the lazy dog",
	"Practice makes perfect when typing fast",
	"Speed and accuracy are both important skills",
	"Challenge yourself to type faster every day",
	"Master the keyboard with dedication and practice",
	"Typing is a valuable skill in the modern world",
	"Focus on accuracy before increasing your speed",
	"Every keystroke brings you closer to mastery",
	"Consistent practice leads to incredible results",
	"Push your limits and break your records"
}

-- Timer Configuration
local INITIAL_TIME = 15
local MIN_TIME = 5
local TIME_REDUCTION = 1

-- Create/Get BindableEvent for server-to-server communication
local matchEvent = ServerScriptService:FindFirstChild("MatchBindable")
if not matchEvent then
	matchEvent = Instance.new("BindableEvent")
	matchEvent.Name = "MatchBindable"
	matchEvent.Parent = ServerScriptService
end

-- Remote Events (for server-to-client communication)
local matchRemote = ReplicatedStorage:WaitForChild("MatchRemote")
local typingRemote = ReplicatedStorage:FindFirstChild("TypingTestRemote")
if not typingRemote then
	typingRemote = Instance.new("RemoteEvent")
	typingRemote.Name = "TypingTestRemote"
	typingRemote.Parent = ReplicatedStorage
end

-- Match State
local activePlayers = {}      -- Players currently in match
local playerData = {}          -- Player stats and status
local currentRound = 1
local currentTimeLimit = INITIAL_TIME
local currentSentence = ""
local matchInProgress = false
local lobbyTimer = 0
local roundInProgress = false

-- Initialize player data
local function initializePlayer(player, chairNumber)
	playerData[player] = {
		chairNumber = chairNumber,
		status = "waiting",     -- waiting, typing, completed, failed
		wpm = 0,
		completionTime = 0,
		isAlive = true,
		character = player.Character
	}
	
	print("🎮 Player", player.Name, "joined chair", chairNumber)
end

-- Remove player from match
local function removePlayer(player)
	if playerData[player] then
		playerData[player] = nil
	end
	
	local index = table.find(activePlayers, player)
	if index then
		table.remove(activePlayers, index)
	end
	
	print("👋 Player", player.Name, "left match")
end

-- Broadcast leaderboard update to all players
local function updateLeaderboard()
	local leaderboardData = {}
	
	for i = 1, MAX_PLAYERS do
		leaderboardData[i] = {
			playerName = "",
			userId = 0,
			status = "empty",
			wpm = 0,
			completionTime = 0,
			chairNumber = i
		}
	end
	
	for player, data in pairs(playerData) do
		if data.chairNumber and data.chairNumber <= MAX_PLAYERS then
			leaderboardData[data.chairNumber] = {
				playerName = player.Name,
				userId = player.UserId,
				status = data.status,
				wpm = data.wpm,
				completionTime = data.completionTime,
				chairNumber = data.chairNumber
			}
		end
	end
	
	matchRemote:FireAllClients("UpdateLeaderboard", leaderboardData, currentRound, currentTimeLimit)
end

-- Start a new round
local function startRound()
	roundInProgress = true
	
	-- Select random sentence
	currentSentence = SENTENCES[math.random(1, #SENTENCES)]
	
	-- Reset all alive players to typing status
	for player, data in pairs(playerData) do
		if data.isAlive then
			data.status = "typing"
			data.wpm = 0
			data.completionTime = 0
		end
	end
	
	-- Update leaderboard
	updateLeaderboard()
	
	-- Send round start to all alive players
	for _, player in ipairs(activePlayers) do
		if playerData[player] and playerData[player].isAlive then
			matchRemote:FireClient(player, "StartRound", currentSentence, currentTimeLimit, currentRound)
		end
	end
	
	print("🎯 Round", currentRound, "started - Time:", currentTimeLimit, "s")
end

-- End match and declare winner (MOVED ABOVE checkRoundEnd to fix orange warning)
local function endMatch(winner)
	matchInProgress = false
	roundInProgress = false
	
	if winner then
		print("🏆 Winner:", winner.Name)
		matchRemote:FireAllClients("MatchEnd", winner.Name, winner.UserId)
	else
		print("🤝 Match ended in a draw")
		matchRemote:FireAllClients("MatchEnd", nil, 0)
	end
	
	-- Show winner message for 3 seconds
	task.wait(3)
	
	-- Tell all clients to hide UI and reset
	matchRemote:FireAllClients("ResetAll")
	
	-- Tell all chairs to unlock their players
	matchEvent:Fire("UnlockAll")
	
	-- Small delay for unlocking to process
	task.wait(0.3)
	
	-- Kick all players from chairs to reset
	for player, data in pairs(playerData) do
		if player and player.Character then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				-- Re-enable jumping
				humanoid.JumpPower = 50
				humanoid.JumpHeight = 7.2
				
				-- Force unseat
				humanoid.Sit = false
				task.wait(0.05)
				humanoid.Jump = true
			end
		end
		
		-- Hide their UI
		if typingRemote then
			typingRemote:FireClient(player, "HideUI")
		end
	end
	
	-- Clear all player data
	activePlayers = {}
	playerData = {}
	currentRound = 1
	currentTimeLimit = INITIAL_TIME
	
	-- Reset leaderboard
	updateLeaderboard()
	
	print("🔄 Match reset, all players kicked, ready for new match")
end

-- Check if round should end
local function checkRoundEnd()
	local aliveCount = 0
	local typingCount = 0
	local completedCount = 0
	
	for player, data in pairs(playerData) do
		if data.isAlive then
			aliveCount = aliveCount + 1
			if data.status == "typing" then
				typingCount = typingCount + 1
			elseif data.status == "completed" then
				completedCount = completedCount + 1
			end
		end
	end
	
	-- Check for winner FIRST (only 1 alive) - prevents extra rounds
	if aliveCount == 1 then
		local winner = nil
		for player, data in pairs(playerData) do
			if data.isAlive then
				winner = player
				break
			end
		end
		
		if winner then
			endMatch(winner)
			return -- Exit early, don't start new round
		end
	elseif aliveCount == 0 then
		-- Everyone died, draw
		endMatch(nil)
		return -- Exit early
	end
	
	-- Round ends if everyone completed or failed (and more than 1 alive)
	if typingCount == 0 and aliveCount > 1 then
		endRound()
	end
end

-- End current round
function endRound()
	if not roundInProgress then return end
	roundInProgress = false
	
	print("🏁 Round", currentRound, "ended")
	
	-- Increase difficulty
	currentRound = currentRound + 1
	currentTimeLimit = math.max(MIN_TIME, currentTimeLimit - TIME_REDUCTION)
	
	-- Update leaderboard
	updateLeaderboard()
	
	-- Wait before next round
	task.wait(ROUND_DELAY)
	
	-- Check if enough players alive
	local aliveCount = 0
	for _, data in pairs(playerData) do
		if data.isAlive then
			aliveCount = aliveCount + 1
		end
	end
	
	if aliveCount >= 1 then
		startRound()
	end
end

-- endMatch function moved above checkRoundEnd (already defined there)

-- Start match
local function startMatch()
	if matchInProgress then return end
	if #activePlayers < MIN_PLAYERS then return end
	
	matchInProgress = true
	currentRound = 1
	currentTimeLimit = INITIAL_TIME
	
	print("🎮 Match starting with", #activePlayers, "players!")
	
	-- Notify all players
	matchRemote:FireAllClients("MatchStarting", LOBBY_WAIT_TIME)
	
	-- Countdown
	for i = 3, 1, -1 do
		matchRemote:FireAllClients("LobbyCountdown", i)
		task.wait(1)
	end
	
	-- Start first round
	startRound()
end

-- Handle player joining (from chair)
local function onPlayerJoin(player, chairNumber)
	if matchInProgress then
		return -- Can't join mid-match
	end
	
	if #activePlayers >= MAX_PLAYERS then
		return -- Match full
	end
	
	-- Add player
	table.insert(activePlayers, player)
	initializePlayer(player, chairNumber)
	
	-- Update leaderboard
	updateLeaderboard()
	
	-- Check if we can start
	if #activePlayers >= MIN_PLAYERS and not matchInProgress then
		-- Start lobby countdown
		if lobbyTimer == 0 then
			lobbyTimer = LOBBY_WAIT_TIME
			
			task.spawn(function()
				while lobbyTimer > 0 and #activePlayers >= MIN_PLAYERS and not matchInProgress do
					matchRemote:FireAllClients("LobbyCountdown", lobbyTimer)
					task.wait(1)
					lobbyTimer = lobbyTimer - 1
				end
				
				if lobbyTimer == 0 and #activePlayers >= MIN_PLAYERS then
					startMatch()
				end
				
				lobbyTimer = 0
			end)
		end
	end
end

-- Handle player leaving (from chair)
local function onPlayerLeave(player)
	removePlayer(player)
	updateLeaderboard()
	
	-- If match in progress, check if should end
	if matchInProgress then
		checkRoundEnd()
	end
end

-- Handle player completion
local function onPlayerComplete(player, wpm, timeTaken)
	if not playerData[player] then return end
	if not playerData[player].isAlive then return end
	
	playerData[player].status = "completed"
	playerData[player].wpm = wpm
	playerData[player].completionTime = timeTaken
	
	print("✅", player.Name, "completed!", wpm, "WPM in", timeTaken, "s")
	
	-- Update leaderboard
	updateLeaderboard()
	
	-- Check if round should end
	checkRoundEnd()
end

-- Handle player failure (timeout)
local function onPlayerFail(player)
	if not playerData[player] then return end
	if not playerData[player].isAlive then return end
	
	playerData[player].status = "failed"
	playerData[player].isAlive = false
	
	print("❌", player.Name, "failed!")
	
	-- Update leaderboard
	updateLeaderboard()
	
	-- Check if round/match should end
	checkRoundEnd()
end

-- Handle player WPM update (real-time)
local function onPlayerWPMUpdate(player, wpm)
	if not playerData[player] then return end
	if not playerData[player].isAlive then return end
	if playerData[player].status ~= "typing" then return end
	
	playerData[player].wpm = wpm
	
	-- Update leaderboard (throttled)
	updateLeaderboard()
end

-- Listen to chair events (server-to-server via BindableEvent)
matchEvent.Event:Connect(function(action, player, ...)
	if action == "PlayerJoin" then
		local chairNumber = ...
		onPlayerJoin(player, chairNumber)
		
	elseif action == "PlayerLeave" then
		onPlayerLeave(player)
	end
end)

-- Listen to player events from clients (via RemoteEvent)
matchRemote.OnServerEvent:Connect(function(player, action, ...)
	if action == "PlayerComplete" then
		local wpm, timeTaken = ...
		onPlayerComplete(player, wpm, timeTaken)
		
	elseif action == "PlayerFail" then
		onPlayerFail(player)
		
	elseif action == "UpdateWPM" then
		local wpm = ...
		onPlayerWPMUpdate(player, wpm)
	end
end)

-- Handle player disconnect
Players.PlayerRemoving:Connect(function(player)
	if playerData[player] then
		onPlayerLeave(player)
	end
end)

print("🎮 Match Controller initialized!")
print("📋 Settings: Min Players:", MIN_PLAYERS, "| Max Players:", MAX_PLAYERS)
