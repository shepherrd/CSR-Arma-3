// Class IDs only. Empty means no assigned division logo.
params [["_id",objNull]];
if !(_id isEqualType "" && {count _id <= 256}) exitWith {false};
(toArray _id) findIf {!(_x in [45,46,95]) && {!(_x >= 48 && {_x <= 57})} && {!(_x >= 65 && {_x <= 90})} && {!(_x >= 97 && {_x <= 122})}} < 0