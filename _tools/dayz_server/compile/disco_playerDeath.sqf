/*
[_object,_source,_method] spawn disco_playerDeath;
*/
private["_object","_source","_method","_key","_playerID","_characterID","_playerName"];
_object = 	_this select 0;
_source = 	_this select 1;
_method = 	_this select 2;
_playerID = 	_object getVariable["playerID"]; //playerUID
_characterID = 	_object getVariable["characterID"]; //characterID
_playerName = 	_object getVariable["bodyName"];
_humanity =	0;
_wait = 	0;

_id = [_characterID,0,_object,_playerID,_playerName] spawn server_playerDied;

sleep 0.5;
_object setDamage 1;
_id = _object spawn spawn_flies; // work?
// dayzFlies = _object;
// publicVariable "dayzFlies";
_id = [_object,50,true,getPosATL _object] spawn player_alertZombies;

publicVariable["_canHitFree","_isBandit","_myKills","_humanity","_killsH","_wait","_killsB"];
if (!isNull _source) then {
	if (_source != _object) then {
		_canHitFree = _object getVariable ["freeTarget",false];
		_isBandit = (typeOf _object) == "Bandit1_DZ";
		_myKills = ((_object getVariable ["humanKills",0]) / 30) * 1000;
		if (!_canHitFree and !_isBandit) then {
			//Process Morality Hit
			_humanity = -(2000 - _myKills);
			_killsH = _source getVariable ["humanKills",0];
			_source setVariable ["humanKills",(_killsH + 1),true];
			_wait = 300;
		} else {
			//Process Morality Hit
			//_humanity = _myKills * 100;
			_killsB = 		_source getVariable ["banditKills",0];
			_source setVariable ["banditKills",(_killsB + 1),true];
			_wait = 0;
		};
		if (_humanity < 0) then {
			_wait = 0;
		};
		if (!_canHitFree and !_isBandit) then {
			dayzHumanity = [_source,_humanity,_wait];
			publicVariable "dayzHumanity";
		};
	};
};
_object setVariable ["deathType",_method,true];
