extends Spatial

func set_open(_value):
	$AnimationPlayer.play("disappear")

func reached():
	set_open(true)
