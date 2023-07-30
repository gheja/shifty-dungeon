extends Control

signal start_button_pressed

export(Array, PackedScene) var levels

onready var player1_button: Button = $VBoxContainer/MainMenu/VBoxContainer/Player1Button
onready var player2_button: Button = $VBoxContainer/MainMenu/VBoxContainer/Player2Button
onready var level_button: Button = $VBoxContainer/MainMenu/VBoxContainer/LevelButton
onready var start_button: Button = $VBoxContainer/MainMenu/VBoxContainer/StartButton
onready var options_button: Button = $VBoxContainer/MainMenu/VBoxContainer/OptionsButton
onready var how_to_play_button: Button = $VBoxContainer/MainMenu/VBoxContainer/HowToPlayButton
onready var about_button: Button = $VBoxContainer/MainMenu/VBoxContainer/AboutButton
onready var exit_button: Button = $VBoxContainer/MainMenu/VBoxContainer/ExitButton

onready var about_back_button: Button = $VBoxContainer/About/VBoxContainer/AboutBackButton

onready var options_fullscreen_button: = $VBoxContainer/Options/VBoxContainer/FullScreenButton
onready var options_music_button: = $VBoxContainer/Options/VBoxContainer/MusicButton
onready var options_sounds_button: = $VBoxContainer/Options/VBoxContainer/SoundsButton
onready var cpu_player_difficulty_button: = $VBoxContainer/Options/VBoxContainer/CpuPlayerDifficultyButton
onready var options_back_button: Button = $VBoxContainer/Options/VBoxContainer/OptionsBackButton

onready var how_to_play_back_button: Button = $VBoxContainer/HowToPlay/VBoxContainer/HowToPlayBackButton

var player1_control = GameState.CONTROL_MOUSE
var player2_control = GameState.CONTROL_CPU

func _ready():
	if OS.has_feature("mobile") or OS.has_feature("web"):
		exit_button.hide()
	
	update_buttons()
	
	player1_button.grab_focus()

func is_last_level_selected():
	if GameState.levelToLoad == levels.size() - 1:
		return true
	
	return false

func get_selected_level_scene():
	return levels[GameState.levelToLoad]

func reset_selected_level_index():
	GameState.levelToLoad = GameState.maxLevelUnlocked
	update_buttons()

func get_text_from_control_number(n):
	if n == 0:
		return "Keyboard"
	elif n == 1:
		return "Mouse"
	elif n == 2:
		return "CPU"
	
	print("?!")

func get_on_off_text(a):
	if a:
		return "On"
	
	return "Off"

func get_cpu_player_difficulty(n):
	if n == 1:
		return "Easy"
	elif n == 2:
		return "Normal"
	elif n == 3:
		return "Hard"
	
	print("?!")

func get_level_text(n):
	var s = str(n + 1)
	
	if n > GameState.maxLevelUnlocked:
		s += " (locked)"
	
	return s

func level_finished_dialog(status):
	show_level_complete_menu()
	
	$VBoxContainer/LevelComplete/VBoxContainer/TextNext.hide()
	$VBoxContainer/LevelComplete/VBoxContainer/TextGameComplete.hide()
	$VBoxContainer/LevelComplete/VBoxContainer/TextFailed.hide()
	$VBoxContainer/LevelComplete/VBoxContainer/TryAgainButton.hide()
	$VBoxContainer/LevelComplete/VBoxContainer/NextLevelButton.hide()
	
	if status == 1:
		$VBoxContainer/LevelComplete/VBoxContainer/TextNext.show()
		$VBoxContainer/LevelComplete/VBoxContainer/TryAgainButton.show()
		$VBoxContainer/LevelComplete/VBoxContainer/NextLevelButton.show()
		$VBoxContainer/LevelComplete/VBoxContainer/NextLevelButton.grab_focus()
	elif status == 2:
		$VBoxContainer/LevelComplete/VBoxContainer/TextGameComplete.show()
		$VBoxContainer/LevelComplete/VBoxContainer/TryAgainButton.show()
		$VBoxContainer/LevelComplete/VBoxContainer/TryAgainButton.grab_focus()
	elif status == 3:
		$VBoxContainer/LevelComplete/VBoxContainer/TextFailed.show()
		$VBoxContainer/LevelComplete/VBoxContainer/TryAgainButton.show()
		$VBoxContainer/LevelComplete/VBoxContainer/TryAgainButton.grab_focus()

