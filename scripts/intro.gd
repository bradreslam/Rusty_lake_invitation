extends CanvasLayer

@onready var timer = $Timer
@onready var audio = $AudioStreamPlayer2D
@onready var container = $Control

var messages = ["Hello?","Is this Rusty Lake?","Yes?","I am looking for the masters of the lake.","Follow the crow."]

var message_left = true

var message = -1
var letter = 0
var text:String
var message_letters = []
var current_line
var letters_done = false

var phone_start = load("res://Assets/Audio/phone_ring.wav")
var audio_lines = [load("res://Assets/Audio/line1.wav"),load("res://Assets/Audio/line2.wav"),
load("res://Assets/Audio/line3.wav"),load("res://Assets/Audio/line4.wav"),load("res://Assets/Audio/line5.wav")]

func _ready():
	audio.stream = phone_start
	audio.play()

func new_message():
	if message > 3:
		message += 1
		timer.stop()
		var tween = create_tween()
		tween.tween_property(container,"modulate:a",0.0,0.5)
		await tween.finished
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
		return
	text = ""
	letters_done = false
	letter = 0
	message += 1
	message_left = !message_left
	audio.stream = audio_lines[message]
	audio.play()
	message_letters = messages[message].split()
	current_line = Label.new()
	current_line.add_theme_font_size_override("font_size",22)
	container.add_child(current_line)
	current_line.position.y = 50 * message
	if !message_left:
		current_line.layout_direction = Control.LAYOUT_DIRECTION_RTL
		current_line.position.x = 300
	else:
		current_line.position.x = -300
	timer.one_shot = false
	timer.wait_time = 0.1
	timer.start()

func move_messages():
	var tween = create_tween()
	tween.tween_property(container,"position:y",container.position.y - 50,0.5)
	await tween.finished
	new_message()

func _on_audio_stream_player_2d_finished():
	if audio.stream == phone_start:
		move_messages()
	elif letters_done:
		timer.stop()
		timer.wait_time = 1
		timer.one_shot = true
		timer.start()

func _input(event):
	if event.is_action_pressed("click"):
		if message != -1 && message < 4:
			timer.stop()
			current_line.text = messages[message]
		audio.stop()
		move_messages()

func next_letter():
	text += message_letters[letter]
	current_line.text = text
	letter += 1
	if letter == message_letters.size():
		letters_done = true
		timer.stop()
		timer.wait_time = 1
		timer.one_shot = true
		timer.start()

func _on_timer_timeout():
	if timer.one_shot == true:
		move_messages()
	else:
		next_letter()
