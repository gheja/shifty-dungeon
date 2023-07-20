extends Spatial

func set_open(value):
	$TheGoal/chest.hide()
	$TheGoal/chest_open.hide()
	
	if not value:
		$TheGoal/chest.show()
	else:
		$TheGoal/chest_open.show()

func reached():
	set_open(true)
