## 地图内关于寻路算法中的一系列设置
class_name 开拓者类
extends Resource

var _网格类: Resource
var _astar_全图:= AStarGrid2D.new()
var _astar_范围:= AStarGrid2D.new()

## 移动范围格子集将用于范围内寻路路径绘制，障碍格子集将收入地形障碍
func _init(_网格类_: 网格类, 移动范围格子集:= PackedVector2Array(), 障碍格子集:= PackedVector2Array(), 攻击范围格子集:= PackedVector2Array()) -> void:
	_网格类 = _网格类_
	_astar_全图.region = Rect2i(0, 0, _网格类.网格地图大小.x, _网格类.网格地图大小.y)
	_astar_全图.cell_size = _网格类.格子大小
	_astar_全图.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar_全图.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar_全图.default_estimate_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	_astar_全图.update()
	
	_astar_范围.region = Rect2i(0, 0, _网格类.网格地图大小.x, _网格类.网格地图大小.y)
	_astar_范围.cell_size = _网格类.格子大小
	_astar_范围.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar_范围.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar_范围.default_estimate_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	_astar_范围.update()
	
	if not 障碍格子集.is_empty():
		for i in 障碍格子集:
			设置全图障碍(i)
			设置范围障碍(i)
	
	# 将攻击范围设为障碍
	if not 攻击范围格子集.is_empty():
		for i in 攻击范围格子集:
			设置全图权重(i, 2)
	
	# 将地图内，移动范围外的位置都设为障碍
	for i in _网格类.网格地图大小.x:
		for j in _网格类.网格地图大小.y:
			if not 移动范围格子集.has(Vector2i(i, j)):
				设置范围障碍(Vector2i(i, j))

func 计算全图路径(起点: Vector2i, 终点: Vector2i) -> PackedVector2Array:
	# 如果没有通往目标的有效路径，get_id_path第三个变量为true，会返回通往距离目标最近的可达点的路径。
	# 以达到光标在攻击范围之外也可以完成寻路的目的
	return _astar_全图.get_id_path(起点, 终点, true)

func 设置全图障碍(障碍坐标: Vector2i) -> void:
	_astar_全图.set_point_solid(障碍坐标)

func 设置全图权重(格子坐标: Vector2i, 权重值: float) -> void:
	_astar_全图.set_point_weight_scale(格子坐标, 权重值)

func 计算范围路径(起点: Vector2i, 终点: Vector2i) -> PackedVector2Array:
	# 如果没有通往目标的有效路径，get_id_path第三个变量为true，会返回通往距离目标最近的可达点的路径。
	# 以达到光标在攻击范围之外也可以完成寻路的目的
	return _astar_范围.get_id_path(起点, 终点, true)

func 设置范围障碍(障碍坐标: Vector2i) -> void:
	_astar_范围.set_point_solid(障碍坐标)

func 设置范围权重(格子坐标: Vector2i, 权重值: float) -> void:
	_astar_范围.set_point_weight_scale(格子坐标, 权重值)
