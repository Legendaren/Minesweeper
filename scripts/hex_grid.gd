@tool
extends TileMap
class_name HexGrid

const LAYER := 0
const SOURCE_ID := 0

const ONE := Vector2i(0, 0)
const TWO := Vector2i(1, 0)
const THREE := Vector2i(2, 0)
const RED_MINE := Vector2(3, 0)
const FOUR := Vector2i(0, 1)
const FIVE := Vector2i(1, 1)
const SIX := Vector2i(2, 1)
const START_CELL := Vector2i(3, 1)
const EMPTY := Vector2i(0, 3)
const FLAG := Vector2i(0, 2)
const HIDDEN := Vector2i(1, 2)
const MINE := Vector2i(2, 2)
const MINE_COUNT_TO_ATLAS := {
	0: EMPTY,
	1: ONE, 2: TWO, 3: THREE,
	4: FOUR, 5: FIVE, 6: SIX
}


@export_range(5, 25) var radius_limit := 15:
	get:
		return radius_limit
	set(value):
		radius_limit = value
		_create_grid()

@export_range(1, 100) var mine_count := 80:
	get:
		return mine_count
	set(value):
		mine_count = value

@export_group("Start Cube")
@export var show_start_cube := true:
	get:
		return show_start_cube
	set(value):
		show_start_cube = value
		_create_grid()

@export var start_cube_position := Vector3i(0, 0, 0):
	get:
		return start_cube_position
	set(value):
		start_cube_position = value
		update_configuration_warnings()
		_create_grid()


var cells := {}
var is_mine_revealed := false
var has_won := false
var at_least_one_cell_selected := false
@onready var hex_grid_generator: HexGridGenerator = $"Hex Grid Generator"

func _ready() -> void:
	if not Engine.is_editor_hint():
		EventBus.cell_revealed.connect(_on_cell_reveal)
		EventBus.cell_flagged.connect(_on_cell_flagged)
		EventBus.mine_revealed.connect(_on_mine_reveal)
	assert(start_cube_position.x + start_cube_position.y + start_cube_position.z == 0, "x + y + z must be equal to 0")
	_create_grid()


func _get_configuration_warnings():
	var warnings: Array[String] = []
	if start_cube_position.x + start_cube_position.y + start_cube_position.z != 0:
		warnings.append("Start cube must consist of valid coordinates (x + y + z = 0)")
	return warnings

func _create_grid():
	clear()
	cells = hex_grid_generator.generate_empty_grid(start_cube_position, radius_limit)
	_update_grid()


func _on_mine_reveal(_cell: CellComponent):
	is_mine_revealed = true


func _on_cell_reveal(cell: CellComponent):
	_update_cell(cell)
	if cell.is_empty():
		_reveal_connected_empty_cells(cell)


func _on_cell_flagged(cell: CellComponent):
	_update_cell(cell)


func _update_grid() -> void:
	for cell: CellComponent in cells.values():
		if Engine.is_editor_hint():
			_update_cell_editor(cell)
		else:
			_update_cell(cell)


func _input(event: InputEvent) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var cell_pos: Vector2i = local_to_map(mouse_pos)
	var cell_source_id: int = get_cell_source_id(LAYER, cell_pos)
	var is_cell_empty := cell_source_id == -1
	if is_cell_empty:
		return

	var cell_cube: Vector3i =  CellUtils.oddr_to_cube(cell_pos)
	if cell_cube not in cells:
		return
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
	elif cell.is_mine():
		texture = RED_MINE
	else:
		texture = MINE_COUNT_TO_ATLAS[cell.neighbor_mine_count]
	_set_cell_v2(oddr, texture)
	if _are_all_non_mine_cells_revealed():
		has_won = true
		EventBus.game_win.emit()


func _update_cell_editor(cell: CellComponent):
	var oddr: Vector2i = CellUtils.cube_to_oddr(cell.pos)
	if cell.pos == start_cube_position and show_start_cube:
		_set_cell_v2(oddr, START_CELL)
	else:
		_set_cell_v2(oddr, HIDDEN)

func _reveal_cell(cell: CellComponent) -> void:
	cell.reveal()
	_update_cell(cell)


func _reveal_connected_empty_cells(cell: CellComponent) -> void:
	var connected_empty_cells: Array[CellComponent] = _connected_empty_cells(cell)
	for connected_cell in connected_empty_cells:
		_reveal_cell(connected_cell)


func _connected_empty_cells(cell: CellComponent) -> Array[CellComponent]:
	var connected_cells: Array[CellComponent] = []
	var neighbor_cubes := CellUtils.cube_neighbors(cell.pos)
	for neighbor in neighbor_cubes:
		if neighbor not in cells:
			continue
		var neighbor_cell: CellComponent = cells[neighbor]
		if neighbor_cell.is_flagged:
			continue
		if not neighbor_cell.is_mine():
			connected_cells.append(neighbor_cell)
	return connected_cells


func _are_all_non_mine_cells_revealed() -> bool:
	for cell: CellComponent in cells.values():
		if not cell.is_mine() and not cell.is_revealed:
			return false
	return true


func _select_cell(cell: CellComponent) -> void:
	if is_mine_revealed or has_won:
		return
	if not at_least_one_cell_selected:
		cells = hex_grid_generator.add_mines_to_grid(cells, mine_count, cell.pos)
		at_least_one_cell_selected = true
	cell.reveal()


func _flag_cell(cell: CellComponent) -> void:
	if is_mine_revealed or has_won:
		return
	cell.flag()
