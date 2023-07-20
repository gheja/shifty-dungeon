extends Control

func update_text(swapped):
	if not swapped:
		$VBoxContainer/Label3.hide()
	else:
		$VBoxContainer/Label2.hide()
