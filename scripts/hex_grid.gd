extends TileMap
class_name HexGrid

const LAYER := 0
const SOURCE_ID := 2

const RADIUS_LIMIT := 10
const START_CUBE := Vector3i(0, 0, 0)
const MINE_COUNT := 50

const ONE := Vector2i(0, 0)
const TWO := Vector2i(1, 0)
const THREE := Vector2i(2, 0)
const RED_MINE := Vector2(3, 0)
const FOUR := Vector2i(0, 1)
const FIVE := Vector2i(1, 1)
const SIX := Vector2i(2, 1)
const EMPTY := Vector2i(3, 1)
const FLAG := Vector2i(0, 2)
const HIDDEN := Vector2i(1, 2)
const MINE := Vector2i(2, 2)
const MINE_COUNT_TO_ATLAS := {
	0: EMPTY,
	1: ONE, 2: TWO, 3: THREE,
	4: FOUR, 5: FIVE, 6: SIX
}

var cells := {}
var is_mine_revealed := false
@onready var hex_grid_generator: HexGridGenerator = $"Hex Grid Generator"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.cell_revealed.connect(_on_cell_reveal)
	EventBus.cell_flagged.connect(_on_cell_flag)
	cells = hex_grid_generator.generate_grid(START_CUBE, RADIUS_LIMIT, MINE_COUNT)
	_update_grid()

	
func _on_cell_reveal(cell: CellComponent):
	_update_cell(cell)
	if cell.cell_state == Enums.CellState.MINE:
		is_mine_revealed = true
		return
	
	if cell.cell_state == Enums.CellState.EMPTY:
		_reveal_connected_empty_cells(cell)
	
	
func _on_cell_flag(cell: CellComponent):
	_update_cell(cell)


func _update_grid() -> void:
	for cell: CellComponent in cells.values():
		_update_cell(cell)
	

func _input(event: InputEvent) -> void:	
	var mouse_pos: Vector2 = get_global_mouse_position()
	var cell_pos: Vector2i = local_to_map(mouse_pos)
	var cell_source_id: int = get_cell_source_id(LAYER, cell_pos)
	if cell_source_id == -1:
		return
		
	var cell_cube: Vector3i =  CellUtils.oddr_to_cube(cell_pos)
	var cell: CellComponent = cells[cell_cube]
	if event.is_action_pressed("select_cell"):
		_select_cell(cell)
	if event.is_action_pressed("flag_cell"):
		_flag_cell(cell)


func _set_cell_v2(cell_pos: Vector2i, atlas_pos: Vector2i) -> void:
	set_cell(LAYER, cell_pos, SOURCE_ID, atlas_pos)


func _update_cell(cell: CellComponent) -> void:
	var oddr: Vector2i = CellUtils.cube_to_oddr(cell.pos)
	var texture: Vector2i
	if cell.is_flagged:
		texture = FLAG
	elif not cell.is_revealed:
		texture = HIDDEN
	elif cell.cell_state == Enums.CellState.MINE:
		texture = RED_MINE
	else:
		texture = MINE_COUNT_TO_ATLAS[cell.neighbor_mine_count]
	_set_cell_v2(oddr, texture)


func _reveal_cell(cell: CellComponent) -> void:
	cell.reveal()
	_update_cell(cell)


func _reveal_connected_empty_cells(cell: CellComponent) -> void:
	var connected_empty_cells: Array[CellComponent] = _connected_empty_cells(cell)
	for connected_cell in connected_empty_cells:
		_reveal_cell(connected_cell)


func _connected_empty_cells(cell: CellComponent) -> Array[CellComponent]:
	var stack: Array[Vector3i] = [cell.pos]
	var visited: Dictionary = {}
	var connected_cells: Array[CellComponent] = []
	while stack:
		var popped_cube: Vector3i = stack.pop_back()
		if popped_cube not in cells or popped_cube in visited:
			continue

		var popped_cell: CellComponent = cells[popped_cube]
		if popped_cell.is_flagged:
			continue

		connected_cells.append(popped_cell)
		visited[popped_cube] = true

		if popped_cell.neighbor_mine_count == 0:
			stack.append_array(CellUtils.cube_neighbors(popped_cube))
	return connected_cells


func _select_cell(cell: CellComponent) -> void:
	if is_mine_revealed or cell.is_flagged:
		return
	cell.select()


func _flag_cell(cell: CellComponent) -> void:
	if is_mine_revealed:
		return
	cell.flag()
