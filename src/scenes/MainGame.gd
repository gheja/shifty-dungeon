extends Spatial

func unload_level():
	for child in $LevelContainer.get_children():
		$LevelContainer.remove_child(child)

func load_level():
	unload_level()
	
	var level_preload = preload("res://scenes/Level1.tscn")
	
	var level  = level_preload.instance()
	level.connect("navmesh_changed", self, "on_level_navmesh_changed")
	
	$LevelContainer.add_child(level)
	$Player.global_transform = Lib.get_first_group_member("player_start_positions").global_transform

func _ready():
	load_level()

func on_level_navmesh_changed():
	$Player.regenerate_route_schedule()

func _on_Timer_timeout():
	load_level()
