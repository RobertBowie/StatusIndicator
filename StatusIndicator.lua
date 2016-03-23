--changes:
--added HE rounds, Corrosive Rounds, Incendiary Rounds
--fixed up Judgement/Adjudication tracking for secondaries

--Thanks to Xsear for pointing me to the correct way to find out if a player has a perk equipped
--Thanks to MadWarrior for solving the compatibility issues with MiniHUD

require "math";
require "string";
require "lib/lib_InterfaceOptions"	
require "lib/lib_Debug";
require "lib/lib_WebCache";
require "lib/lib_Callback2";
require "lib/lib_Slash";

local ipairs = ipairs
local tostring = tostring

local calldownIDs = {}

calldownIDs["35922"] = {duration=15} --mosquito wings
calldownIDs["35921"] = {duration=15} --adrenaline
calldownIDs["36264"] = {duration=1}  --energy pack
calldownIDs["38620"] = {duration=15} --rocketeer
--stim packs
calldownIDs["35468"] = {duration=5}
calldownIDs["36232"] = {duration=5}
calldownIDs["36234"] = {duration=5}
calldownIDs["36235"] = {duration=5}
calldownIDs["36236"] = {duration=5}


local durationIDs={}

--set it equal to "default" to use the default icon

durationIDs[1514] = {url="http://firefall-wiki.com/images/firefall-wiki.com/2/2e/Afterburner.png",} -- Afterburner && Cannonball Afterburner
durationIDs[47] = {url="http://firefall-wiki.com/images/firefall-wiki.com/3/3d/Overcharge.png",} -- Overcharge
durationIDs[1161] = {url="http://firefall-wiki.com/images/firefall-wiki.com/archive/f/f9/20130908035940%21Burn_Jets.png",} -- Burn jets
durationIDs[177] = {url="http://firefall-wiki.com/images/firefall-wiki.com/4/48/Bombs_Away.png",} -- Bombs away

durationIDs[968] = {url="http://firefall-wiki.com/images/firefall-wiki.com/5/5f/Immolate.png",} -- Immolate
durationIDs[1525] = {url="http://firefall-wiki.com/images/firefall-wiki.com/2/22/Inferno_Dash.png",} -- Inferno Dash

