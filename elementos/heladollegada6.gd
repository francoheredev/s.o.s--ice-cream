extends Area2D

@onready var anim = $AnimatedSprite2D
@onready var label = $Label
@onready var sfx = $AudioStreamPlayer2D
@onready var win_label = get_tree().current_scene.get_node("CanvasModulate/WinLabel2")
@onready var camera = get_viewport().get_camera_2d()

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
		
		# 🛑 frenar player
		body.velocity = Vector2.ZERO
		
		if "can_move" in body:
			body.can_move = false
		
		level_complete()


func level_complete():
	completed = true
	
	label.visible = false
	
	if sfx:
		sfx.stop()
	
	print("Nivel completado!")
	anim.play("completado")

	var tree = get_tree()
	if not tree:
		return

	# 🧊 slow motion
	Engine.time_scale = 0.1
	await tree.create_timer(0.1).timeout
	Engine.time_scale = 1.0

	# 🎥 zoom
	await zoom_to_goal()

	# 💬 mensaje
	await show_win_message()

	# ➡️ cambiar nivel
	tree.change_scene_to_file("res://menu.tscn")


# --------------------
# 🎥 ZOOM
# --------------------
func zoom_to_goal():
	if not camera:
		return
	
	var tween = create_tween()
	tween.tween_property(camera, "zoom", Vector2(1.75, 1.5), 0.4)
	tween.parallel().tween_property(camera, "global_position", global_position, 0.4)
	
	await tween.finished


# --------------------
# 💬 MENSAJE
# --------------------
func show_win_message():
	if not win_label:
		return
	
	var tree = get_tree()
	if not tree:
		return
	
	win_label.text = "NIVEL COMPLETADO!!"
	win_label.visible = true
	win_label.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(win_label, "modulate:a", 1.0, 0.2)
	await tween.finished
	
	await tree.create_timer(0.8).timeout
	
	var tween_out = create_tween()
	tween_out.tween_property(win_label, "modulate:a", 0.0, 0.2)
	await tween_out.finished
	
	win_label.visible = false


# --------------------
# 💬 LOOP
# --------------------
func dialog_loop():
	var tree = get_tree()
	if not tree:
		return
	
	await tree.create_timer(0.4).timeout
	
	while not completed:
		await show_dialog()
		
		if completed:
			return
		
		await tree.create_timer(1.5).timeout


# --------------------
# 💬 DIÁLOGO
# --------------------
func show_dialog():
	if completed:
		return
	
	var tree = get_tree()
	if not tree:
		return
	
	label.visible = true
	
	var tween = create_tween()
	label.position.y = base_y + 10
	label.modulate.a = 0.0
	
	tween.tween_property(label, "position:y", base_y, 0.4)
	tween.parallel().tween_property(label, "modulate:a", 1.0, 0.3)
	
	await tween.finished
	
	if completed:
		return
	
	await type_text("SOS SOS!!", 0.05)
	
	if completed:
		return
	
	await shake_label(0.3)
	
	if completed:
		return
	
	await float_label(1.0)
	
	if completed:
		return
	
	var tween_out = create_tween()
	tween_out.tween_property(label, "modulate:a", 0.0, 0.3)
	await tween_out.finished
	
	label.visible = false


# --------------------
# ✍️ TYPING
# --------------------
func type_text(text: String, speed := 0.04):
	var tree = get_tree()
	if not tree:
		return
	
	label.text = ""
	
	for i in text.length():
		if completed:
			return
		
		label.text += text[i]
		
		if sfx and text[i] != " ":
			sfx.pitch_scale = randf_range(0.9, 1.1)
			sfx.play()
		
		await tree.create_timer(speed).timeout


# --------------------
# 😨 SHAKE
# --------------------
func shake_label(duration):
	var tree = get_tree()
	if not tree:
		return
	
	var time := 0.0
	
	while time < duration:
		if completed:
			return
		
		label.position.x += randf_range(-2, 2)
		label.position.y += randf_range(-2, 2)
		
		await tree.create_timer(0.03).timeout
		time += 0.03
	
	label.position.y = base_y


# --------------------
# 🌊 FLOAT
# --------------------
func float_label(duration):
	var tree = get_tree()
	if not tree:
		return
	
	var time := 0.0
	
	while time < duration:
		if completed:
			return
		
		label.position.y = base_y + sin(time * 6.0) * 4
		
		await tree.create_timer(0.04).timeout
		time += 0.016
	
	label.position.y = base_y
