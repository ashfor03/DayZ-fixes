/*
[_dir,_pos,_objectID,_objectUID] call local_deleteObj;
*/
private["_obj","_id","_uid","_dir","_pos","_key"];
//[dayz_characterID,_tent,[_dir,_location],"TentStorage"]

if (count _this > 2) then {
	_id 	= _this select 2;
	_uid 	= _this select 3;
} else {
	_dir 	= _this select 0;
	_pos 	= _this select 1;
	_uid 	= [_dir,_pos] call dayz_objectUID2;
};

if (isServer) then {
//remove from database
	if (parseNumber _id > 0) then {
		//Send request
		_key = format["CHILD:304:%1:",_id];
		_key call server_hiveWrite;
		diag_log format["DELETE: Deleted by ID: %1",_id];
	};
	if (parseNumber _uid > 0) then {
		//Send request
		_key = format["CHILD:310:%1:",_uid];
		_key call server_hiveWrite;
		diag_log format["DELETE: Deleted by UID: %1",_uid];
	};
};