durationIDs[1128] = {url="http://firefall-wiki.com/images/firefall-wiki.com/c/c6/Trailblaze.png",} -- Trailblaze; slight deployment delay, but not significant
--not tracking disruption (it's only a snare)
durationIDs[990] = {url="http://firefall-wiki.com/images/firefall-wiki.com/a/a9/Tether_Field.png",} -- Tether Field

durationIDs[156] = {url="http://firefall-wiki.com/images/firefall-wiki.com/7/77/Deployable_Shield.png",} -- Deployable Shield
--not tracking any deployables
durationIDs[999] = {url="http://firefall-wiki.com/images/firefall-wiki.com/3/3b/Anti-Personnel_Turret.png",} -- AP turret

--durationIDs[1131] = {url="http://firefall-wiki.com/images/firefall-wiki.com/9/9f/Energy_Wall.png",} -- Energy Wall, has two activations, so will need special code for that (currently no code implemented to handle that)
durationIDs[1027] = {url="http://firefall-wiki.com/images/firefall-wiki.com/c/c7/Fortify.png",} -- Fortify

durationIDs[1598] = {url="http://firefall-wiki.com/images/firefall-wiki.com/e/e4/Boomerang_Shot.png",} -- Boomerang Shot
durationIDs[1004] = {url="http://firefall-wiki.com/images/firefall-wiki.com/8/82/Bulwark.png",} -- Bulwark
durationIDs[1004] = {url="http://firefall-wiki.com/images/firefall-wiki.com/d/dd/Electrical_Storm.png",} -- Electrical Storm

durationIDs[1472] = {url="http://firefall-wiki.com/images/firefall-wiki.com/4/44/Absorbtion_Bomb.png",} -- Absorption Bomb
durationIDs[149] = {url="http://firefall-wiki.com/images/firefall-wiki.com/6/62/Heavy_Armor.png",} -- Heavy Armor && Reflective Armor && Rapid Armor, bug when checking if the name is the same for ordering
durationIDs[1033] = {url="http://firefall-wiki.com/images/firefall-wiki.com/5/5f/Explosive_Rounds.png",} -- Explosive Rounds
durationIDs[1036] = {url="http://firefall-wiki.com/images/firefall-wiki.com/9/94/Accord_Mortar_Arcfold.png",} -- Accord Mortar Arcfold

durationIDs[1418] = {url="http://firefall-wiki.com/images/firefall-wiki.com/1/17/Charge%21.png",} --Charge
durationIDs[1421] = {url="http://firefall-wiki.com/images/firefall-wiki.com/2/25/Sundering_Wave.png", delay = 0.5} -- Sundering Wave, has delay that needs to be accounted for
durationIDs[1146] = {url="http://firefall-wiki.com/images/firefall-wiki.com/d/d0/Dreadfield.png",} -- Dreadfield

durationIDs[142] = {url="http://firefall-wiki.com/images/firefall-wiki.com/8/8e/Thunderdome.png",} -- Thunderdome
durationIDs[1042] = {url="http://firefall-wiki.com/images/firefall-wiki.com/c/c6/Shield_Wall.png", delay = 0.5} -- Shield Wall, small half-second delay in deployment I need to adjust
durationIDs[1047] = {url="http://firefall-wiki.com/images/firefall-wiki.com/1/1c/Tremors.png",} -- Tremors

durationIDs[1517] = {url="http://firefall-wiki.com/images/firefall-wiki.com/e/e8/Combat_Shotgun.png",} -- Combat Shotgun
durationIDs[1218] = {url="http://firefall-wiki.com/images/firefall-wiki.com/d/d0/Shoulder_Rockets.png",} -- Shoulder Rockets

durationIDs[1157] = {url="http://firefall-wiki.com/images/firefall-wiki.com/0/0f/Healing_Generator.png",} -- Healing Generator
durationIDs[112] = {url="http://firefall-wiki.com/images/firefall-wiki.com/5/57/Poison_Trail.png",} -- Poison Trail && Blinding Poison Trail
durationIDs[109] = {url="http://firefall-wiki.com/images/firefall-wiki.com/9/94/Triage.png",} --Triage and Ghostly Triage
durationIDs[1096] = {url="http://firefall-wiki.com/images/firefall-wiki.com/8/8b/Chemical_Sprayer_Arcfold.png",} -- Accord Chemical Sprayer

durationIDs[1105] = {url="http://firefall-wiki.com/images/firefall-wiki.com/d/df/Emergency_Response.png",} --Emergency Response
durationIDs[939] = {url="http://firefall-wiki.com/images/firefall-wiki.com/a/a3/Healing_Dome.png",} -- Healing dome

durationIDs[1013] = {url="http://firefall-wiki.com/images/firefall-wiki.com/4/47/Evacuate.png",} -- Evacuate
durationIDs[1416] = {url="http://firefall-wiki.com/images/firefall-wiki.com/c/ca/Creeping_Death.png",} -- Creeping Death; deployment delay, but not significant
durationIDs[1117] = {url="http://firefall-wiki.com/images/firefall-wiki.com/4/4d/Necrosis.png",} -- Necrosis

durationIDs[1066] = {url="http://firefall-wiki.com/images/firefall-wiki.com/b/bb/Decoy.png",} -- Decoy and Advanced Decoy
--not tracking Cryo grenade, just a snare, and Burning Cryo Grenade has a deployment delay
--not tracking Proximity Response, just a snare
durationIDs[127] = {url="http://firefall-wiki.com/images/firefall-wiki.com/b/bf/SIN_Beacon.png",} -- SIN Beacon; deployment delay, but not significant
durationIDs[1431] = {url="http://firefall-wiki.com/images/firefall-wiki.com/2/2f/Accord_Artillery_Strike.png", delay = 2} --artillery strike actual duration; needs special code for the two durations (delay of 2 sec)

durationIDs[449] = {url="http://firefall-wiki.com/images/firefall-wiki.com/6/6c/SIN_Scrambler.png",} -- SIN Scrambler
durationIDs[1085] = {url="http://firefall-wiki.com/images/firefall-wiki.com/8/89/Teleport_Beacon.png", singleton = true} -- Teleport Beacon; has double activation that needs to be filtered out
durationIDs[1088] = {url="http://firefall-wiki.com/images/firefall-wiki.com/a/a7/Overload.png",} -- Overload

durationIDs[1076] = {url="http://firefall-wiki.com/images/firefall-wiki.com/e/e5/Smoke_Screen.png",} -- Smoke Screen; deployment delay, but not significant
durationIDs[1387] = {url="http://firefall-wiki.com/images/firefall-wiki.com/b/bb/Execution64.png",} -- Execution
durationIDs[1392] = {url="http://firefall-wiki.com/images/firefall-wiki.com/3/32/Eruption_Rounds.png",} -- Eruption Rounds
durationIDs[2011] = {url="http://firefall-wiki.com/images/firefall-wiki.com/e/e1/Icon_perk_passive_siphoning_unit.png", duration= 34.5} -- Heroism

--durationIDs[125] = {url="http://firefall-wiki.com/images/firefall-wiki.com/8/85/Remote_Explosive.png",} -- Remote Explosive, has double activation that needs to be worked around

local moduleIDs = {}

moduleIDs[120630] = {url="http://d2ja7bjtwj8eb0.cloudfront.net/assets/items/64/BF_9_new.png"} --Judgement, normal
moduleIDs[120637] = {url="http://d2ja7bjtwj8eb0.cloudfront.net/assets/items/64/BF_9_new.png"} --Judgement, HC
moduleIDs[120995] = {url="http://d2ja7bjtwj8eb0.cloudfront.net/assets/items/64/BF_9_new.png"} --HE rounds, level 20
moduleIDs[120998] = {url="http://d2ja7bjtwj8eb0.cloudfront.net/assets/items/64/BF_9_new.png"} --HE rounds, level 32
moduleIDs[121001] = {url="http://d2ja7bjtwj8eb0.cloudfront.net/assets/items/64/BF_9_new.png"} --Corrosive Rounds, normal
moduleIDs[121005] = {url="http://d2ja7bjtwj8eb0.cloudfront.net/assets/items/64/BF_9_new.png"} --Corrosive Rounds, HC
moduleIDs[121095] = {url="http://d2ja7bjtwj8eb0.cloudfront.net/assets/items/64/BF_9_new.png"} --Incendiary Rounds, normal
moduleIDs[121133] = {url="http://d2ja7bjtwj8eb0.cloudfront.net/assets/items/64/BF_9_new.png"} --Incendiary Rounds, HC
moduleIDs[122664] = {url="http://d2ja7bjtwj8eb0.cloudfront.net/assets/items/64/cooldown.png", icd=6} --Apotheosis


--local buggyDurationIDs = {}

--buggyDurationIDs[1511] = "default"; -- Shielded Crater, not tracking b/c of large delay in deployment
--buggyDurationIDs[743] = "default"; --GFG, not tracking because of large delay in deployment
--buggyDurationIDs[1482] = "default"; -- Poison ball, not tracking because of large delay in deployment
--buggyDurationIDs[1489] = "default"; -- Healing Pillar; not tracking because of large delay in deployment
--buggyDurationIDs[1081] = "default"; -- Powerfield; not tracking because of large delay in deployment

local SpecOps = {} --keep track of which abilities are affected by Spec.Ops
SpecOps["Decoy"] = "Spec. Ops"
SpecOps["Smoke Screen"] = "Spec. Ops"

local ResonatingShields = {}
ResonatingShields["Bulwark"] = "Resonating Shields"
ResonatingShields["Quick Deploy Forcefield"] = "Resonating Shields"
ResonatingShields["Energy Wall"] = "Resonating Shields" --not tracked
ResonatingShields["Shield Wall"] = "Resonating Shields"
ResonatingShields["Thunderdome"] = "Resonating Shields"
ResonatingShields["Boomerang Shot"] = "Resonating Shields"
ResonatingShields["Shielded Crater"] = "Resonating Shields" --not tracked

local AbilityNameVariations = {} --mapping of ability names to their item names
AbilityNameVariations["Heavy Armor"] = "Reflective Armor" -- to match reflective armor
AbilityNameVariations["Reflexive Heavy Armor"] =  "Rapid Armor" -- to match rapid armor
AbilityNameVariations["Quick Deploy Forcefield"] = "Deployable Shield"
AbilityNameVariations["Heavy Turret Placement"] = "Heavy Turret"
AbilityNameVariations["Rocket Turret Placement"] = "Rocket Turret"
AbilityNameVariations["Multi Deploy Turret"] = "Multi Turret"
AbilityNameVariations["Power field"] = "Power Field"
AbilityNameVariations["Supply Station"] = "Armor Station"

local AUDIO_CLIPS = {}
local tempAudio = {
"Play_AMB_CharacterCreation_Battlelab_Loop",
"Play_AMB_CharacterCreation_Battlelab_RadioChatter_Loop",
"Play_Click021",
"Play_Copa_Intro_Log_Nostromo_Chain",
"Play_DisableSlowMoPlayback",
"Play_EnableSlowMoPlayback",
"Play_Ender_FailureMusic",
"Play_Ender_SuccessMusic",
"Play_Ender_TieMusic",
"Play_First5_Intro_Coda_Pilgrim_001",
"Play_ManufacturingStarted_01",
"Play_ManufacturingStarted_02",
"Play_ManufacturingStarted_03",
"Play_MuteAll_Except_UIandMusicandMissionDialog",
"Play_NewYou_ChangeMusictoLevel1",
"Play_NewYou_ChangeMusictoLevel2",
"Play_PAX_FirefallSplash_Defeat",
"Play_PAX_FirefallSplash_Firefall",
"Play_PAX_FirefallSplash_Unlock",
"Play_PAX_FirefallSplash_Victory",
"Play_PvP_Confirmation",
"Play_PvP_ScoreboardState",
"Play_RedBean_ManufactureNow_01",
"Play_RedBean_ManufactureNow_02",
"Play_RedBean_ManufactureNow_03",
"Play_Release02",
"Play_ResetMuteAll_Except_UIandMusicandMissionDialog",
"Play_ScrollLow",
"Play_SFX_Loot_Trash",
"Play_SFX_NewYou_BodySelectionHulaPopUp",
"Play_SFX_NewYou_GearRackScroll",
"Play_SFX_NewYou_GenericConfirm",
"Play_SFX_NewYou_IntoAndLoop",
"Play_SFX_NewYou_ItemMenuPopup",
"Play_SFX_UI_AbilitySelect01_v4",
"Play_SFX_UI_AbilitySelect03_v3",
"Play_SFX_UI_AbilitySelect03_v4",
"Play_SFX_UI_AchievementEarned",
"Play_SFX_UI_Ding",
"Play_SFX_UI_E_Initiate_Loop",
"Play_SFX_UI_End",
"Play_SFX_UI_GeneralAnnouncement",
"Play_SFX_UI_GeneralConfirm14_v2",
"Play_SFX_UI_Loot_Abilities",
"Play_SFX_UI_Loot_Ammo",
"Play_SFX_UI_Loot_Backpack_Pickup",
"Play_SFX_UI_Loot_Basic",
"Play_SFX_UI_Loot_Battleframe_Pickup",
"Play_SFX_UI_Loot_Crystite",
"Play_SFX_UI_Loot_Equipment",
"Play_SFX_UI_Loot_Flyover",
"Play_SFX_UI_Loot_PowerUp",
"Play_SFX_UI_Loot_Weapon_Pickup",
"Play_SFX_UI_Manufacture_Start",
"Play_SFX_UI_NPELogin",
"Play_SFX_UI_OCT_1MinWarning",
"Play_SFX_UI_SIN_CooldownFail",
"Play_SFX_UI_Ticker",
"Play_SFX_UI_TipPopUp",
"Play_SFX_UI_WhisperTickle",
"Play_SFX_WebUI_Close",
"Play_SFX_WebUI_Equip_BackpackModule",
"Play_SFX_WebUI_Equip_Battleframe",
"Play_SFX_WebUI_Equip_BattleframeModule",
"Play_SFX_WebUI_Equip_Weapon",
"Play_SFX_WebUI_Open",
"Play_SlotMachine_Decryption",
"Play_SlotMachine_EpicDecryption",
"Play_SlotMachine_InsertCoin",
"Play_SlotMachine_PullLever",
"Play_SpecialEventMusic_FirstImpressions_LogIn",
"Play_SpecialEventMusic_LoginScreen",
"Play_State_Interact",
"Play_State_InteractNone",
"Play_TurnDownMusic",
"Play_ui_abilities_cooldown_complete",
"Play_UI_Ability_Selection",
"Play_UI_Ability_Trigger",
"Play_UI_ARESMIssions_Pickup_Generic01",
"Play_UI_Beep_06",
"Play_UI_Beep_08",
"Play_UI_Beep_09",
"Play_UI_Beep_10",
"Play_UI_Beep_12",
"Play_UI_Beep_13",
"Play_UI_Beep_19",
"Play_UI_Beep_23",
"Play_UI_Beep_24",
"Play_UI_Beep_26",
"Play_UI_Beep_27",
"Play_UI_Beep_41",
"Play_UI_Beep_44",
"Play_UI_CharacterCreate_Confirm",
"Play_UI_DailyRewardsScreen_Close",
"Play_UI_DailyRewardsScreen_Open",
"Play_UI_DailyRewardsScreen_ProgressShift",
"Play_UI_DailyRewardsScreen_RewardGranted",
"Play_UI_Friendly_Distress",
"Play_UI_Garage_CPUUgrade",
"Play_UI_Garage_MassUpgrade",
"Play_UI_Garage_Perks_DropInCircle",
"Play_UI_Garage_PowerUpgrade",
"Play_UI_Garage_UnlockSlot",
"Play_UI_Interact_Available",
"Play_UI_Intermission",
"Play_UI_Login",
"Play_UI_Login_Back",
"Play_UI_Login_Click",
"Play_UI_Login_Confirm",
"Play_UI_Login_Keystroke",
"Play_UI_Map_DetailClose",
"Play_UI_Map_DetailOpen",
"Play_UI_Map_ZoomIn",
"Play_UI_Map_ZoomOut",
"Play_UI_MapClose",
"Play_UI_MapMarker_GetFocus",
"Play_UI_MapMarker_LostFocus",
"Play_UI_MapOpen",
"Play_UI_NavWheel_Close",
"Play_UI_NavWheel_MouseLeftButton",
"Play_UI_NavWheel_MouseLeftButton_Initiate",
"Play_UI_NavWheel_MouseRightButton",
"Play_UI_NavWheel_MouseScroll",
"Play_UI_NavWheel_Open",
"Play_UI_RewardNotification",
"Play_UI_RewardsAward",
"Play_UI_RewardScreenOpen",
"Play_UI_sfx_warning_Ammo",
"Play_UI_SIN_Acquired",
"Play_UI_SIN_ExtraInfo_Off",
"Play_UI_SIN_ExtraInfo_On",
"Play_UI_SINView_Mode",
"Play_UI_SlideNotification",
"Play_UI_Squad_Join",
"Play_UI_Squad_Leave",
"Play_UI_StatsAward",
"Play_UI_Ticker_1stStageIntro",
"Play_UI_Ticker_2ndStageIntro",
"Play_UI_Ticker_LowPulse",
"Play_UI_Ticker_QuietSecondTick",
"Play_UI_Ticker_ZeroTick",
"Play_UI_VOIP_CloseChannel",
"Play_UI_VOIP_OpenChannel",
"Play_UI_XPReward",
"Play_UI_ZoneSelect_Confirm",
"Play_Vox_BattleframeVocal_Male01_DurabilityCritical",
"Play_Vox_BattleframeVocal_Male01_MaintenanceRequired",
"Play_Vox_Emote_Groan",
"Play_Vox_Emote_Victory",
"Play_Vox_UI_Frame25",
"Play_Vox_UI_Frame50",
"Play_Vox_VoiceSetSelect",
"Stop_AMB_CharacterCreation_Battlelab_Loop",
"Stop_AMB_CharacterCreation_Battlelab_RadioChatter_Loop",
"Stop_Copa_Intro_Log_Nostromo_001",
"Stop_Copa_Intro_Log_Nostromo_002",
"Stop_Copa_Intro_Log_Nostromo_003",
"Stop_Copa_Intro_Log_Nostromo_Chain",
"Stop_PvP_ScoreboardState",
"Stop_SFX_NewYou_IntoAndLoop",
"Stop_SFX_UI_E_Initiate_Loop_Fail",
"Stop_SFX_UI_E_Initiate_Loop_Success",
"Stop_SFX_UI_NPELogin",
"Stop_SpecialEventMusic_FirstImpressions_LogIn",
"Stop_SpecialEventMusic_LoginScreen",
"Stop_State_Interact",
"Stop_TurnDownMusic",
"Stop_UI_NavWheel_MouseScroll",
"Stop_UI_SINView_Mode",
}

local AUDIO_ITERATOR = 1
for _,audio in pairs(tempAudio) do
	AUDIO_CLIPS[AUDIO_ITERATOR] = audio
	AUDIO_ITERATOR = AUDIO_ITERATOR + 1
end
local MAIN_FRAME = Component.GetFrame("Main"); 
InterfaceOptions.AddMovableFrame({
	frame = MAIN_FRAME,
	label = "Status Indicator V2", 
	scalable = true
});
local OPTIONS = {
  enabled = true,
  trackPerks = true,
  trackHKM = true,
	trackCalldowns = true,
  showTime = true,
  debug = true,
  sound = "Play_SFX_UI_Ding",
	floatingTimer = false,
	timerHeight = -18,	

	startEdgeColor = {tint="00FF00", alpha = 1.0},
	startBackgroundColor = {tint = "000000", alpha = 0.7},
	startArcColor = {tint = "FF8800", alpha = 1.0},
	startTimerAlpha = 1.0,
	startIconTint = {tint = "FFFFFF", alpha = 1.0},

	endEdgeColor = {tint="FF0000", alpha = 1.0},
	endBackgroundColor = {tint = "000000", alpha = 0.7},
	endArcColor = {tint = "FF8800", alpha = 1.0},
	endTimerAlpha = 1.0,
	endIconTint = {tint = "FFFFFF", alpha = 1.0},
}
local g_Perks = {};
local m_options = {};
local m_optionsCallbacks = {};
local m_hiddenByHUDHiding = false;
local m_hiddenBecauseVehicle = false;
local m_widgetList = {};
local m_identifier = 0;
function addCheckBoxOption(id, label, tooltip, default) 
  m_options[id] = default;
  m_optionsCallbacks[id] = function(msg) m_options[id] = msg; end
  InterfaceOptions.AddCheckBox({id=id, label=label, checkbox=true, default=default, tooltip=tooltip});
end

local AmbushCrit = false

local HMGShieldUp = false

local ExecutionDuration = 0

local kmph = 0

--sure shot stuff
local burst_time = 0
local last_shot_time = 0

function OnSettingsChange(option, value)
	OPTIONS[option] = value;
end



InterfaceOptions.StartGroup({id="enabled", label="Enable Status Indicator V2", checkbox=true, default=OPTIONS.enabled, tooltip="Disables the Addon if unchecked"});
InterfaceOptions.AddCheckBox({id="trackPerks", label="Perk Tracking", checkbox=true, default=OPTIONS.trackPerks, tooltip="Enable if you want to see perk cooldowns"});
InterfaceOptions.AddCheckBox({id="trackHKM", label="HKM/Ability Tracking", checkbox=true, default=OPTIONS.trackHKM, tooltip="Enable if you want to see HKM and ability durations"});
InterfaceOptions.AddCheckBox({id="trackCalldowns", label="Calldown Tracking", checkbox=true, default=OPTIONS.trackCalldowns, tooltip="Enable if you want to see calldown durations"});
InterfaceOptions.AddCheckBox({id="showTime", label="Timer", checkbox=true, default=OPTIONS.showTime, tooltip="Enable a timer to show remaining time"});
InterfaceOptions.AddCheckBox({id="debug", label="Debugging", checkbox=true, default=OPTIONS.debug, tooltip="Enables visible debugging so I can get data on failed assertions"});
InterfaceOptions.AddChoiceMenu({id="sound", label="Sound", default=OPTIONS.sound});
InterfaceOptions.AddChoiceEntry({menuId="sound", val="", label="No Sound"});
InterfaceOptions.AddColorPicker({id="startEdgeColor", label = "Start Edge Color", default = OPTIONS.startEdgeColor});
InterfaceOptions.AddColorPicker({id="endEdgeColor", label = "End Edge Color", default = OPTIONS.endEdgeColor});
InterfaceOptions.AddColorPicker({id="startBackgroundColor", label = "Start Background Color", default = OPTIONS.startBackgroundColor});
InterfaceOptions.AddColorPicker({id="endBackgroundColor", label = "End Background Color", default = OPTIONS.endBackgroundColor});
InterfaceOptions.AddColorPicker({id="startArcColor", label = "Start Arc Color", default = OPTIONS.startArcColor});
InterfaceOptions.AddColorPicker({id="endArcColor", label = "End Arc Color", default = OPTIONS.endArcColor});
InterfaceOptions.AddColorPicker({id="startIconTint", label = "Start Icon Tint", default = OPTIONS.startIconTint});
InterfaceOptions.AddColorPicker({id="endIconTint", label = "End Icon Tint", default = OPTIONS.endIconTint});
InterfaceOptions.AddSlider({id="startTimerAlpha", label = "Start Timer Alpha", default = OPTIONS.startTimerAlpha, min = 0, max = 1, inc = 0.01})
InterfaceOptions.AddSlider({id="endTimerAlpha", label = "End Timer Alpha", default = OPTIONS.endTimerAlpha, min = 0, max = 1, inc = 0.01})
InterfaceOptions.AddCheckBox({id="floatingTimer", label="Non-centered Timer", checkbox=true, default=OPTIONS.floatingTimer, tooltip="Allows the text timer to be moved vertically"});
InterfaceOptions.AddSlider({id="timerHeight", label = "Timer Height", default = OPTIONS.timerHeight, min = -100, max = 100, inc = 1})

for i = 1, #AUDIO_CLIPS do
	InterfaceOptions.AddChoiceEntry({menuId="sound", val=AUDIO_CLIPS[i], label=AUDIO_CLIPS[i]});
end

InterfaceOptions.StopGroup()





function OnComponentLoad()
  InterfaceOptions.SetCallbackFunc(OnSettingsChange, "Status Indicator V2")


  local d_perk_info = Game.GetPerkModuleInfo();
  for _, perk in pairs(d_perk_info) do
    g_Perks[perk.id] = {INFO = perk};
  end
end

function CheckPerkEquipped(perkName)
  local loadout = Player.GetCurrentLoadout()
  if( loadout ) then
    for _, module in ipairs(loadout.modules.chassis) do 
      local perk = g_Perks[tostring(module.item_sdb_id)]
      if( perk ) then
        if(perkName == perk.INFO.name) then
          return true
        end
      end
    end
  end
  return false
end

function GetLoadoutPerks()
    local slotted_perks = {};
    local loadout = Player.GetCurrentLoadout()
    if( loadout ) then
        for _, module in ipairs(loadout.modules.chassis) do 
            local perk = g_Perks[tostring(module.item_sdb_id)]
            if( perk ) then
                table.insert(slotted_perks, perk.INFO);
                --Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=module.slot_idx}); --for testing
                --Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=perk.INFO.name}); --for more testing
            end
        end
    end
    
    return slotted_perks;
