extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	EventBus.mine_revealed.connect(on_mine_revealed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_mine_revealed(cell: CellComponent):
	visible = true
