extends Spatial

signal mouse_hover

func _on_FloorBox_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouse:
		emit_signal("mouse_hover", position)
