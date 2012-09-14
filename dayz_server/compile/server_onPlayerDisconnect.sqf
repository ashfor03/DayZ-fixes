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

private ["_isInjured","_isCardiac","_unconscious"];
_isInjured 	= _object getVariable["USEC_injured",false];
_isCardiac 	= _object getVariable["USEC_isCardiac",false];
_unconscious 	= _object getVariable["NORRN_unconscious",false];

diag_log format["DISCONNECT: %1 (%2) Object: %3, _characterID: %4", _playerName,_playerID,_object,_characterID];

/* if you want to kill injured player - remove this comment
diag_log format["DISCONNECT: _isInjured=%1,_isCardiac=%2,_unconscious=%3",_isInjured,_isCardiac,_unconscious];

if ( _isInjured or _isCardiac or _unconscious ) then {
	_object setDamage 1;
	dayzDeath = [_characterID,0,_object,_playerID,_playerName];
	_id = dayzDeath call server_playerDied;
};
if you want to kill injured player - remove this comment */ 

[_object,[],true] call server_playerSync;

_id = [_playerID,_characterID,2] spawn dayz_recordLogin;

if (!isNull _object) then {
	if (alive _object) then {
		_myGroup = group _object;
		deleteVehicle _object;
		deleteGroup _myGroup;
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