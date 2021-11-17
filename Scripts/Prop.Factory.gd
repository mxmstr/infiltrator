extends Node

export(NodePath) var target
export(String) var container_name
export(String, MULTILINE) var products


func _ready():
	
	var products_list = []
	var new_product = {}
	var i = 0
	
	for param in products.split(' '):
		
		if i == 0:
			new_product.target = param
		if i == 2:
			new_product.item = param
		if i == 3:
			new_product.amount = param
		
		i = i + 1 
		if i > 3:
			i = 0
			products_list.append(new_product)
	
	
	var container = owner.get_node(container_name)
	
#	for product in products_list:
#
#		if product.target == 'target':
#
#			Meta.CreateLink(Meta._add_actor(product.item))
