// Canonical whitespace and validation shared by storage migration and editing.
params [["_name","",[""]]];
private _chars = toArray _name;
while {count _chars > 0 && {(_chars # 0) == 32}} do {_chars deleteAt 0;};
while {count _chars > 0 && {(_chars # ((count _chars)-1)) == 32}} do {_chars deleteAt ((count _chars)-1);};
if (count _chars == 0 || {count _chars > 64} || {_chars findIf {_x < 32 || {_x == 127}} >= 0}) exitWith {""};
toString _chars
