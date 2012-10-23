/*

*/
private["_characterID","_minutes","_newObject","_playerID","_playerName","_playerID","_myGroup","_group","_source"];
//[unit, weapon, muzzle, mode, ammo, magazine, projectile]
_characterID = 	_this select 0;
_minutes =	_this select 1;
_newObject = 	_this select 2;
_playerID = 	_this select 3;
_playerName = 	_this select 4;
_source = 	_this select 5;
_method = 	_this select 6;

private["_distance","_sourceName","_weapon","_deathMessage"];
if ( isNull _source ) then { 
	_deathMessage = format["%1 [%2] died. (zombie? suicide? or...)",_playerName,_playerID];
} else { 
	_distance = _newObject distance _source;
	_sourceName = _source getVariable["bodyName","unknown"];
	_weapon = currentWeapon _source;
	_deathMessage = format["%1 [%2] died from %3 [Object:%4]. Distance:%5 Weapon:%6 Method:%7",_playerName,_playerID,_sourceName,_source,_distance,_weapon,_method];
	// _weapon may be inaccurate
	// _method is inaccurate
	// TODO: ...
};

dayz_disco = dayz_disco - [_playerID];
_newObject setVariable["processedDeath",time];

if !(isnil "_characterID") then {
	
	if (_characterID != "0") then {
		_key = format["CHILD:202:%1:%2:",_characterID,_minutes];
		//diag_log ("HIVE: WRITE: "+ str(_key));
		_key call server_hiveWrite;
	} else {
		deleteVehicle _newObject;
	};
} else {
	deleteVehicle _newObject;
};

diag_log ("DEBUG: server_playerDied: " + _deathMessage);
