extends Area2D

@onready var anim = $AnimatedSprite2D
@onready var label = $Label
@onready var sfx = $AudioStreamPlayer

var completed := false
var base_y := 0.0

func _ready():
	anim.play("quieto")
	
	base_y = label.position.y
	label.modulate.a = 0.0
	label.visible = false
	
	dialog_loop()


func _on_body_entered(body):
	if completed:
		return
		
	if body.is_in_group("player"):
		level_complete()


func level_complete():
	completed = true
	label.visible = false
	
	print("Nivel completado!")


# --------------------
# 💬 LOOP DE DIÁLOGO
# --------------------
func dialog_loop():
	await get_tree().create_timer(0.4).timeout
	
	while not completed:
		await show_dialog()
		await get_tree().create_timer(1.5).timeout


# --------------------
# 💬 MOSTRAR DIÁLOGO
# --------------------
func show_dialog():
	label.visible = true
	
	# 🔼 aparece con animación
	var tween = create_tween()
	label.position.y = base_y + 10
	label.modulate.a = 0.0
	
	tween.tween_property(label, "position:y", base_y, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 1.0, 0.3)
	
	await tween.finished
	
	# ✍️ typing + sonido
	await type_text("HELP ME PLEASE!!", 0.05)
	
	# 😨 vibración
	await shake_label(0.3)
	
	# 🌊 flotación
	await float_label(1.0)
	
	# 🔽 desaparecer
	var tween_out = create_tween()
	tween_out.tween_property(label, "modulate:a", 0.0, 0.3)
	await tween_out.finished
	
	label.visible = false


# --------------------
# ✍️ TYPING + SONIDO
# --------------------
func type_text(text: String, speed := 0.04):
	label.text = ""
	
	for i in text.length():
		label.text += text[i]
		
		if text[i] != " ":
			sfx.pitch_scale = randf_range(0.9, 1.1)
			sfx.play()
		
		await get_tree().create_timer(speed).timeout


# --------------------
# 😨 SHAKE
# --------------------
func shake_label(duration):
	var time := 0.0
	
	while time < duration:
		label.position.x += randf_range(-2, 2)
		label.position.y += randf_range(-2, 2)
		
		await get_tree().create_timer(0.03).timeout
		time += 0.03
	
	label.position = Vector2(label.position.x, base_y)


# --------------------
# 🌊 FLOAT
# --------------------
func float_label(duration):
	var time := 0.0
	
	while time < duration:
		label.position.y = base_y + sin(time * 6.0) * 4
		await get_tree().create_timer(0.016).timeout
		time += 0.016
	
	label.position.y = base_y
