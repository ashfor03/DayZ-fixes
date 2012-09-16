/***********************************************************
	PROCESS DAMAGE TO A UNIT
	- Function
	- [unit, selectionName, damage, source, projectile] call disco_damageHandler;
************************************************************/
private["_unit","_characterID","_humanityHit","_myKills","_isBandit","_hit","_damage","_isPlayer","_unconscious","_wound","_isHit","_isInjured","_type","_hitPain","_inPain","_isDead","_isCardiac","_killerID","_evType","_recordable","_inVehicle","_isHeadHit","_isMinor","_scale","_canHitFree","_player_blood"];
_unit = _this select 0;
_hit = _this select 1;
_damage = _this select 2;
_unconscious = _unit getVariable ["NORRN_unconscious", false];
_source = _this select 3;
_ammo = _this select 4;
_type = [_damage,_ammo] call fnc_usec_damageType;
_isMinor = (_hit in USEC_MinorWounds);
_isHeadHit = (_hit == "head_hit");
_inVehicle = (vehicle _unit != _unit);
_evType = "";
_recordable = false;
_isPlayer = (isPlayer _source);
_humanityHit = 0;
_myKills = 0;
_characterID = _unit getVariable ["CharacterID","0"];

_player_blood = _unit getVariable["USEC_BloodQty",1200];

if (_characterID == "0") exitWith
{
	diag_log "DEBUG: disco_damageHandler: CharacterID is 0";
};

//PVP Damage
_scale = 200;
if (_damage > 0.4) then {
	if (_ammo != "zombie") then {
		_scale = _scale + 50;
	};
	if (_isHeadHit) then {
		_scale = _scale + 500;
	};
	if (_source == _unit) then {
		_scale = _scale + 800;
		if (_isHeadHit) then {
			_scale = _scale + 500;
		};
	};
	switch (_type) do {
		case 1: {_scale = _scale + 200};
		case 2: {_scale = _scale + 200};
	};
	//Cause blood loss
	_player_blood = _player_blood - (_damage * _scale);
};

//Record Damage to Minor parts (legs, arms)
if (_hit in USEC_MinorWounds) then {
	if (_ammo == "zombie") then {
		if (_hit == "legs") then {
			[_unit,_hit,(_damage / 6)] call object_processHit;
		} else {
			[_unit,_hit,(_damage / 4)] call object_processHit;
		};
	} else {;
		[_unit,_hit,(_damage / 2)] call object_processHit;
	};
	if (_ammo == "") then {
		[_unit,_hit,_damage] call object_processHit;
	};
};

if (_damage > 0.1) then {
		_unit setVariable["medForceUpdate",true,true];
};
if (_damage > 0.4) then {	//0.25
	/*
		BLEEDING
	*/		
	_wound = _hit call fnc_usec_damageGetWound;
	_isHit = _unit getVariable[_wound,false];
	_rndPain = 		(random 10);
	_rndInfection = (random 1000);
	_hitPain = 		(_rndPain < _damage);
	if ((_isHeadHit) or (_damage > 1.2 and _hitPain)) then {
		_hitPain = true;
	};
	_hitInfection = (_rndInfection < 1);
	//player sidechat format["HitPain: %1, HitInfection %2 (Damage: %3)",_rndPain,_rndInfection,_damage]; //r_player_infected
	if (_isHit) then {
		//Make hit worse
		_player_blood = _player_blood - 50;
	};
	if (_hitInfection) then {
		//Set Infection if not already
		_unit setVariable["USEC_infected",true,true];
		
	};
	if (_hitPain) then {
		//Set Pain if not already
			_unit setVariable["USEC_inPain",true,true];
	};
	if ((_damage > 1.5) and _isHeadHit) then {
		_unit setDamage 1;
		dayzFlies = _unit;
		publicVariable "dayzFlies";
		_unit setVariable ["deathType","shothead",true];
		_key = format["CHILD:202:%1:%2:",_characterID,0];
		diag_log ("HIVE: WRITE: "+ str(_key));
		_key call server_hiveWrite;
	};
};
if(!_isHit) then {
	//Create Wound
	_unit setVariable[_wound,true,true];
//		[_unit,_wound,_hit] spawn fnc_usec_damageBleed;
	usecBleed = [_unit,_wound,_hit];
	publicVariable "usecBleed";

	//Set Injured if not already
	if (!_isInjured) then {
		_unit setVariable["USEC_injured",true,true];
		if (_ammo != "zombie") then {
			dayz_sourceBleeding = _source;
		};
	};
	//Set ability to give blood
	_lowBlood = _unit getVariable["USEC_lowBlood",false];
	if (!_lowBlood) then {
		_unit setVariable["USEC_lowBlood",true,true];
	};
};
if (_type == 1) then {
	/*
		BALISTIC DAMAGE		
	*/		
	if (_damage > 4) then {
		//serious ballistic damage
		_unit setDamage 1;
		dayzFlies = _unit;
		publicVariable "dayzFlies";
		_unit setVariable ["deathType","explosion",true];
		_key = format["CHILD:202:%1:%2:",_characterID,0];
		diag_log ("HIVE: death WRITE: "+ str(_key));
		_key call server_hiveWrite;
	} else {
		if (_damage > 2) then {
			_isCardiac = _unit getVariable["USEC_isCardiac",false];
			if (!_isCardiac) then {
				_unit setVariable["USEC_isCardiac",true,true];
			};
		};
	};
};
if (_type == 2) then {
	/*
		HIGH CALIBRE
	*/
	if (_damage > 4) then {
		//serious ballistic damage
		_unit setDamage 1;
		dayzFlies = _unit;
		publicVariable "dayzFlies";
		_unit setVariable ["deathType","shotheavy",true];
		_key = format["CHILD:202:%1:%2:",_characterID,0];
		diag_log ("HIVE: death WRITE: "+ str(_key));
		_key call server_hiveWrite;
	} else {
		if (_damage > 2) then {
			_isCardiac = _unit getVariable["USEC_isCardiac",false];
			if (!_isCardiac) then {
				_unit setVariable["USEC_isCardiac",true,true];
			};
		};
	};
};

if (_player_blood <= 0) then {
	_unit setDamage 1;
	dayzFlies = _unit;
	publicVariable "dayzFlies";
	_unit setVariable ["deathType","bled",true];
	_key = format["CHILD:202:%1:%2:",_characterID,0];
	diag_log ("HIVE: death WRITE: "+ str(_key));
	_key call server_hiveWrite;
};
diag_log format["DEBUG: disco_damageHandler: _player_blood=%1",_player_blood];
_unit setVariable["USEC_BloodQty",_player_blood,true];
_damage