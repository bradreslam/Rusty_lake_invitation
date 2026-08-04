extends CanvasLayer

@onready var quit_check = $Check
@onready var settings = $Settings
@onready var window_button = $Settings/VBoxContainer/HBoxContainer2/Window_mode

var quiting:bool = false

var window = 0

func _input(event):
	if event.is_action_pressed("Settings"):
		if settings.visible == true:
			settings.visible = false
		else:
			get_tree().paused = false
			self.queue_free()

func _on_quit_pressed():
	quiting = true
	quit_check.visible = true

func _on_reset_pressed():
	quiting = false
	quit_check.visible = true

func _on_settings_pressed():
	settings.visible = true

func _on_return_pressed():
	get_tree().paused = false
	self.queue_free()

func _on_yes_pressed():
	if quiting:
		get_tree().quit()
	else:
		get_tree().paused = false
		get_tree().reload_current_scene()
		self.queue_free()

func _on_no_pressed():
	quit_check.visible = false

func _on_window_mode_pressed():
	match window:
		0:
			window = 1
			window_button.text = "maximized"
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		1:
			window = 2
			window_button.text = "windowed"
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		2:
			window = 0
			window_button.text = "fullscreen"
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_close_settings_pressed():
	settings.visible = false

func _on_volume_value_changed(value):
	AudioServer.set_bus_volume_db(0,value)
