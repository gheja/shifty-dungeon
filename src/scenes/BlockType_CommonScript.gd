extends Spatial

signal mouse_hover

func _on_FloorBox_input_event(_camera, event, position, _normal, _shape_idx):
	if event is InputEventMouse:
		emit_signal("mouse_hover", position)

