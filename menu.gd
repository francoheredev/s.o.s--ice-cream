extends Control

@onready var play_button = $Button
@onready var quit_button = $Button2

func _ready():
	# conectar botones
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# música
	var song = load("res://Takeover - Abyss.mp3")
	Music.play_music(song)


func _on_play_pressed():
	get_tree().change_scene_to_file("res://personaje/nivel de prueba/nivel_1.tscn")


func _on_quit_pressed():
	get_tree().quit()
