extends Node2D

@onready var time_label = $CanvasLayer/TimeLabel
@onready var death_label = $CanvasLayer/DeathLabel

var time := 0.0

func _process(delta):
	time += delta
	
	var seconds = int(time)
	var milliseconds = int((time - seconds) * 100)
	
	time_label.text = "%02d:%02d" % [seconds, milliseconds]
	death_label.text = "Deaths: %d" % GameManager.deaths
