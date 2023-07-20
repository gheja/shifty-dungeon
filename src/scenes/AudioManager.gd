extends Node

var menu_music_player: AudioStreamPlayer = null
var main_music_player: AudioStreamPlayer = null
var music_fade_ratio = 0.0
var music_fade_ratio_target = 0.0

var sounds = [
	preload("res://data/sounds/toggle_001.ogg"), # 0
	preload("res://data/sounds/toggle_002.ogg"), # 1
	preload("res://data/sounds/toggle_003.ogg"),
	preload("res://data/sounds/confirmation_002.ogg"),
	preload("res://data/music/psytronic-let-the-games-begin-21858_menu.ogg"),
	preload("res://data/music/psytronic-let-the-games-begin-21858_main.ogg"),
	preload("res://data/sounds/drop_003.ogg"),
	preload("res://data/sounds/drop_002.ogg"),
	preload("res://data/sounds/dropLeather.ogg"),
	preload("res://data/sounds/impactMining_002_edited.ogg"),
	preload("res://data/sounds/impactMining_004_edited.ogg"), # 10
	preload("res://data/sounds/question_003.ogg")
]

var volume_overrides = [
	0.3, 0.3, 0.3, 0.3, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
	2.0
]

func play_sound(index, pitch_shift_min: float = 1.0, pitch_shift_max: float = 1.0):
	var tmp = AudioStreamPlayer.new()
	tmp.stream = sounds[index]
	tmp.bus = "SFX"
	
	if volume_overrides.size() > index and volume_overrides[index] != null:
		tmp.volume_db = linear2db(volume_overrides[index])
	
	if pitch_shift_min != 1.0 or pitch_shift_max != 1.0:
		tmp.pitch_scale = rand_range(pitch_shift_min, pitch_shift_max)
	
	tmp.play()
	
	get_tree().root.call_deferred("add_child", tmp)

func _ready():
	menu_music_player = AudioStreamPlayer.new()
	menu_music_player.stream = sounds[4]
	menu_music_player.volume_db = linear2db(0.3)
	menu_music_player.bus = "Menu Music"
	menu_music_player.play()
	
	main_music_player = AudioStreamPlayer.new()
	main_music_player.stream = sounds[5]
	main_music_player.volume_db = linear2db(0.25)
	main_music_player.bus = "Main Music"
	main_music_player.play()
	
	get_tree().root.call_deferred("add_child", menu_music_player)
	get_tree().root.call_deferred("add_child", main_music_player)

func set_music_fade_ratio_target(value):
	music_fade_ratio_target = value

func _process(delta):
	music_fade_ratio = Lib.plerp(music_fade_ratio, music_fade_ratio_target, 0.25, delta)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Menu Music"), linear2db(1 - music_fade_ratio))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Main Music"), linear2db(music_fade_ratio))
