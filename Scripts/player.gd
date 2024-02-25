extends CharacterBody2D

var speed = 100
const voice_speed = 3000
var curr_dir = "none"
var player = null
var found = false

var effect
var recording
var record_timer
var record_count

var right = true

func _ready():
	$AnimatedSprite2D.play("front_idle")
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	record_timer = Timer.new()
	record_timer.wait_time = 2.0 # 设置定时器每秒触发一次
	record_timer.connect("timeout", _on_record_timer_timeout)
	add_child(record_timer) # 将定时器添加为子节点，确保能够被正确管理和释放
	effect.set_recording_active(true)
	record_count = 0
	record_timer.start()
	
func _physics_process(delta):
	player_movement(delta)
	if found:
		speed = 0

func player_movement(delta):
		
	if Input.is_action_pressed("ui_right"):
		curr_dir = "right"
		play_animation(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		curr_dir = "left"
		play_animation(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		curr_dir = "down"
		play_animation(1)
		velocity.x = 0
		velocity.y = speed
	elif Input.is_action_pressed("ui_up"):
		curr_dir = "up"
		play_animation(1)
		velocity.x = 0
		velocity.y = -speed
	else:
		play_animation(0)
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide()
	
func play_animation(movement):
	var dir = curr_dir
	var animation = $AnimatedSprite2D
	
	if dir == "right":
		animation.flip_h = false
		if movement == 1:
			animation.play("side_walk")
		elif movement == 0:
			animation.play("side_idle")
	if dir == "left":
		animation.flip_h = true
		if movement == 1:
			animation.play("side_walk")
		elif movement == 0:
			animation.play("side_idle")
	if dir == "down":
		if movement == 1:
			animation.play("front_walk")
		elif movement == 0:
			animation.play("front_idle")
	if dir == "up":
		if movement == 1:
			animation.play("back_walk")
		elif movement == 0:
			animation.play("back_idle")
	
func _on_record_timer_timeout():
	record_count += 1
	var save_path = "recording_" + str(record_count) + ".wav"
	print(save_path)
	recording = effect.get_recording()
	recording.save_to_wav(save_path)
 #$Status.text = "Saved WAV file to: %s\n(%s)" % [save_path, ProjectSettings.globalize_path(save_path)]
	$HTTPRequest.request_completed.connect(_on_request_completed)
	var body_dict = {"file_name": save_path}
	var body = JSON.stringify(body_dict)
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request("http://127.0.0.1:8000/upload", headers, HTTPClient.METHOD_POST, body)

	effect.set_recording_active(false) 
	record_timer.start()
	effect.set_recording_active(true)

func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print(response_code)
		return
	var json_data = JSON.parse_string(body.get_string_from_utf8())
	print(json_data)


	# 检查是否成功解析 JSON 数据
	if json_data:
		# 从 JSON 数据中获取命令数组
		var commands = json_data["commands"]

		# 遍历命令数组
		for command in commands:
			# 根据不同的命令执行不同的操作
			match command:
				"left":
					curr_dir = "left"
					play_animation(1)
					velocity.x = -voice_speed
					velocity.y = 0
					move_and_slide()
				"right":
					curr_dir = "right"
					play_animation(1)
					velocity.x = voice_speed
					velocity.y = 0
					move_and_slide()
				"up":
					curr_dir = "up"
					play_animation(1)
					velocity.x = 0
					velocity.y = -voice_speed
					move_and_slide()
				"down":
					curr_dir = "down"
					play_animation(1)
					velocity.x = 0
					velocity.y = voice_speed
					move_and_slide()

