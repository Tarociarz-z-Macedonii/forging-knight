class_name BlueprintMaterialLabel
extends Label
var item_name: String
var max_amount: int
var amount: int

func set_amount():
	text = str(amount)  + " / " + str(max_amount) 
