/*
[_object,_playerID,_characterID] spawn disco_playerMorph;
*/
//private["_playerName","_updates","_playerID","_characterID","_humanity","_worldspace","_model","_newUnit","_object","_class","_position","_dir","_group","_oldUnit","_currentWpn","_muzzles","_currentAnim","_wounds"];
private["_object","_playerID","_characterID","_playerName","_model","_position","_dir","_currentAnim"];
_object 	= _this select 0;
_playerID 	= _this select 1; //playerUID
_characterID 	= _this select 2; //characterID
_playerName	= name _object;
_model		= typeOf _object;
_position 	= getPosATL _object;
_dir 		= getDir _object;
_currentAnim 	= animationState _object;

_object removeAllEventHandlers "FiredNear";
_object removeAllEventHandlers "HandleDamage";
_object removeAllEventHandlers "Killed";
_object removeAllEventHandlers "Fired";

private["_updates","_humanity","_legs","_arms","_medical","_worldspace","_zombieKills","_headShots","_humanKills","_banditKills","_temp"];
_updates 	= _object getVariable["updatePlayer",[false,false,false,false,false]];
_updates set [0,true];
_object setVariable["updatePlayer",_updates,true];

_humanity 	= _object getVariable["humanity",0];
_temp 		= round(_object getVariable ["temperature",100]);
_worldspace 	= [round(_dir),_position];
_zombieKills 	= _object getVariable ["zombieKills",0];
_headShots 	= _object getVariable ["headShots",0];
_humanKills 	= _object getVariable ["humanKills",0];
_banditKills 	= _object getVariable ["banditKills",0];
_medical 	= _object call player_sumMedical;

//BackUp Weapons and Mags
private ["_weapons","_magazines","_primweapon","_secweapon"];
_weapons 	= weapons _object;
_magazines	= magazines _object;
_primweapon	= primaryWeapon _object;
_secweapon	= secondaryWeapon _object;

//Checks
if(!(_primweapon in _weapons) && _primweapon != "") then {
	_weapons = _weapons + [_primweapon];
};

if(!(_secweapon in _weapons) && _secweapon != "") then {
	_weapons = _weapons + [_secweapon];
};

if(count _magazines == 0) then {
	_magazines = magazines _object;
};

//BackUp Backpack
private ["_newBackpackType","_backpackWpn","_backpackMag"];
	_newBackpackType = typeOf (unitBackpack _object);
	if(_newBackpackType != "") then {
		_backpackWpn = getWeaponCargo unitBackpack _object;
		_backpackMag = getMagazineCargo unitBackpack _object;
	};

//Get Muzzle
private ["_currentWpn","_muzzles"];
	_currentWpn = "";
	_muzzles = getArray(configFile >> "cfgWeapons" >> _currentWpn >> "muzzles");
	if (count _muzzles > 1) then {
		_currentWpn = currentMuzzle _object;
	};

private ["_primary"];
_doLoop = 0;
while {_doLoop < 5} do {
	_key = format["CHILD:101:%1:%2:%3:",_playerID,dayZ_instance,_playerName];
	_primary = [_key,false,dayZ_hivePipeAuth] call server_hiveReadWrite;
	if (count _primary > 0) then {
		if ((_primary select 0) != "ERROR") then {
			_doLoop = 9;
		};
	};
	_doLoop = _doLoop + 1;
};
private ["_group","_newUnit"];
// get from DB for ammo count
_magazines = (_primary select 4) select 1;

//	deleteVehicle _object;	
//Create New Character
	_group 		= createGroup west;
	_newUnit 	= _group createUnit [_model,[0,0,0],[],0,"NONE"];
// magic!
	[_newUnit] joinSilent grpNull;
	sleep 0.2;
	[_newUnit] joinSilent _group;
	_group reveal _newUnit;
//Clear New Character
	{_newUnit removeMagazine _x;} forEach (magazines _newUnit);
	removeAllWeapons _newUnit;

//Equip New Charactar
{ _newUnit addMagazine _x } forEach _magazines;
{ _newUnit addWeapon _x } forEach _weapons;
if(_primweapon !=  (primaryWeapon _newUnit)) then { _newUnit addWeapon _primweapon };
if(_secweapon != (secondaryWeapon _newUnit) && _secweapon != "") then {	_newUnit addWeapon _secweapon };

