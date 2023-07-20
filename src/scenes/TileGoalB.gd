extends Spatial

func set_open(value):
	$TheGoal/chest.hide()
	$TheGoal/chest_open.hide()
	
	if not value:
		$TheGoal/chest.show()
	else:
		$TheGoal/chest_open.show()

func reached():
	var tmp = preload("res://scenes/CongratulationsParticles.tscn").instance()
	get_tree().root.add_child(tmp)
	tmp.global_transform = global_transform
	# print("reached 3")
	set_open(true)
