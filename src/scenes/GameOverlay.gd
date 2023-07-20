extends Control

# TODO: lags behind a bit... check out Input.set_custom_mouse_cursor()

var mouse_cursors = [
	preload("res://data/graphics/mouse_cursor_menu.png"),
	preload("res://data/graphics/mouse_cursor_step.png"),
	preload("res://data/graphics/mouse_cursor_rotate.png"),
	preload("res://data/graphics/mouse_cursor_invalid.png"),
]

var game_progressbar_target = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	var p = get_viewport().get_mouse_position()
	$MouseCursor.rect_position = p - Vector2(3, 3)
	
	$TextureProgress2.value = Lib.plerp($TextureProgress2.value, game_progressbar_target, 0.25, delta)

func reset():
	$TextureProgress.value = 0
	$TextureProgress2.value = 0
	game_progressbar_target = 0

func set_progress(value):
	$TextureProgress.value = value * 1000

func set_game_progressbar(value):
	# 1, 2, 3, 4
	if value == 1:
		game_progressbar_target = 150
	elif value == 2:
		game_progressbar_target = 500
	elif value == 3:
		game_progressbar_target = 800
	else:
		# 1000 is the max but the bar stops before it, possibly due to plerp()
		game_progressbar_target = 1200

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

func set_elements_visibility(value):
	$TextureProgress.visible = value
	$TextureProgress2.visible = value
