extends CharacterBody2D

var player = null
var found = false

func _ready():
	$AnimatedSprite2D.play("idle")
	
func _physics_process(delta):
	if found:
		get_tree().quit()

func _on_area_2d_body_entered(body):
	# play video
	player = body
	found = true
