extends Camera2D

@onready var player: Player = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player.velocity.x != 0:
		position.x = move_toward(position.x, 200*player.facing, position_smoothing_speed)
	if player.velocity.x == 0:
		position.x =  move_toward(position.x, 0, position_smoothing_speed/2)
	if player.is_clinging: 
		position.x =  move_toward(position.x, 200*player.facing, position_smoothing_speed)
