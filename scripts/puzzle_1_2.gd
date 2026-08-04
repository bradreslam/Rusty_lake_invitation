extends Node2D

@onready var animation = $AnimationPlayer

signal puzzle_1_2_finished

var puzzle_finished = true

func _on_puzzle_puzzle_finished():
	animation.play("Tree_falling")
	puzzle_1_2_finished.emit()