end
function Show(show)
	if (show) then
		MAIN_FRAME:Show(true);
	else
		MAIN_FRAME:Show(false);
	end
end

function OnHudShow(args)
	--g_hiddenByHUDHiding = not args.show;

	CheckHUDVisibility();
end

function OnVehicleMode(args)
        if(args.fake==true) then return; end
	--g_hiddenBecauseVehicle = args.show;
	
	CheckHUDVisibility();
end

function CheckHUDVisibility()
	local hidden = g_hiddenBecauseVehicle or g_hiddenByHUDHiding;
	Show(not hidden);
end

function OnAbility(args)
  GetLoadoutPerks() --for testing
  if(not OPTIONS.enabled) then return; end

	if(args.index > 4) then -- not an ability
		trackCalldowns(args)
		return
	end

  if(OPTIONS.trackHKM) then
  	local abilityItem = GetAbilityItem(args);
    	CheckDurationAbilities(args, abilityItem)

	local slottedModules = GetAbilityItem(args).slotted_modules
	CheckItemModules(slottedModules)

    	if(AbilityMatch(abilityItem.name, "Execution")) then
      		for _, attribute in pairs(abilityItem.attributes) do
        		if (durationIDs[attribute.stat_id]) then -- Duration attributes
          			ExecutionDuration = attribute.value
        		end
      		end
      		local widget = findName("Ambush")
      		if(widget) then
        		RemoveStatusWidget(widget)
      		end
    	end
  elseif(OPTIONS.trackPerks and CheckPerkEquipped("Ambush")) then
    local abilityItem = GetAbilityItem(args);
    if(abilityItem and AbilityMatch(abilityItem.name, "Execution")) then
      CheckDurationAbilities(args, abilityItem)
      for _, attribute in pairs(abilityItem.attributes) do
        if (durationIDs[attribute.stat_id]) then -- Duration attributes
          ExecutionDuration = attribute.value
        end
      end
      local widget = findName("Ambush")
      if(widget) then
        RemoveStatusWidget(widget)
      end
    end
  end
  


  if(OPTIONS.trackPerks) then

    if(not CheckRealAbility(args)) then return; end

    if(CheckPerkEquipped("Health Surge")) then
      if(findName("Health Surge")) then
        RefreshDuration("Health Surge", 10)
      else
        RegisterStatus("Health Surge", 10, "http://d2ja7bjtwj8eb0.cloudfront.net/assets/items/64/Perk_Power-Reserves.png");
      end
    end

    if(CheckPerkEquipped("Invigorate")) then
      if(findName("Invigorate")) then
        RefreshDuration("Invigorate", 12)
      else
      RegisterStatus("Invigorate", 6, "http://firefall-wiki.com/images/firefall-wiki.com/2/28/Icon_perk_advanced_invigorate.png");
      end
    end
  
    if(CheckPerkEquipped("Flame Buffer")) then
      RegisterStatus("Flame Buffer", 6, "http://firefall-wiki.com/images/firefall-wiki.com/1/10/Icon_perk_master_flame_buffer.png");
    end

    if(CheckPerkEquipped("Personal Shield")) then
      local duration  = 5
      if(CheckPerkEquipped("Resonating Shields")) then
	duration = duration + 2
      end
      RegisterStatus("Personal Shield", duration, "http://firefall-wiki.com/images/firefall-wiki.com/e/e5/Icon_perk_passive_personal_shield.png");
    end

    if(CheckPerkEquipped("Auxiliary Tanks")) then
      RegisterStatus("Auxiliary Tanks", 4, "http://firefall-wiki.com/images/firefall-wiki.com/1/1a/Icon_perk_passive_auxiliary_tanks.png"); --NOTE: replace with actual duration once I figure out what that is
    end
  end
