class_name Player
extends CharacterBody2D

#Node refs
@onready var dash_timer = $DashTimer
@onready var attack_hitbox = $attackHitbox
@onready var attack_timer = $attackHitbox/attackTimer
@onready var sprite = $AnimatedSprite2D
@onready var damage_cooldown = $damageHitbox/damageCooldown
@onready var damage_hitbox = $damageHitbox/CollisionShape2D


#ability/upgrade variables 
var is_dashing = false
var canDash = true
var stopDash = false
var HasWallJump = true
var canDoubleJump = false
var HasDoubleJump = true
var is_clinging : bool = false
var canCling = true
var weapon = "sword"

#general
const SPEED = 700.0
const JUMP_VELOCITY = -900.0
var gravMod = 1
var facing : float = 1
var lastRespawnPoint = Vector2(1149, 1241)
@export var HPMax : int = 5
@export var HP : int = 5

func _ready() -> void:
	Engine.time_scale = 1.0

func _physics_process(delta: float) -> void:
	handle_animation()
	
	
	
	#variable jump height 
	if velocity.y<0:
		gravMod = 0.8
	else:
		gravMod = move_toward(gravMod, 1.5, 0.1)
	if Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	if velocity.y > 1700:
		velocity.y = 1700 #Adds maximum velocity
	
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
	
	if stopDash: #slows the player to a halt after dashing
		if velocity != Vector2.ZERO:
			velocity.x = move_toward(velocity.x, 0, SPEED/3)
			if velocity.y < 0:
				velocity.y = move_toward(velocity.y, 0, SPEED/3)
			else:
				velocity.y = move_toward(velocity.y, 0, SPEED/3)
		else:
			stopDash = false

	
	#attacks
	handle_attack()
	
	#if the player is dashing dont add gravity or let them jump
	if not is_dashing and not stopDash:

		# Handle jump.
		if is_on_floor():
			jump()

		# Get the input direction and handle the movement/deceleration.
		var direction = Input.get_axis("Left", "Right")
		if direction:
			velocity.x = move_toward(velocity.x, direction * SPEED, SPEED/8)
			if (direction < 0):
				facing = -1 # left
			else:
				facing = 1 # right
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED*0.2)
		
		# Wall Jump
		if HasWallJump:
			
			if is_on_wall():
				var normal = get_wall_normal()
				var dir
				if normal.x == 1 :
					dir = "Left"
				if normal.x == -1:
					dir = "Right"
					
				if Input.is_action_pressed(dir) and canCling:
					is_clinging = true
					
				if is_on_floor():
					is_clinging = false
					if Input.is_action_just_pressed("Jump"):
						canCling = false
				
				if is_clinging:
					velocity.y = 200
					gravMod = 0;
					if Input.is_action_just_pressed("Jump"):
						velocity.y = JUMP_VELOCITY
						velocity.x = -700 * facing
					
				if Input.is_action_just_pressed(dir):
					velocity.y = 0
				
				
			else:
				is_clinging = false
			
			if is_on_floor() and not Input.is_action_pressed("Jump"):
				canCling = true
				
		# Double Jump
		if HasDoubleJump:
			if is_on_floor():
				canDoubleJump = true
			if canDoubleJump and (not is_on_floor()) and Input.is_action_just_pressed("Jump"):
				jump()
				canDoubleJump = false
		
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * gravMod * delta
	#death; die if dead
	death()
	
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

func jump() -> void:
	if Input.is_action_pressed("Jump"):
			velocity.y = JUMP_VELOCITY
			

func handle_attack() -> void:
	#attack direction
	if attack_timer.time_left<=0:
		attack_hitbox.scale.x = facing
		if Input.is_action_pressed("Up"):
			attack_hitbox.rotation_degrees = -90/facing
		elif Input.is_action_pressed("Down") and not is_on_floor():
			attack_hitbox.rotation_degrees = 90/facing
		else:
			attack_hitbox.rotation_degrees = 0
	
	if weapon == "sword":
		attack_timer.wait_time = 0.15
	
	#temp
	$attackHitbox/Sprite2D.visible = false
	
	$attackHitbox/CollisionPolygon2D.disabled = true
	
	if Input.is_action_just_pressed("Attack"):
		$attackHitbox/CollisionPolygon2D.disabled = false
		attack_timer.start()
		$attackHitbox/Sprite2D.visible = true
	
	if attack_timer.time_left > 0:
		$attackHitbox/Sprite2D.visible = true
		$attackHitbox/CollisionPolygon2D.disabled = false
	
#attack hits something :O
func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if not body is Player:
		if attack_hitbox.rotation_degrees*facing == 90:
			if body.is_in_group("pogoable"):
				velocity.y = -1000
				canDash = true
		elif attack_hitbox.rotation_degrees*facing == -90:
			pass
		else:
			velocity.x = move_toward(velocity.x, -800*facing, SPEED*2) 
		
		
func handle_animation() -> void: 
	if facing == -1:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	if Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
		sprite.play("walk")
	else:
		sprite.play("idle")

func death() -> void:
	if HP <= 0:
		HP = HPMax
		velocity = Vector2.ZERO
		position = lastRespawnPoint

func kusarigama() -> void:
	pass
	
func _on_dash_timer_timeout() -> void:
	stopDash = true #go to the "if stopDash:" line in physics process

func _on_death_zone_body_entered(body: Node2D) -> void:
	
	var player := body as Player
	if player:
		position = Vector2(1120,432)


func _on_damage_hitbox_body_entered(body: Node2D) -> void:
	if not body is Player:
		if body.is_in_group("damage"):
			if damage_cooldown.time_left<=0:
				HP-=1
				damage_cooldown.start()
			if body.position.y>=position.y+damage_hitbox.shape.size.y/2:
				velocity.y = move_toward(velocity.y, -500, SPEED*2)
			else:
				velocity.x = move_toward(velocity.x, -900*facing, SPEED*2)
			freezeFrame(0.1, 0.1) 
			 
			

func freezeFrame(timescale: float, duration: float) -> void:
	Engine.time_scale = timescale
	await get_tree().create_timer(duration,true, false, true).timeout
	Engine.time_scale= 1.0
