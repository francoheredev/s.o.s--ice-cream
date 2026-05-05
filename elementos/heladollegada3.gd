extends Area2D

@onready var anim = $AnimatedSprite2D
var completed := false

func _ready():
	anim.play("quieto")


func _on_body_entered(body):
	if completed:
		return
		
	if body.is_in_group("player"):
		level_complete()


func level_complete():
	completed = true
	
	print("Nivel completado!")

	# 🔥 animación de completado
	anim.play("completado")

	# freeze tipo SMB
	get_tree().paused = true

	await get_tree().create_timer(0.15).timeout

	get_tree().paused = false
	get_tree().change_scene_to_file("res://nivel_4.tscn")
