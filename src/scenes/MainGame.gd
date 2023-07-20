extends Spatial

func _on_Level1_navmesh_changed():
	$Player.regenerate_route()
