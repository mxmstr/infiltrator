extends 'res://Scripts/Link.gd'

export(String) var container
export(String, MULTILINE) var products

var products_list = []
var outputs = []

signal finished


func _ready():
	
	if is_queued_for_deletion():
		return
	
	yield(get_tree(), 'idle_frame')
	
#	products = products.c_escape().replace('\\n', ' ')
	
	var new_product = {}
	var i = 0
	
	for product in products.c_escape().split('\\n'):
	
		for param in product.split(' ', false):
			
			if i == 0:
				new_product.target = param
			if i == 1:
				new_product.target_container = param
			if i == 3:
				new_product.amount = param
			if i == 4:
				new_product.item = param
				products_list.append(new_product.duplicate())
				new_product = {}
				i = 0
				continue
			
			i = i + 1
		
		new_product = {}
		i = 0
	
	
	for product in products_list:
		
		if product.target == 'target':
			
			_create_product(get_node(to), container, product.amount, product.item)
		
		else:
			
			var output = Meta.AddActor(product.target)
			outputs.append(output)
			
			_create_product(output, product.target_container, product.amount, product.item)
	
	emit_signal('finished')


func _create_product(target, target_container, amount, item):
	
	for i in range(amount):
		
		if target.get_node(target_container).factory_mode:
		
			target.get_node(target_container)._add_item(item)
		
		else:
		
			var new_actor = Meta.AddActor(item)
			
			Meta.CreateLink(target, new_actor, 'Contains', { 'container': target_container })
			
			for subproduct in products_list:
				
				if subproduct.target == item:
					
					_create_product(new_actor, subproduct.target_container, subproduct.amount, subproduct.item)