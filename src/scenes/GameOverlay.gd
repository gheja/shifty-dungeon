extends Control

# TODO: lags behind a bit... check out Input.set_custom_mouse_cursor()

var mouse_cursors = [
	preload("res://data/graphics/mouse_cursor_menu.png"),
	preload("res://data/graphics/mouse_cursor_step.png"),
	preload("res://data/graphics/mouse_cursor_rotate.png"),
	preload("res://data/graphics/mouse_cursor_invalid.png"),
]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta):
	var p = get_viewport().get_mouse_position()
	$MouseCursor.rect_position = p - Vector2(3, 3)

func set_progress(value):
	$TextureProgress.value = value * 100

# TODO: should not update on every frame...
func update_mouse_cursor(player1_control, player2_control, is_valid):
	if not GameState.state == GameState.STATE_RUNNING:
		$MouseCursor/Graphics.modulate = Color(1.0, 1.0, 1.0, 1.0)
		$MouseCursor/Graphics.texture = mouse_cursors[0]
		return

	if player1_control == GameState.CONTROL_MOUSE:
		$MouseCursor/Graphics.modulate = Color(1.0, 0.0, 0.0, 0.5)
	elif player2_control == GameState.CONTROL_MOUSE:
		$MouseCursor/Graphics.modulate = Color(0.0, 0.5, 1.0, 0.5)
	else:
		$MouseCursor/Graphics.modulate = Color(1.0, 1.0, 1.0, 0.3)
	
	
	if not GameState.is_swapped:
		if player1_control == GameState.CONTROL_MOUSE:
			$MouseCursor/Graphics.texture = mouse_cursors[1]
		elif player2_control == GameState.CONTROL_MOUSE:
			if is_valid:
				$MouseCursor/Graphics.texture = mouse_cursors[2]
			else:
				$MouseCursor/Graphics.texture = mouse_cursors[3]
	else:
		if player1_control == GameState.CONTROL_MOUSE:
			if is_valid:
				$MouseCursor/Graphics.texture = mouse_cursors[2]
			else:
				$MouseCursor/Graphics.texture = mouse_cursors[3]
		elif player2_control == GameState.CONTROL_MOUSE:
			$MouseCursor/Graphics.texture = mouse_cursors[1]