end

function GetAbilityItem(event)
  local abilityUsed = Player.GetCurrentLoadout().modules.backpack[event.index];
	if not abilityUsed then
		return nil
	end
  local testAbility = Player.GetAbilityInfo(event.id)
  if (abilityUsed.item_guid) then
    
    local result = Player.GetItemInfo(abilityUsed.item_guid);

    if(AbilityMatch(result.name, testAbility.name)) then
      return result
    else --UI order is not the same as backpack order, must find correct ability --doesn't work, need to fix
      for i=1,4 do
        abilityUsed = Player.GetCurrentLoadout().modules.backpack[i];
        result = Player.GetItemInfo(abilityUsed.item_guid);
        if(AbilityMatch(result.name, testAbility.name)) or tostring(result.itemTypeId) == tostring(testAbility.itemTypeId) then
          return result
        end
      end
    end
  end


  local abilityUsed = Player.GetCurrentLoadout().modules.backpack[event.index];
  local result = Player.GetItemInfo(abilityUsed.item_guid);
  if(OPTIONS.debug) then
    Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text="COMPARISON ERROR"}); --for finding names that don't match
    Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=result.name});
    Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=testAbility.name});
    Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=Game.GetItemInfoByType(abilityUsed.item_sdb_id).name});
  end
  return result
end

