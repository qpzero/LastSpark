extends Control

@onready var mana_bar = $manaBar
@onready var player: Player = $"../../../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	mana_bar.size.x = (player.MP/player.MPMax)*(size.x-30)
