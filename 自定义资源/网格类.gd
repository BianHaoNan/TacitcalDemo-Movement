## 网格（棋盘）属性
## 计算、换算网格内的坐标
class_name 网格类
extends Resource

@export var 网格地图大小 := Vector2i(20, 20)
@export var 格子大小 := Vector2i(16, 16)

var 格子宽高除2 = 格子大小 / 2

func 计算格子坐标(地图坐标: Vector2) -> Vector2i:
	return (地图坐标 / Vector2(格子大小)).floor()

func 计算格子中心地图坐标(格子坐标: Vector2) -> Vector2i:
	return Vector2i(格子坐标 * Vector2(格子大小) + Vector2(格子宽高除2))

func 判断格子是否在网格地图内(格子坐标: Vector2i) -> bool:
	return 格子坐标.x >= 0 and 格子坐标.x < 网格地图大小.x and 格子坐标.y >= 0 and 格子坐标.y < 网格地图大小.y

func 将格子限制在界限内(格子坐标: Vector2i) -> Vector2i:
	var 结果 := 格子坐标
	结果.x = clamp(结果.x, 0, 网格地图大小.x - 1.0)
	结果.y = clamp(结果.y, 0, 网格地图大小.y - 1.0)
	return 结果

func 获取全图块坐标() -> Array:
	var 结果 : Array[Vector2i]
	for x in 网格地图大小.x:
		for y in 网格地图大小.y:
			结果.append(Vector2i(x, y))
	return 结果
