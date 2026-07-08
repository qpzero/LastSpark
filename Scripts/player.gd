class_name Player
extends CharacterBody2D


const SPEED = 700.0
const JUMP_VELOCITY = -900.0
var gravMod = 1
var is_dashing = false
var canDash = true
var HasWallJump = true
var is_clinging : bool = false
@onready var dash_timer = $DashTimer
var facing : float = 1

func _physics_process(delta: float) -> void:
	#variable jump height 
	if velocity.y<0:
		gravMod = 0.7
	else:
		gravMod = move_toward(gravMod, 1.2, 0.1)
	if Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y = move_toward(velocity.y, 0, SPEED/1.2)
		
	#Dash
	if Input.is_action_just_pressed("Dash") and canDash and not is_dashing:
		velocity = Vector2.ZERO
		dash_timer.start()
		dash(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down"))
		
	if dash_timer.time_left > 0:
		is_dashing = true
	else: 
		is_dashing = false
	
	if is_on_floor() or is_clinging:
		canDash = true
	
	#if the player is dashing dont add gravity or let them jump
	if is_dashing == false:

		# Handle jump.
		if Input.is_action_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		var direction = Input.get_axis("Left", "Right")
		if direction:
			velocity.x = move_toward(velocity.x, direction * SPEED, SPEED/2)
			if (direction < 0):
				facing = -1 # left
			else:
				facing = 1 # right
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED*0.2)
		
		# Wall Jump
		if HasWallJump:
			if is_on_wall_only():
				var normal = get_wall_normal()
				var dir
				if normal.x == 1 :
					dir = "Left"
				if normal.x == -1:
					dir = "Right"
					
				if Input.is_action_pressed(dir):
					is_clinging = true
					
				if is_clinging:
					velocity.y = 200
					gravMod = 0;
					if Input.is_action_just_pressed("Jump"):
						velocity.y = JUMP_VELOCITY
						velocity.x = -1500 * facing
					
				if Input.is_action_just_pressed(dir):
					velocity.y = 0
			else:
				is_clinging = false
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * gravMod * delta

	move_and_slide()

func dash(dirX, dirY) -> void:
	var dashSpeed = 3
	canDash = false
	is_dashing = true
	#if dirX:
		#velocity.x = dirX*SPEED*dashSpeed
	#if dirY:
		#velocity.y = dirY*SPEED*dashSpeed/1.4
	velocity = Vector2(dirX, dirY).normalized()*SPEED*dashSpeed
	is_dashing = false;

func _on_dash_timer_timeout() -> void:
	velocity.x = move_toward(velocity.x, 0, SPEED)
	if velocity.y < 0:
		velocity.y = move_toward(velocity.y, 0, SPEED*2)
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	


func _on_death_zone_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player:
		position = Vector2(1120,432)