function trackCalldowns(event)
	--out(event)
	if not OPTIONS.trackCalldowns then return end
	local calldownInfo = calldownIDs[tostring(event.id)]
	if(calldownInfo) then --it's one of the ones we track
		local calldownAbilityInfo = Player.GetAbilityInfo(event.id)
		local calldownItemInfo = Game.GetItemInfoByType(calldownAbilityInfo.itemTypeId)

		RegisterStatus("Calldown " .. event.index, calldownInfo.duration, calldownItemInfo.web_icon) --pulls the web icon from the game's database instead of hard-coding the values
	end
end

function CheckItemModules(modules)

	for _,module in pairs(modules) do
		if moduleIDs[tonumber(module)] then
			local itemInfo = Game.GetItemInfoByType(module)
        		if(tonumber(module) == 122664 and not findName("Apotheosis")) then --apotheosis
         			RegisterStatus("Apotheosis", moduleIDs[tonumber(module)].icd, moduleIDs[tonumber(module)].url);
       			end
			
		end
	end
end

function GetAbilityItemByName(name)
  for i=1,4 do
    local abilityUsed = Player.GetCurrentLoadout().modules.backpack[i];
    result = Player.GetItemInfo(abilityUsed.item_guid);
    if(AbilityMatch(result.name, name)) then
      return result
    end
  end

  --return Game.GetItemInfoByType(abilityUsed.item_sdb_id);


  local abilityUsed = Player.GetCurrentLoadout().modules.backpack[1];
  local result = Player.GetItemInfo(abilityUsed.item_guid);
  if(OPTIONS.debug) then
    Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text="FIND COMPARISON ERROR"}); --for finding names that don't match
    Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=name});
  end
  return result --wild guess that it'll be in the first slot
end

function AbilityMatch(name1, name2) --sees if the two abilities are the same; name1 should be result.name, name2 should be testAbility.name
  if(string.find(name1, trim(name2))) then  --Find used because testAbility.name does not have the attached prefixes (i.e. Cooled)
    return true
  elseif(AbilityNameVariations[trim(name2)]) then
    if(string.find(name1, AbilityNameVariations[trim(name2)])) then
      return true
    end
  end
  return false
end
function trim(s)  --removes whitespace from beginning and end, because Turret Mode's testAbility name has an extra space and is failing comparisons
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end  

function CheckDurationAbilities(event, abilityItem)
  --Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=abilityItem.name}); --for testing
  for _, attribute in pairs(abilityItem.attributes) do
    
    --Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=attribute.display_name}); --for testing
    --Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=attribute.value}); --more testing
    if (attribute.stat_id == 2011) then -- Testing hard coding a timer for Heroism
      local abilityInfo = durationIDs[2011]
      -- Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text="Attempted to display."}); --for testing
      RegisterStatus(abilityItem.name, abilityInfo.duration, abilityInfo.url)
      -- Component.GenerateEvent("MY_SYSTEM_MESSAGE", {"stat_id ", text=attribute.stat_id}); --for testing
      -- Component.GenerateEvent("MY_SYSTEM_MESSAGE", {"value ", text=attribute.value}); --for testing
    elseif (durationIDs[attribute.stat_id]) then -- Duration attributes
      local abilityInfo = durationIDs[attribute.stat_id]
      local duration = attribute.value
      if(abilityInfo.delay) then
        duration = duration + abilityInfo.delay
      end

      if(CheckPerkEquipped("Spec. Ops")) then
        local testAbility = Player.GetAbilityInfo(event.id)
        if(SpecOps[trim(testAbility.name)]) then
          duration = duration + 3
        end
      end
      if(CheckPerkEquipped("Resonating Shields")) then
        local testAbility = Player.GetAbilityInfo(event.id)
        if(ResonatingShields[trim(testAbility.name)]) then
          duration = duration + 2
        end
      end

      if(abilityInfo.singleton and findName(abilityItem.name)) then 
        RemoveStatusWidget(findName(abilityItem.name))
      elseif(abilityInfo.url == "default") then
        RegisterStatus(abilityItem.name, duration, "http://firefall-wiki.com/images/firefall-wiki.com/b/b6/HKM_icon_%28Status_Indicator%29.png");
      else
        RegisterStatus(abilityItem.name, duration, abilityInfo.url);
      end
      return true;
    end
  end
end

function CheckRealAbility(args)
  local abilityItem = GetAbilityItem(args);
  if(abilityItem.name) then
    return true
  end
  return false
end
function OnWeaponReload(args)
	if(args.begin) then
		local weaponstate = Player.GetWeaponState()
		if(weaponstate.Clip == 0 and CheckAdjudication()) then
			RegisterStatus("Adjudication", CheckAdjudication(), "http://d2ja7bjtwj8eb0.cloudfront.net/assets/items/64/MOD_BF_3.png")
		end
	end
end
function OnDamage(args)
  if(not OPTIONS.enabled) then return; end

  if(args.critical) then
    local readiness = GetAbilityReadiness()
    Callback2.FireAndForget(CheckTactician, readiness, 0.5);
    if(CheckPerkEquipped("Ambush") and not findName("Ambush")) then
      AmbushCrit = true
    end
  elseif(CheckPerkEquipped("Ambush") and not findName("Ambush")) then
    RegisterStatus("Ambush", 10.1, "http://firefall-wiki.com/images/firefall-wiki.com/a/a5/Icon_perk_passive_ambush.png"); --.1 for a margin of error
  end

  if args.damage > 0 then
    CheckModules()
  end

  if(CheckPerkEquipped("Dynamic Relay")) then
    if(args.damage > 0) then
      if(findName("Dynamic Relay Shielding")) then
        local statusWidgetObject = findName("Dynamic Relay Shielding")
        local remainingDuration = (tonumber(System.GetClientTime()) - statusWidgetObject.startTime)
        statusWidgetObject.duration = remainingDuration + 10000 --set to 10 sec until I find out what the duration actually is
      else
        RegisterStatus("Dynamic Relay Shielding", 10, "http://firefall-wiki.com/images/firefall-wiki.com/f/f8/Icon_perk_passive_dynamic_relay.png");
      end
    elseif(args.damageType == "Overheal Shields") then
      if(findName("Dynamic Relay RoF")) then
        local statusWidgetObject = findName("Dynamic Relay RoF")
        local remainingDuration = (tonumber(System.GetClientTime()) - statusWidgetObject.startTime)
        statusWidgetObject.duration = remainingDuration + 10000 --set to 10 sec until I find out what the duration actually is
      else
        RegisterStatus("Dynamic Relay RoF", 10, "http://firefall-wiki.com/images/firefall-wiki.com/f/f8/Icon_perk_passive_dynamic_relay.png");
      end
    end
  end

  if(CheckPerkEquipped("Rally")) then
    if(args.damage > 0) then
      if(findName("Rally Healing")) then
        RefreshDuration("Rally Healing", 10) --set to 10 sec until I find out what the duration actually is
      else
        RegisterStatus("Rally Healing", 10, "http://firefall-wiki.com/images/firefall-wiki.com/3/36/Icon_perk_passive_rally.png");
      end
    elseif(args.damageType == "Health Only" or args.damageType == "Generic") then
      if(findName("Rally Damage")) then
        RefreshDuration("Rally Damage", 10) --set to 10 sec until I find out what the duration actually is
      else
        RegisterStatus("Rally Damage", 10, "http://firefall-wiki.com/images/firefall-wiki.com/3/36/Icon_perk_passive_rally.png");
      end
    end
  end
