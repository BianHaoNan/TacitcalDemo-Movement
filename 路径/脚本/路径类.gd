## 绘制单位的移动路径
class_name 路径类
extends TileMapLayer

@export var _网格类: Resource = preload("res://自定义资源/网格类.tres")

var _开拓者类: 开拓者类
var 全图路径:= PackedVector2Array()
var 范围内路径:= PackedVector2Array()

func 初始化AStarGrid2D(移动范围格子集:= PackedVector2Array(), 障碍格子集:= PackedVector2Array(), 攻击范围格子集:= PackedVector2Array()) -> void:
	_开拓者类 = 开拓者类.new(_网格类, 移动范围格子集, 障碍格子集, 攻击范围格子集)

## 重置开拓者类，用于移除已绘制的路径
func stop() -> void:
	_开拓者类 = null
	clear()

func 新_绘制移动路径(起点: Vector2i, 终点: Vector2i) -> void:
	clear()
	范围内路径 = _开拓者类.计算范围路径(起点, 终点)
	# 在TileMapLayer上绘制路线
	set_cells_terrain_path(范围内路径, 0, 0)

func 获取全图路径在范围内的终点(起点: Vector2i, 终点: Vector2i, 移动范围格子集:= PackedVector2Array()) -> Vector2i:
	var 中转 : Array[Vector2i]
	for i in 移动范围格子集:
		中转.append(Vector2i(i))
	var 范围内全图路径 : Array[Vector2i]
	var 范围内路径终点: Vector2i
	全图路径 = _开拓者类.计算全图路径(起点, 终点)
	# 取出位于移动范围内的路径坐标用作绘制
	for i in 全图路径:
		if 中转.has(Vector2i(i)):
			范围内全图路径.append(Vector2i(i))
	if 范围内全图路径.size() != 0:
		范围内路径终点 = 范围内全图路径[-1]
	return 范围内路径终点

#func _ready() -> void:
	#var 起:= Vector2i(0, 0)
	#var 终:= Vector2i(16, 16)
	#var 移动范围格子集:= PackedVector2Array()
	#for x in 终.x - 起.x + 1:
		#for y in 终.y - 起.y +1:
			#移动范围格子集.append(起 + Vector2i(x, y))
	#初始化AStarGrid2D()
	#绘制移动路径(起, 终, 移动范围格子集)
