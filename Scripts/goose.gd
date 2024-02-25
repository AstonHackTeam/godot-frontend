extends CharacterBody2D

var player = null
var found = false

func _ready():
	$AnimatedSprite2D.play("idle")
	
func _physics_process(delta):
	if found:
		open_youtube_link()

func _on_area_2d_body_entered(body):
	# play video
	player = body
	found = true

func open_youtube_link():
	OS.shell_open("https://www.youtube.com/watch?v=qo8SDCuVCoY")
	get_tree().quit()