end

function GetAbilityReadiness()
  local abilities = Player.GetAbilities()
  for i=1,3 do
    local ability = abilities.slotted[i]
    local abilityItem = GetAbilityItem({id = ability.abilityId, index = i})
    local state = Player.GetAbilityState(ability.abilityId)
    if(not state.isReady) then
      return false
    end
    local numCharges = Player.GetAbilityCharges(ability.abilityId)
    for _,attribute in pairs(abilityItem.attributes) do
      if(trim(attribute.display_name) == "Max Deployment") then
        if(attribute.value and attribute.value ~= numCharges) then
          return false
        end
      end
    end
  end
  return true
end

function OnVehicleUpdate(args)
	if(args.kmph-kmph >10 and args.kmph >120 and not findName("LGV Boost")) then
		RegisterStatus("LGV Boost", 9, "http://di0fhzb64fdop.cloudfront.net/assets/items/64/Omnidyne_LGV.png");
	end
	kmph = args.kmph
end

function CheckTactician(readiness)
  if(readiness == false and GetAbilityReadiness() and CheckPerkEquipped("Tactician") and not findName("Tactician")) then
    RegisterStatus("Tactician", 60, "http://firefall-wiki.com/images/firefall-wiki.com/4/45/Icon_perk_advanced_tactician.png");
  end
end

function RefreshDuration(name, timeSeconds)
  local statusWidgetObject = findName(name)
  local remainingDuration = (tonumber(System.GetClientTime()) - statusWidgetObject.startTime)

	--set colors
	statusWidgetObject.CIRCLE:SetParam("alpha", OPTIONS.startEdgeColor.alpha)
	statusWidgetObject.CIRCLE:SetParam("tint", "#" .. OPTIONS.startEdgeColor.tint)
	statusWidgetObject.BACKGROUND:SetParam("alpha", OPTIONS.startBackgroundColor.alpha)
	statusWidgetObject.BACKGROUND:SetParam("tint", "#" .. OPTIONS.startBackgroundColor.tint)
	statusWidgetObject.COOLDOWN:SetParam("alpha", OPTIONS.startArcColor.alpha)
	statusWidgetObject.COOLDOWN:SetParam("tint", "#" .. OPTIONS.startArcColor.tint)
	statusWidgetObject.COOLDOWN:SetParam("alpha", OPTIONS.startArcColor.alpha)
	statusWidgetObject.COOLDOWN:SetParam("tint", "#" .. OPTIONS.startArcColor.tint)
	statusWidgetObject.WEB_ICON:SetParam("alpha", OPTIONS.endIconTint.alpha)
	statusWidgetObject.WEB_ICON:SetParam("tint", "#" .. OPTIONS.endIconTint.tint)
	--set fading
	statusWidgetObject.CIRCLE:ParamTo("alpha", OPTIONS.endEdgeColor.alpha, timeSeconds)
	statusWidgetObject.CIRCLE:ParamTo("tint", "#" .. OPTIONS.endEdgeColor.tint, timeSeconds)
	statusWidgetObject.BACKGROUND:ParamTo("alpha", OPTIONS.endBackgroundColor.alpha, timeSeconds)
	statusWidgetObject.BACKGROUND:ParamTo("tint", "#" .. OPTIONS.endBackgroundColor.tint, timeSeconds)
	statusWidgetObject.COOLDOWN:ParamTo("alpha", OPTIONS.endArcColor.alpha, timeSeconds)
	statusWidgetObject.COOLDOWN:ParamTo("tint", "#" .. OPTIONS.endArcColor.tint, timeSeconds)
	statusWidgetObject.WEB_ICON:ParamTo("alpha", OPTIONS.endIconTint.alpha, timeSeconds)
	statusWidgetObject.WEB_ICON:ParamTo("tint", "#" .. OPTIONS.endIconTint.tint, timeSeconds)

  if(OPTIONS.showTime) then
	statusWidgetObject.COOLDOWN_COUNTER:SetParam("alpha", OPTIONS.startTimerAlpha)
	statusWidgetObject.COOLDOWN_COUNTER:ParamTo("alpha", OPTIONS.endTimerAlpha, timeSeconds)
    statusWidgetObject.COOLDOWN_COUNTER:StartTimer(timeSeconds, true)
  end
  statusWidgetObject.duration = remainingDuration + (1000*timeSeconds)
  
end

