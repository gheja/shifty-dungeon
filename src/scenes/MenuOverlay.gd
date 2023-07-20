extends Control

signal start_button_pressed

# controls:
# - 0: keyboard
# - 1: mouse
# - 2: cpu

onready var player1_button: Button = $MainMenu/VBoxContainer/Player1Button
onready var player2_button: Button = $MainMenu/VBoxContainer/Player2Button
onready var start_button: Button = $MainMenu/VBoxContainer/StartButton
onready var about_button: Button = $MainMenu/VBoxContainer/AboutButton
onready var exit_button: Button = $MainMenu/VBoxContainer/ExitButton
onready var about_back_button: Button = $About/VBoxContainer/AboutBackButton

var player1_control = GameState.CONTROL_MOUSE
var player2_control = GameState.CONTROL_CPU

func _ready():
	if OS.has_feature("mobile") or OS.has_feature("web"):
		exit_button.hide()
	player1_button.grab_focus()

func get_text_from_control_number(n):
	if n == 0:
		return "Keyboard"
	elif n == 1:
		return "Mouse"
	elif n == 2:
		return "CPU"
	
	print("?!")

func update_buttons():
	player1_button.text = "Player 1: " + get_text_from_control_number(player1_control)
	player2_button.text = "Player 2: " + get_text_from_control_number(player2_control)
	
	if (player1_control == 1 or player1_control == 0) and (player1_control == player2_control):
		start_button.disabled = true
	else:
		start_button.disabled = false

func show_main_menu(back_from_about: bool):
	$About.hide()
	$MainMenu.show()
	if back_from_about:
		about_button.grab_focus()
	else:
		player1_button.grab_focus()

func show_about_menu():
	$MainMenu.hide()
	$About.show()
	about_back_button.grab_focus()

func _on_Player1Button_pressed():
	AudioManager.play_sound(1)
	player1_control = (player1_control + 1) % 3
	update_buttons()

func _on_Player2Button_pressed():
	AudioManager.play_sound(1)
	player2_control = (player2_control + 1) % 3
	update_buttons()

func _on_AboutButton_pressed():
	AudioManager.play_sound(1)
	show_about_menu()

func _on_AboutBackButton_pressed():
	AudioManager.play_sound(1)
	show_main_menu(true)

func _on_ExitButton_pressed():
	AudioManager.play_sound(1)
	get_tree().quit()

func _on_StartButton_pressed():
	AudioManager.play_sound(3)
	emit_signal("start_button_pressed")

func _on_Button_focus_entered():
	AudioManager.play_sound(0)
