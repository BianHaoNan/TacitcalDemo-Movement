class_name 地图类
extends TileMapLayer

enum 地形 {
	平地,
	森林,
	山地
}

## vector2i：int | ***暂时将 地形id+1 作为移动力消耗量，后续根据兵种进行区分
var 格子坐标_扩散消耗值 := {}

func _ready() -> void:
	for i in get_used_cells():
		格子坐标_扩散消耗值[i] = get_cell_tile_data(i).terrain + 1
