extends Node

const CONTROL_KEYBOARD = 0
const CONTROL_MOUSE = 1
const CONTROL_CPU = 2

const STATE_MENU = 1
const STATE_STARTING = 2
const STATE_RUNNING = 3
const STATE_FINISHED = 4

var is_swapped: bool = false
var state: int = 0
var cpu_player_difficulty = 2 # 1-2-3
var levelToLoad = 0
var maxLevelUnlocked = 0

var musicEnabled = true
var soundsEnabled = true
var fullScreenEnabled = false

func applyOptions():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music Master"), not musicEnabled)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Sounds Master"), not soundsEnabled)
	OS.set_window_fullscreen(fullScreenEnabled)

func saveConfig():
	var config = ConfigFile.new()
	
	config.set_value("game", "max_level_unlocked", maxLevelUnlocked)
	config.set_value("settings", "music_enabled", musicEnabled)
	config.set_value("settings", "sounds_enabled", soundsEnabled)
	config.set_value("settings", "full_screen_enabled", fullScreenEnabled)
	config.set_value("settings", "cpu_player_difficulty", cpu_player_difficulty)
	
	config.save("user://config.cfg")

func loadConfig():
	var config = ConfigFile.new()
	var err = config.load("user://config.cfg")
	
	if err != OK:
		return
	
	maxLevelUnlocked = config.get_value("game", "max_level_unlocked", 0)
	musicEnabled = config.get_value("settings", "music_enabled", true)
	soundsEnabled = config.get_value("settings", "sounds_enabled", true)
	fullScreenEnabled = config.get_value("settings", "full_screen_enabled", false)
	cpu_player_difficulty = config.get_value("settings", "cpu_player_difficulty", 2)

func prepareConfig():
	var config = ConfigFile.new()
	var err = config.load("user://config.cfg")
	
	if err != OK:
		saveConfig()
		return

func setMaxLevelUnlocked(value):
	maxLevelUnlocked = value
