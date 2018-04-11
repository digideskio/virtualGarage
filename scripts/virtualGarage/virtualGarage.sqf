// Developed by [GZA] David for German Zombie Apocalypse Servers (https://zombieapo.eu/)
// Rewritten by salival (https://github.com/oiad)

private ["_class","_control","_displayName","_heliPad","_isNearPlot","_itemText","_localVehicles","_ownerPUID","_plotCheck","_storedVehicles","_vgDisplCtl"];

if (isNil "vg_init") then {
	player_getVehicle = compile preprocessFileLineNumbers "scripts\virtualGarage\player_getVehicle.sqf";
	player_removePad = compile preprocessFileLineNumbers "scripts\virtualGarage\player_removePad.sqf";
	player_storeVehicle = compile preprocessFileLineNumbers "scripts\virtualGarage\player_storeVehicle.sqf";
	Player_MaintainVG = compile preprocessFileLineNumbers "scripts\virtualGarage\player_MaintainVG.sqf";
	vehicleInfo = compile preprocessFileLineNumbers "scripts\virtualGarage\vehicleInfo.sqf";
	vg_maintainSetText = {
		disableSerialization;
		waituntil {!isNull (findDisplay 2800)};
		_vgDisplCtl = (findDisplay 2800) displayCtrl 2854;
		if (vg_maintainCost > 0) then {
			_itemText = if (Z_SingleCurrency) then {CurrencyName} else {[vg_maintainCost,true] call z_calcCurrency};
			if (Z_SingleCurrency) then {
				_vgDisplCtl ctrlSetText format["%1 (%2 %3)",localize "STR_CL_VG_MAINTAIN_GARAGE",vg_maintainCost,_itemText];
			} else {
				_vgDisplCtl ctrlSetText format["%1 (%2)",localize "STR_CL_VG_MAINTAIN_GARAGE",_itemText];
			};
		} else {
			_vgDisplCtl ctrlSetText format["%1 (%2)",localize "STR_CL_VG_MAINTAIN_GARAGE",localize "strwffree"];
		};
	};
	vg_init = true;
};

if (dayz_actionInProgress) exitWith {localize "str_player_actionslimit" call dayz_rollingMessages;};
dayz_actionInProgress = true;

disableSerialization;

vg_hasRun = false;

createDialog "virtualGarage";

{ctrlShow [_x,false]} count [2803,2830,2850,2851,2852,2853];

_plotCheck = [player,false] call FNC_find_plots;

PVDZE_queryVehicle = if (vg_tiedToPole) then {
	_isNearPlot = (_plotCheck select 1) > 0;
	_ownerPUID = if (_isNearPlot) then {(_plotCheck select 2) getVariable ["ownerPUID","0"]} else {dayz_playerUID};
	[player,_ownerPUID]
} else {
	_isNearPlot = false;
	[player]
};

publicVariableServer "PVDZE_queryVehicle";
waitUntil {!isNil "PVDZE_queryVehicleResult"};

_storedVehicles = PVDZE_queryVehicleResult;
PVDZE_queryVehicle = nil;
PVDZE_queryVehicleResult = nil;

_localVehicles = ([player] call FNC_getPos) nearEntities [["Air","LandVehicle","Ship"],Z_VehicleDistance];
_heliPad = nearestObjects [if (_isNearPlot) then {_plotCheck select 2} else {player},vg_heliPads,if (_isNearPlot) then {DZE_maintainRange} else {Z_VehicleDistance}];

if (count _heliPad > 0 && {_isNearPlot}) then {ctrlShow[2853,true];};

_control = ((findDisplay 2800) displayCtrl 2802);
lbClear _control;

if (count _storedVehicles == 0 && {isNull DZE_myVehicle || {!(alive DZE_myVehicle)} || {!(local DZE_myVehicle)}}) exitWith {ctrlSetText[2811,localize "STR_CL_VG_NO_VEHICLES"];};

vg_vehicleList = [];

{
	_displayName = getText(configFile >> "CfgVehicles" >> (_x select 1) >> "displayName");
	_control lbAdd _displayName;
	_control lbSetData [(lbSize _control)-1,str(_x)];
	vg_vehicleList set [count vg_vehicleList,_x];
} count _storedVehicles;

{
	if (!isNull DZE_myVehicle && {local DZE_myVehicle} && {alive DZE_myVehicle} && {DZE_myVehicle == _x}) then {
		_class = typeOf _x;
		_displayName = getText(configFile >> "CfgVehicles" >> _class >> "displayName");
		_control lbAdd _displayName;
		_control lbSetData [(lbSize _control)-1,_class];
		_control lbSetColor [(lbSize _control)-1,[0, 1, 0, 1]];
		vg_vehicleList set [count vg_vehicleList,_x];
	};
} count _localVehicles;

ctrlShow[2810,false];
ctrlShow[2811,false];

ctrlSetText [2804, format ["%1 (%2 %3)",localize "STR_CL_VG_YOUR_VEHICLES",count (_storedVehicles),localize "STR_CL_VG_VEHICLES"]];
