extends Control

func controlled_text(player, character):
	return player + " now controls the " + character

func update_text():
	if not GameState.is_swapped:
		$VBoxContainer/Label2.text = controlled_text("Player 1", "Orc")
		$VBoxContainer/Label3.text = controlled_text("Player 2", "Dungeon Master")
	else:
		$VBoxContainer/Label2.text = controlled_text("Player 1", "Dungeon Master")
		$VBoxContainer/Label3.text = controlled_text("Player 2", "Orc")