function OnTookHit(args)
  if(not OPTIONS.enabled) then return; end
  if not (args.sourceId and args.sourceId ~= Player.GetTargetId()) then return; end

  if(OPTIONS.trackPerks and args.damage > 0) then
	if(CheckPerkEquipped("Hellbent")) then
      		if(findName("Hellbent")) then
        		RefreshDuration("Hellbent", 15)
      		else
        		RegisterStatus("Hellbent", 15, "http://firefall-wiki.com/images/firefall-wiki.com/8/8a/Icon_perk_master_hellbent.png");
      		end
    	end

    if(CheckPerkEquipped("Harden") and not findName("Harden")) then
      RegisterStatus("Harden", 6.89, "http://firefall-wiki.com/images/firefall-wiki.com/3/36/Icon_perk_basic_harden.png"); --the .89 is to handle the slight delay for removal
    end

    if(CheckPerkEquipped("Sentient Armor") and not findName("Sentient Armor")) then
      local type = args.damageType or args.type or nil
      if(type==nil or type=="Fire" or type=="Poison" or type=="Kinetic" or type=="Bullet" or type=="Ice" or type=="Cryo" or type=="blast" or type=="fire" or type=="poison" or type=="kinetic" or type=="bullet" or type=="ice" or type=="cryo") then
        RegisterStatus("Sentient Armor", 11.89, "http://firefall-wiki.com/images/firefall-wiki.com/0/0b/Icon_perk_advanced_sentient_armor.png"); --the .89 is to handle the slight delay for removal
      end
    end
    if(not findName("Trickster") and PercentHealth() < 0.50 and CheckPerkEquipped("Trickster")) then
      RegisterStatus("Trickster", 119.89, "http://firefall-wiki.com/images/firefall-wiki.com/8/8d/Icon_perk_achievement_trickster.png"); --the .89 is to handle the slight delay for removal
    end
 
    if(not findName("Hero") and PercentHealth() == 0 and CheckPerkEquipped("Hero")) then
      RegisterStatus("Hero", 5, "http://firefall-wiki.com/images/firefall-wiki.com/d/de/Icon_perk_master_hero.png");
      RegisterStatus("Hero", 899.89, "http://firefall-wiki.com/images/firefall-wiki.com/d/de/Icon_perk_master_hero.png"); --the .89 is to handle the slight delay for removal, although it really shouldn't matter for Hero
    end
    
    if(not findName("Reactive Armor") and CheckPerkEquipped("Reactive Armor")) then
      RegisterStatus("Reactive Armor", 9.89, "http://firefall-wiki.com/images/firefall-wiki.com/3/39/Icon_perk_basic_kinetic_absorption.png"); --the .89 is to handle the slight delay for removal
    end


    local life_info = Player.GetLifeInfo()
    if(CheckPerkEquipped("Auto-repair") and args.damage/life_info["MaxHealth"] > 0.25) then
	RegisterStatus("Auto-repair", 10, "http://d2ja7bjtwj8eb0.cloudfront.net/assets/items/64/Perk_Auto-Repair.png")
    end


    local type = args.damageType or args.type
    if(type) then
      if((type=="Poison" or type=="Poison") and not findName("Ventilator") and CheckPerkEquipped("Ventilator")) then
        RegisterStatus("Ventilator", 9.89, "http://firefall-wiki.com/images/firefall-wiki.com/e/ea/Icon_perk_basic_virus.png"); --the .89 is to handle the slight delay for removal
      end

      if((type=="Fire" or type=="fire") and not findName("Extinguisher") and CheckPerkEquipped("Extinguisher")) then
        RegisterStatus("Extinguisher", 9.89, "http://firefall-wiki.com/images/firefall-wiki.com/1/10/Icon_perk_master_flame_buffer.png"); --the .89 is to handle the slight delay for removal
      end

      if((type=="Plasma" or type=="plasma") and not findName("Plasma Scoops") and CheckPerkEquipped("Plasma Scoops")) then
        RegisterStatus("Plasma Scoops", 9.89, "http://firefall-wiki.com/images/firefall-wiki.com/5/52/Icon_perk_advanced_prototype_plasma.png"); --the .89 is to handle the slight delay for removal
      end

      if((type=="Energy" or type=="energy") and not findName("Feedback Circuits") and CheckPerkEquipped("Feedback Circuits")) then
        RegisterStatus("Feedback Circuits", 9.89, "http://firefall-wiki.com/images/firefall-wiki.com/d/df/Icon_perk_basic_powered_armor.png"); --the .89 is to handle the slight delay for removal
      end

      if((type=="Melding" or type=="melding" or type=="Melding Energy" or type=="melding energy") and not findName("Melding Converter") and CheckPerkEquipped("Melding Converter")) then
        RegisterStatus("Melding Converter", 9.89, "http://firefall-wiki.com/images/firefall-wiki.com/9/9b/Icon_perk_basic_persistence.png"); --the .89 is to handle the slight delay for removal
      end

    end
  end
  if(args.damage > 0) then
    if(OPTIONS.trackHKM and not findName("Draconis Core") and PercentHealth() < 0.50 and CheckDraconisCore()) then
      RegisterStatus("Draconis Core", 29.89, "http://firefall-wiki.com/images/firefall-wiki.com/3/3d/Core-epic-transparent.png"); --the .89 is to handle the slight delay for removal
    end
  end
end

function CheckDraconisCore()
  local loadout = Player.GetCurrentLoadout()
  local chassisModules = loadout.modules.chassis;

  for _, modInfo in pairs(chassisModules) do --chassis modules include cores and perks, need to find the core module
    local itemTypeId = modInfo.item_sdb_id;
    local itemId = modInfo.item_guid;

    local itemInfo = nil;

    if (itemId and itemId ~= 0) then
      itemInfo = Player.GetItemInfo(itemId);
    end

    if (not itemInfo) then
      itemInfo = Game.GetItemInfoByType(itemTypeId);
    end
    if( itemInfo.moduleType == "Battleframe Core" and itemInfo.name == "Draconis Core") then
      return true
    end
  end
  return false
end

function CheckModules()
	if(findName("Module")) then return end
	local loadout = Player.GetCurrentLoadout()
    	if loadout and next(loadout.items.primary_weapon) then
        	local primary_weapon_info = Player.GetItemInfo(loadout.items.primary_weapon.item_guid)
		local weapon_info = {}
		local current_weapon = Player.GetWeaponInfo()	
		if not current_weapon then return end --player has no weapon equipped
		if(current_weapon.WeaponType == primary_weapon_info.weaponType) then --primary weapon currently being used
			weapon_info = primary_weapon_info
		else
			if(next(loadout.items.secondary_weapon)) then
				local secondary_weapon_info = Player.GetItemInfo(loadout.items.secondary_weapon.item_guid)
				if(current_weapon.WeaponType == secondary_weapon_info.weaponType) then --secondary weapon currently being used
					weapon_info = secondary_weapon_info
				else
					if(OPTIONS.debug) then
   						--Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text="COMPARISON ERROR"}); --for finding names that don't match
    						--Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=current_weapon.WeaponType});
    						--Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=primary_weapon_info.weaponType});
    						--Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=secondary_weapon_info.weaponType});
  					end
				end
			else
				if(OPTIONS.debug) then
    					--Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text="COMPARISON ERROR"}); --for finding names that don't match
    					--Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=current_weapon.WeaponType});
    					--Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=primary_weapon_info.weaponType});
 				end
			end
			
		end
		for _,module in pairs(weapon_info.slotted_modules) do
			if moduleIDs[tonumber(module)] then
				local itemInfo = Game.GetItemInfoByType(module)
				if(itemInfo and itemInfo.item_scalars) then
					for _,stat in pairs(itemInfo.item_scalars) do
						if(stat.name and string.find(stat.name, "Internal Cooldown")) then --get the module's ICD from the database
							RegisterStatus("Module", stat.value, moduleIDs[tonumber(module)].url);
							return
						end
					end
				end
			end
		end
    	end
end

function CheckAdjudication()
	local loadout = Player.GetCurrentLoadout()
    	if loadout and loadout.items.primary_weapon then
        	primary_weapon_info = Player.GetItemInfo(loadout.items.primary_weapon.item_guid)
		local weapon_info = {}
		local current_weapon = Player.GetWeaponInfo()	
		if not current_weapon then return end --player has no weapon equipped
		if(current_weapon.WeaponType == primary_weapon_info.weaponType) then --primary weapon currently being used
			weapon_info = primary_weapon_info
		else
			if(next(loadout.items.secondary_weapon)) then
				local secondary_weapon_info = Player.GetItemInfo(loadout.items.secondary_weapon.item_guid)
				if(current_weapon.WeaponType == secondary_weapon_info.weaponType) then --secondary weapon currently being used
					weapon_info = secondary_weapon_info
				else
					if(OPTIONS.debug) then
   						Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text="COMPARISON ERROR"}); --for finding names that don't match
    						Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=current_weapon.WeaponType});
    						Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=primary_weapon_info.weaponType});
    						Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=secondary_weapon_info.weaponType});
  					end
				end
			else
				if(OPTIONS.debug) then
    					Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text="COMPARISON ERROR"}); --for finding names that don't match
    					Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=current_weapon.WeaponType});
    					Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=primary_weapon_info.weaponType});
 				end
			end
			
		end
		for _,module in pairs(weapon_info.slotted_modules) do
			if module == 120699 then
				return 2
			end
			if module == 120700 then
				return 2.5
			end
		end
    	end
	return false
end

function PercentHealth()
  local life_info = Player.GetLifeInfo()
  return life_info["Health"]/life_info["MaxHealth"]
end

function AbilityReady(args)
  if(not OPTIONS.enabled) then return; end
end

function OnWeaponBurst(args)
  if(CheckPerkEquipped("Ambush") and not findName("Ambush")) then
    Callback2.FireAndForget(CheckAmbushCrit, nil, .5);
  end
	if(OPTIONS.trackPerks and CheckPerkEquipped("Sure Shot")) then
		local clientTime = tonumber(System.GetClientTime())
		local newBurstTime = clientTime - last_shot_time
		if newBurstTime > burst_time / 3.5 and newBurstTime < burst_time / 1.8 then
			RegisterStatus("Sure Shot", 3, "http://firefall-wiki.com/images/firefall-wiki.com/4/48/Icon_perk_advanced_sure_shot.png");
		end
		burst_time = newBurstTime
		last_shot_time = clientTime
	end
