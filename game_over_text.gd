extends Label


func _ready() -> void:
	EventBus.mine_revealed.connect(on_mine_revealed)
	visible = false


func on_mine_revealed(_cell: CellComponent):
	visible = true
