extends Spatial

func set_open(_value):
	$AnimationPlayer.play("disappear")

func reached():
	set_open(true)

func play_sound():
	AudioManager.play_sound(11)