end

function OnWeaponModeChanged(args)
  if(OPTIONS.trackHKM) then
    CheckHMGActivated()
  end
end

function CheckHMGActivated()
  local state = Player.GetWeaponState()
  if(findName("HMG Shield")) then return; end
  if(state and not state.Locked and not HMGShieldUp and Player.GetWeaponMode() == 2 and CheckHMG()) then
    HMGShieldUp = true
  elseif(state and HMGShieldUp and (Player.GetWeaponMode() == 1 or state.Locked) and CheckHMG()) then
    HMGShieldUp = false
    RegisterStatus("HMG Shield", 5, "http://accorddb.no-ip.org/firefall/assets/items/64/ITEM_ID_114474.png");
    Callback2.FireAndForget(CheckHMGActivated, nil, 5.1);
  end
end

function OnWeaponStateChanged(args)
  if(OPTIONS.trackHKM) then
    CheckHMGActivated()
  end
end

function CheckHMG()
  local state = Player.GetWeaponState()
  if(state.AmmoType == "HMG Bullet") then
    return true
  else
    return false
  end
end

function CheckAmbushCrit()
  if(CheckPerkEquipped("Ambush") and not findName("Ambush")) then
    if(AmbushCrit == false) then
      RegisterStatus("Ambush", 9.6, "http://firefall-wiki.com/images/firefall-wiki.com/a/a5/Icon_perk_passive_ambush.png"); --9.6 for the .5 second delay, as well as a margin for error
    end
    AmbushCrit = false
  end
end

function OnCombatEvent(args)
  local localInfo = Chat.GetLocalUserInfo()
  if(localInfo and string.find(localInfo.player_name, args.SourceName)) then --was actually the player that got the kill
    local StatusWidget = findName("Ambush")
    for _, widget in pairs(m_widgetList) do
      if (string.find(widget.name, "Execution")) then
        RefreshDuration(widget.name, ExecutionDuration)
      end
    end
    if(StatusWidget) then
      for _, widget in pairs(m_widgetList) do
        if (string.find(widget.name, "Execution")) then
          RemoveStatusWidget(StatusWidget)
          return
        end
      end
    end
  end
end

-- Registration
function RegisterStatus(name, durationSeconds, web_icon)
  local statusWidget = CreateStatusWidget();
  statusWidget.HOLDER = statusWidget.WIDGET:GetChild("holder");
  statusWidget.WEB_ICON = statusWidget.HOLDER:GetChild("web_icon");
  statusWidget.ICON = statusWidget.HOLDER:GetChild("icon");
  statusWidget.COOLDOWN = statusWidget.HOLDER:GetChild("cooldown");
  statusWidget.COOLDOWN_COUNTER = statusWidget.HOLDER:GetChild("cooldown_counter");
	statusWidget.CIRCLE = statusWidget.HOLDER:GetChild("circle")
	statusWidget.BACKGROUND = statusWidget.HOLDER:GetChild("iconBackground")

  statusWidget.WEB_ICON:SetUrl(web_icon);
  statusWidget.WEB_ICON:Show(true);

--set colors
statusWidget.CIRCLE:SetParam("alpha", OPTIONS.startEdgeColor.alpha)
statusWidget.CIRCLE:SetParam("tint", "#" .. OPTIONS.startEdgeColor.tint)
statusWidget.BACKGROUND:SetParam("alpha", OPTIONS.startBackgroundColor.alpha)
statusWidget.BACKGROUND:SetParam("tint", "#" .. OPTIONS.startBackgroundColor.tint)
statusWidget.COOLDOWN:SetParam("alpha", OPTIONS.startArcColor.alpha)
statusWidget.COOLDOWN:SetParam("tint", "#" .. OPTIONS.startArcColor.tint)
statusWidget.WEB_ICON:SetParam("alpha", OPTIONS.startIconTint.alpha)
statusWidget.WEB_ICON:SetParam("tint", "#" .. OPTIONS.startIconTint.tint)
--set fading
statusWidget.CIRCLE:ParamTo("alpha", OPTIONS.endEdgeColor.alpha, durationSeconds)
statusWidget.CIRCLE:ParamTo("tint", "#" .. OPTIONS.endEdgeColor.tint, durationSeconds)
statusWidget.BACKGROUND:ParamTo("alpha", OPTIONS.endBackgroundColor.alpha, durationSeconds)
statusWidget.BACKGROUND:ParamTo("tint", "#" .. OPTIONS.endBackgroundColor.tint, durationSeconds)
statusWidget.COOLDOWN:ParamTo("alpha", OPTIONS.endArcColor.alpha, durationSeconds)
statusWidget.COOLDOWN:ParamTo("tint", "#" .. OPTIONS.endArcColor.tint, durationSeconds)
statusWidget.WEB_ICON:ParamTo("alpha", OPTIONS.endIconTint.alpha, durationSeconds)
statusWidget.WEB_ICON:ParamTo("tint", "#" .. OPTIONS.endIconTint.tint, durationSeconds)

  statusWidget.name = name;
  statusWidget.duration = durationSeconds * 1000;
  if(OPTIONS.showTime) then
	statusWidget.COOLDOWN_COUNTER:SetParam("alpha", OPTIONS.startTimerAlpha)
	statusWidget.COOLDOWN_COUNTER:ParamTo("alpha", OPTIONS.endTimerAlpha, durationSeconds)
	if(OPTIONS.floatingTimer) then
		statusWidget.COOLDOWN_COUNTER:SetDims("center-y:0%" .. OPTIONS.timerHeight)
	end
    statusWidget.COOLDOWN_COUNTER:StartTimer(durationSeconds, true)
  end
  statusWidget = statusWidget;
  statusWidget.startTime = tonumber(System.GetClientTime());
  UpdateDuration(statusWidget);
end


--- Widget helper functions
function CreateStatusWidget()
  local statusWidget = {WIDGET = Component.CreateWidget("Status", MAIN_FRAME)};
  statusWidget.identifier = GetNextIdentifer();
  m_widgetList[statusWidget.identifier] = statusWidget;
  UpdateWidgetListPositions();
  return statusWidget;
end

function GetNextIdentifer()
  m_identifier = m_identifier + 1;
  return m_identifier;
end

function RemoveStatusWidget(statusWidgetObject)
  Component.RemoveWidget(statusWidgetObject.WIDGET);
  m_widgetList[statusWidgetObject.identifier] = nil;
  UpdateWidgetListPositions();
  System.PlaySound(OPTIONS.sound)
end

function UpdateWidgetListPositions()
  local offset = 0;
  for i, widget in pairs(m_widgetList) do
	  widget.WIDGET:SetDims("left:"..tostring(offset * 84));
    offset = offset + 1;
  end
end

function UpdateDuration(statusWidgetObject)
  local pct =  (tonumber(System.GetClientTime()) - statusWidgetObject.startTime) / statusWidgetObject.duration;
  if (pct > 1) then
    RemoveStatusWidget(statusWidgetObject)
  else 
    SetCooldownArc(statusWidgetObject.COOLDOWN, pct);
    Callback2.FireAndForget(UpdateDuration, statusWidgetObject, 0.1);
  end
end

function SetCooldownArc(cooldownArc, pct)
  local angle = -180 + pct * 360;
  cooldownArc:SetParam("end-angle", angle);
  --cooldownArc:ParamTo("end-angle", 180, remainingCooldown);
end

function findName(name)
  for i, widget in pairs(m_widgetList) do
    if (widget.name == name) then
      return widget
    end
  end
  return False
end

function out(msg)
	local m = tostring(msg);
	log(m);
	Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=m});
end