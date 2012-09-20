/*

*/
private["_hasDel","_serial","_object","_updates","_myGroup","_nearVeh"];
_playerID = _this select 0;
_playerName = _this select 1;
_object = call compile format["player%1",_playerID];
_characterID =	_object getVariable ["characterID","0"];

if (vehicle _object != _object) then {
	_object action ["eject", vehicle _object];
};

diag_log format["DISCONNECT: %1 (%2) Object: %3, _characterID: %4", _playerName,_playerID,_object,_characterID];

[_object,[],true] call server_playerSync;
_id = [_playerID,_characterID,2] spawn dayz_recordLogin;

if (!isNull _object) then {
	if (alive _object) then {
		[_object,_playerID,_characterID] spawn disco_playerMorph;
//		_myGroup = group _object;
//		deleteVehicle _object;
//		deleteGroup _myGroup;
	};
};

/*
//Update Vehicle
if (!isNull _object) then {
	_nearVeh = nearestObjects [_object, ["AllVehicles","TentStorage"], 20];
	{
		[_x,"gear"] call server_updateObject;
		if (_x isKindOf "AllVehicles") then {
			[_x,"repair"] call server_updateObject;
			[_x,"position"] call server_updateObject;
		};
	} forEach _nearVeh;
};
*/