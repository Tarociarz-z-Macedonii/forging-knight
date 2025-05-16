extends Node2D

var blueprints: Array[BlueprintData]

func add_blueprint(blueprint):
	blueprints.append(blueprint)
	print('blueprint added')
