extends Control

@onready var player : Player = $"../../../Player"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if size.x != (85* get_child_count()) + (20*(get_child_count()-1)):
		size.x = (85* get_child_count()) + (20*(get_child_count()-1))
	updateHPBar()
	for i in get_child_count()-(player.HPMax-player.HP):
		var heart = get_child(i)
		heart.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		heart.modulate = Color(1,0,0,1) 
	for i in get_child_count()-player.HP:
		var heart = get_child(i+player.HP)
		heart.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		heart.modulate = Color(0,0,0,1) 

func updateHPBar() -> void:
	if get_child_count() != player.HPMax: 
		var a = get_child_count()
		for i in get_child_count():
			get_child(i).queue_free()
			  
		print(" ")
		#currentHealthMax = player.HPMax
		for i in player.HPMax:
			var heart = ColorRect.new() #replace with texture rect when texture is ready
			add_child(heart)
		for i in get_child_count():
			var heart = get_child(i)
			heart.size_flags_horizontal=Control.SIZE_EXPAND_FILL
			heart.modulate = Color(1,0,0,1) 
		var b = get_child_count()
		size.x = (85*(b-a)) + (20*(b-a-1))
		#print(player.HPMax, " ", b-a, " ",  (85*(b-a)) + (20*(b-a-1)) ) 
