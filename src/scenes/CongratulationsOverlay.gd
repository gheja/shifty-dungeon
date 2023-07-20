extends Control

func update_text():
	if not GameState.is_swapped:
		$Control/Player2Container.hide()
	else:
		$Control/Player1Container.hide()
