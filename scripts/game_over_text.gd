extends RichTextLabel
class_name GameOverText


func _ready() -> void:
	EventBus.mine_revealed.connect(_on_mine_revealed)
	visible = false


func _on_mine_revealed(cell: CellComponent):
	visible = true