//Add and Fill BackPack
private["_newBackpack"];
if (!isNil "_newBackpackType") then {
	if (_newBackpackType != "") then {
		_newUnit addBackpack _newBackpackType;
		_newBackpack = unitBackpack _newUnit;
		//Fill backpack contents
		//Weapons
		_backpackWpnTypes = [];
		_backpackWpnQtys = [];
		if (count _backpackWpn > 0) then {
			_backpackWpnTypes = _backpackWpn select 0;
			_backpackWpnQtys = 	_backpackWpn select 1;
		};
		_countr = 0;
		{
			_newBackpack addWeaponCargoGlobal [_x,(_backpackWpnQtys select _countr)];
			_countr = _countr + 1;
		} forEach _backpackWpnTypes;
		//magazines
		_backpackmagTypes = [];
		_backpackmagQtys = [];
		if (count _backpackmag > 0) then {
			_backpackmagTypes = _backpackMag select 0;
			_backpackmagQtys = 	_backpackMag select 1;
		};
		_countr = 0;
		{
			_newBackpack addmagazineCargoGlobal [_x,(_backpackmagQtys select _countr)];
			_countr = _countr + 1;
		} forEach _backpackmagTypes;
	};
};
//set medical values
if (count _medical > 0) then {
	_newUnit setVariable["USEC_isDead",(_medical select 0),true];
	_newUnit setVariable["NORRN_unconscious", (_medical select 1), true];
	_newUnit setVariable["USEC_infected",(_medical select 2),true];
	_newUnit setVariable["USEC_injured",(_medical select 3),true];
	_newUnit setVariable["USEC_inPain",(_medical select 4),true];
	_newUnit setVariable["USEC_isCardiac",(_medical select 5),true];
	_newUnit setVariable["USEC_lowBlood",(_medical select 6),true];
	_newUnit setVariable["USEC_BloodQty",(_medical select 7),true];
	_newUnit setVariable["unconsciousTime",(_medical select 10),true];
	//Add Wounds
	{
		_newUnit setVariable[_x,true,true];
		[_newUnit,_x,_hit] spawn fnc_usec_damageBleed;
		usecBleed = [_newUnit,_x,0];
		publicVariable "usecBleed";
	} forEach (_medical select 8);
	//Add fractures
	_fractures = (_medical select 9);
	_newUnit setVariable ["hit_legs",(_fractures select 0),true];
	_newUnit setVariable ["hit_hands",(_fractures select 1),true];
} else {
	//Reset Fractures
	_newUnit setVariable ["hit_legs",0,true];
	_newUnit setVariable ["hit_hands",0,true];
	_newUnit setVariable ["USEC_injured",false,true];
	_newUnit setVariable ["USEC_inPain",false,true];	
};
//General Stats
_newUnit setVariable["characterID",str(_characterID),true];
_newUnit setVariable["worldspace",_worldspace,true];
_newUnit setVariable["bodyName",_playerName,true];
_newUnit setVariable["playerID",_playerID,true];

//Move to position
	_newUnit allowDamage true;
	_newUnit switchMove _currentAnim;
	_newUnit setPosATL _position;
	_newUnit setDir _dir;
	_newUnit disableConversation true;
	_newUnit playActionNow "Die";
	_newUnit setCaptive false;
//	_newUnit disableAi "ANIM";
//	addSwitchableUnit _newUnit;
//	setPlayable _newUnit;

// для чего это делается?
	_newUnit addWeapon "Loot";
	_newUnit addWeapon "Flare";
// deleteVehicle _oldUnit;
botPlayers = botPlayers + [_playerID];
_mydamage_eh1 = _newUnit addeventhandler ["HandleDamage",{ _this call disco_damageHandler }];
//mydamage_eh3 = _newUnit addEventHandler ["Killed", {[_characterID,0,_newUnit,_playerID,_playerName];}];
//call compile format["player%1 = _newUnit", _playerID];
//diag_log format["botPlayers: %1", botPlayers];

sleep 45;
//[_newUnit,[],true] call server_playerSync;
_newUnit removeAllEventHandlers "handleDamage";

if (alive _newUnit) then {
	private["_playerBackp"];
	_playerBackp = [_newBackpackType,getWeaponCargo _newBackpack,getMagazineCargo _newBackpack];
	_medical = _newUnit call player_sumMedical;
	_currentState = [_currentWpn,_currentAnim,_temp];
//Wait for HIVE to be free
//Send request
	_key 	= format["CHILD:201:%1:%2:%3:%4:%5:%6:%7:%8:%9:%10:%11:%12:%13:%14:%15:%16:",
			_characterID,
			_worldspace,
			[],
			_playerBackp,
			_medical,
			false,
			false,
			0,0,0,0,
			[],
			0,0,
			_model,
			0];
	diag_log format["DISCONNECT: %1 %2",_playerName,_key];
	_key call server_hiveWrite;
	_group = group _newUnit;
	deleteVehicle _newUnit;
	deleteGroup _group;
};
botPlayers = botPlayers - [_playerID];
