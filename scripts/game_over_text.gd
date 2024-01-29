extends RichTextLabel


func _ready() -> void:
	EventBus.cell_revealed.connect(on_mine_revealed)
	visible = false


func on_mine_revealed(cell: CellComponent):
	if cell.cell_state == Enums.CellState.MINE:
		visible = true
