extends Area2D

@onready var anim = $AnimatedSprite2D

func _ready():
	anim.play("idle")  # 🔥 arranca animación


func _on_body_entered(body):
	if body.is_in_group("player"):
		GameManager.deaths += 1
		body.die()
