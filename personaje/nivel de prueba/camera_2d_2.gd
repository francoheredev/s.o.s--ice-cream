extends Camera2D

@export var deadzone := Vector2(100, 60)

func _process(delta):
	var player = get_parent()
	var diff = player.global_position - global_position

	var move = Vector2.ZERO

	if abs(diff.x) > deadzone.x:
		move.x = diff.x - sign(diff.x) * deadzone.x

	if abs(diff.y) > deadzone.y:
		move.y = diff.y - sign(diff.y) * deadzone.y

	global_position += move * 0.1
