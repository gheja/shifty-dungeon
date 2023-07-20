extends Node

const CONTROL_KEYBOARD = 0
const CONTROL_MOUSE = 1
const CONTROL_CPU = 2

const STATE_MENU = 1
const STATE_RUNNING = 2
const STATE_FINISHED = 3

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
