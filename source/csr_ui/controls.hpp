class RscText;
class RscPicture;
class RscButton;
class RscEdit;
class RscCombo;
class RscListbox;
class RscControlsGroupNoScrollbars;
class CSR_Group: RscControlsGroupNoScrollbars {idc = -1; class controls {};};
class CSR_Picture: RscPicture {style = 48; colorText[] = {1,1,1,1};};
class CSR_Logo: CSR_Picture {style = 2096;};
class CSR_Text: RscText {font = "RobotoCondensed"; shadow = 0; colorText[] = {0.12,0.18,0.20,1};};
class CSR_MultiText: CSR_Text {style = 16; lineSpacing = 1;};
class CSR_Button: RscButton {
    font = "RobotoCondensed"; shadow = 0;
    colorBackground[] = {0.17,0.29,0.27,1};
    colorBackgroundActive[] = {0.25,0.39,0.35,1};
    colorBackgroundDisabled[] = {0.78,0.82,0.81,1};
    colorFocused[] = {0.25,0.39,0.35,1};
    colorText[] = {0.97,0.98,0.97,1};
    colorDisabled[] = {0.42,0.47,0.46,1};
    colorShadow[] = {0,0,0,0}; borderSize = 0;
    offsetX = 0; offsetY = 0; offsetPressedX = 0; offsetPressedY = 0;
};
class CSR_NavButton: CSR_Button {
    colorBackground[] = {0.12,0.20,0.19,1};
    colorBackgroundActive[] = {0.20,0.31,0.28,1};
    colorFocused[] = {0.20,0.31,0.28,1};
};
class CSR_Edit: RscEdit {
    font = "RobotoCondensed"; shadow = 0;
    colorBackground[] = {0.98,0.99,0.99,1};
    colorText[] = {0.13,0.19,0.21,1};
    colorSelection[] = {0.67,0.79,0.74,1};
    maxChars = 64;
};
class CSR_Combo: RscCombo {
    font = "RobotoCondensed"; shadow = 0;
    colorBackground[] = {0.97,0.98,0.98,1};
    colorText[] = {0.13,0.19,0.21,1};
    colorSelect[] = {0.08,0.17,0.14,1};
    colorSelectBackground[] = {0.77,0.85,0.82,1};
    wholeHeight = 0.4;
};
class CSR_Description: CSR_Edit {style = 16; maxChars = 2048;};
class CSR_ReadDescription: CSR_Description {canModify = 0; colorBackground[] = {0.99,0.995,0.995,1};};
class CSR_Items: CSR_Edit {style = 16; maxChars = 262144; font = "EtelkaMonospacePro";};
class CSR_List: RscListbox {
    font = "RobotoCondensed"; shadow = 0;
    colorText[] = {0.16,0.22,0.24,1};
    colorBackground[] = {0.99,0.995,0.995,1};
    colorSelect[] = {0.07,0.17,0.13,1};
    colorSelect2[] = {0.07,0.17,0.13,1};
    colorSelectBackground[] = {0.80,0.87,0.84,1};
    colorSelectBackground2[] = {0.80,0.87,0.84,1};
};
