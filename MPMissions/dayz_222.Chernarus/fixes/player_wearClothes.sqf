/*
hook for player_wearClothes
item spawn player_wearClothes;
*/
private "_item";
_item = _this;
_isInVehicle = 	vehicle player != player;
if ( _item in (magazines player) && !isInVehicle ) then { _item spawn player_wearClothes_orig };