func update_buttons():
	player1_button.text = "Player 1: " + get_text_from_control_number(player1_control)
	player2_button.text = "Player 2: " + get_text_from_control_number(player2_control)
	level_button.text = "Level: " + get_level_text(GameState.levelToLoad)
	
	options_fullscreen_button.text = "Full screen: " + get_on_off_text(GameState.fullScreenEnabled)
	options_music_button.text = "Music: " + get_on_off_text(GameState.musicEnabled)
	options_sounds_button.text = "Sounds: " + get_on_off_text(GameState.soundsEnabled)
	cpu_player_difficulty_button.text = "CPU player level: " + get_cpu_player_difficulty(GameState.cpu_player_difficulty)
	
	start_button.disabled = false
	
	if (player1_control == 1 or player1_control == 0) and (player1_control == player2_control):
		start_button.disabled = true
	
	if GameState.levelToLoad > GameState.maxLevelUnlocked:
		start_button.disabled = true

func show_main_menu(button_to_focus: Button):
	if not button_to_focus:
		button_to_focus = start_button
	
	$VBoxContainer/MainMenu.show()
	$VBoxContainer/Options.hide()
	$VBoxContainer/HowToPlay.hide()
	$VBoxContainer/About.hide()
	$VBoxContainer/LevelComplete.hide()
	button_to_focus.grab_focus()

func show_about_menu():
	$VBoxContainer/MainMenu.hide()
	$VBoxContainer/Options.hide()
	$VBoxContainer/HowToPlay.hide()
	$VBoxContainer/About.show()
	$VBoxContainer/LevelComplete.hide()
	about_back_button.grab_focus()

func show_options_menu():
	$VBoxContainer/MainMenu.hide()
	$VBoxContainer/Options.show()
	$VBoxContainer/HowToPlay.hide()
	$VBoxContainer/About.hide()
	$VBoxContainer/LevelComplete.hide()
	options_back_button.grab_focus()

func show_how_to_play_menu():
	$VBoxContainer/MainMenu.hide()
	$VBoxContainer/Options.hide()
	$VBoxContainer/HowToPlay.show()
	$VBoxContainer/About.hide()
	$VBoxContainer/LevelComplete.hide()
	how_to_play_back_button.grab_focus()

func show_level_complete_menu():
	$VBoxContainer/MainMenu.hide()
	$VBoxContainer/Options.hide()
	$VBoxContainer/HowToPlay.hide()
	$VBoxContainer/About.hide()
	$VBoxContainer/LevelComplete.show()

func button_pressed():
	AudioManager.play_sound(1)

func button_focused():
	AudioManager.play_sound(0)

func _on_Button_focus_entered():
	button_focused()


# --- main menu ---
func _on_Player1Button_pressed():
	button_pressed()
	player1_control = (player1_control + 1) % 3
	update_buttons()

func _on_Player2Button_pressed():
	button_pressed()
	player2_control = (player2_control + 1) % 3
	update_buttons()

func _on_LevelButton_pressed():
	button_pressed()
	GameState.levelToLoad = (GameState.levelToLoad + 1) % levels.size()
	update_buttons()

func _on_StartButton_pressed():
	# button_pressed()
	AudioManager.play_sound(3)
	emit_signal("start_button_pressed")

func _on_OptionsButton_pressed():
	button_pressed()
	show_options_menu()

func _on_HowToPlayButton_pressed():
	button_pressed()
	show_how_to_play_menu()

func _on_AboutButton_pressed():
	button_pressed()
	show_about_menu()

func _on_ExitButton_pressed():
	button_pressed()
	get_tree().quit()



# --- options menu ---
func _on_FullScreenButton_pressed():
	button_pressed()
	GameState.fullScreenEnabled = !GameState.fullScreenEnabled
	GameState.applyOptions()
	update_buttons()

func _on_MusicButton_pressed():
	button_pressed()
	GameState.musicEnabled = !GameState.musicEnabled
	GameState.applyOptions()
	update_buttons()

func _on_SoundsButton_pressed():
	button_pressed()
	GameState.soundsEnabled = !GameState.soundsEnabled
	GameState.applyOptions()
	update_buttons()

func _on_CpuPlayerDifficultyButton_pressed():
	button_pressed()
	
	GameState.cpu_player_difficulty += 1
	
	if GameState.cpu_player_difficulty > 3:
		GameState.cpu_player_difficulty = 1
		
	GameState.applyOptions()
	update_buttons()

func _on_OptionsBackButton_pressed():
	button_pressed()
	show_main_menu(options_button)


# --- how to play ---
func _on_HowToPlayBackButton_pressed():
	button_pressed()
	show_main_menu(how_to_play_button)


# --- about menu ---
func _on_AboutBackButton_pressed():
	button_pressed()
	show_main_menu(about_button)


# --- level complete screen ---
func _on_LevelCompleteBackButton_pressed():
	show_main_menu(start_button)

func _on_TryAgainButton_pressed():
	_on_StartButton_pressed()

func _on_NextLevelButton_pressed():
	_on_LevelButton_pressed()
	_on_StartButton_pressed()
