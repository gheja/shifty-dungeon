extends Spatial

signal goal_reached

func _ready():
	$Area.connect("body_entered", self, "on_area_shape_entered")
	pass

func on_area_shape_entered(a):
	print(a)

func _on_Area_area_entered(area):
	print(area)

