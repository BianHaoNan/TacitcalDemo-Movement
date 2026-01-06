## 地图内关于寻路算法中的一系列设置
class_name 开拓者类
extends Resource

var _网格类: Resource
var _astar:= AStarGrid2D.new()

## 移动范围格子集将用于范围内寻路路径绘制，障碍格子集将收入地形障碍 | ***未完成绘制路径功能的完全体，暂且将攻击范围格子集作为障碍限制路径范围
func _init(_网格类_: 网格类, 移动范围格子集:= PackedVector2Array(), 障碍格子集:= PackedVector2Array(), 攻击范围格子集:= PackedVector2Array()) -> void:
	
	_网格类 = _网格类_
	_astar.region = Rect2i(0, 0, _网格类.网格地图大小.x, _网格类.网格地图大小.y)
	_astar.cell_size = _网格类.格子大小
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.update()
	
	print_debug("_网格类.网格地图大小.x : ",_网格类.网格地图大小.x)
	if not 障碍格子集.is_empty():
		for i in 障碍格子集:
			设置障碍(i)
	
	# 将攻击范围设为障碍
	if not 攻击范围格子集.is_empty():
		for i in 攻击范围格子集:
			设置障碍(i)

func 计算路径(起点: Vector2i, 终点: Vector2i) -> PackedVector2Array:
	# 如果没有通往目标的有效路径，get_id_path第三个变量为true，会返回通往距离目标最近的可达点的路径。
	# 以达到光标在攻击范围之外也可以完成寻路的目的
	return _astar.get_id_path(起点, 终点, true)

func 设置障碍(障碍坐标: Vector2i) -> void:
	_astar.set_point_solid(障碍坐标)

func 设置权重(格子坐标: Vector2i, 权重值: float) -> void:
	_astar.set_point_weight_scale(格子坐标, 权重值)
