extends Node2D

@onready var animation = $AnimationPlayer
@onready var sprite = $RigidBody2D/Sprite2D
@onready var line = $Line2D
@onready var particles = $RigidBody2D/Sprite2D/GPUParticles2D
@onready var physics = $RigidBody2D
@onready var timer = $DespawTimer

signal termite_finished

var color

func _ready():
	sprite.self_modulate = color
	var term_parts = sprite.get_children()
	for part in term_parts:
		if part.is_in_group("body_part"):
			part.self_modulate = color
	var rotations = [0.0,90.0,180.0,270.0]
	sprite.rotation_degrees = rotations.pick_random()

func init(Term_color):
	color = Term_color

func set_last_point(point:Vector2, last_point:int):
	line.set_point_position(last_point,point)

func follow_line(Points:PackedVector2Array):
	line.add_point(Points[0])
	Points.remove_at(0)
	animation.play("walking")
	particles.emitting = true
	for point in Points:
		line.add_point(sprite.position)
		var last_point = line.points.size()-1
		var tween = create_tween()
		tween.set_parallel()
		set_direction(point)
		tween.tween_property(sprite, "position", point, 1.0)
		tween.tween_method(set_last_point.bind(last_point),sprite.position,point,1.0)
		await tween.finished
	particles.emitting = false
	animation.play("idle")
	termite_finished.emit()

func fall():
	physics.freeze = false
	var rng = RandomNumberGenerator.new()
	physics.apply_impulse(Vector2(rng.randf_range(-50.0,50.0),80.0))
	line.hide()
	timer.start()

func set_direction(point):
	var delta = sprite.position.direction_to(point)

	if abs(delta.x) > abs(delta.y):
		if delta.x > 0:
			sprite.rotation_degrees = 270
		else:
			sprite.rotation_degrees = 90
	else:
		if delta.y > 0:
			sprite.rotation_degrees = 0
		else:
			sprite.rotation_degrees = 180


func _on_despaw_timer_timeout():
	queue_free()
