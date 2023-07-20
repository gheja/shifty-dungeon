extends Node

var menu_music_player: AudioStreamPlayer = null
var main_music_player: AudioStreamPlayer = null
var music_fade_ratio = 0.0
var music_fade_ratio_target = 0.0

var sounds = [
	preload("res://data/sounds/toggle_001.ogg"),
	preload("res://data/sounds/toggle_002.ogg"),
	preload("res://data/sounds/toggle_003.ogg"),
	preload("res://data/sounds/confirmation_002.ogg"),
	preload("res://data/music/psytronic-let-the-games-begin-21858_menu.ogg"),
	preload("res://data/music/psytronic-let-the-games-begin-21858_main.ogg")
]

func play_sound(index):
	var tmp = AudioStreamPlayer.new()
	tmp.stream = sounds[index]
	tmp.bus = "SFX"
	tmp.play()
	
	get_tree().root.call_deferred("add_child", tmp)

func _ready():
	menu_music_player = AudioStreamPlayer.new()
	menu_music_player.stream = sounds[4]
	menu_music_player.bus = "Menu Music"
	menu_music_player.play()
	
	main_music_player = AudioStreamPlayer.new()
	main_music_player.stream = sounds[5]
	main_music_player.bus = "Main Music"
	main_music_player.play()
	
	get_tree().root.call_deferred("add_child", menu_music_player)
	get_tree().root.call_deferred("add_child", main_music_player)

func set_music_fade_ratio_target(value):
	music_fade_ratio_target = value

func _process(_delta):
	music_fade_ratio = music_fade_ratio + (music_fade_ratio_target - music_fade_ratio) * 0.05
	# music_fade_ratio = 1.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Menu Music"), linear2db(1 - music_fade_ratio))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Main Music"), linear2db(music_fade_ratio))
