bonusBags = LibStub("AceAddon-3.0"):NewAddon("bonusBags" , "AceConsole-3.0", "AceTimer-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local libS = LibStub("AceSerializer-3.0")

local best = GetRandomDungeonBestChoice();

local tank = false;
local heal = false;
local dps = false;

local tankAvailable = false;
local healAvailable = false;
local dpsAvailable = false;

local scanning = false;
local queueReady = '';

--[[FUNCTIONS]]--
function joinQueue()
  print("Joining Queue ",best)
  print(tankAvailable)
  print(healAvailable)
  print(dpsAvailable)
  SetLFGRoles(false, tankAvailable, healAvailable, dpsAvailable)
  SetLFGDungeon(1, best)
  JoinLFG(1)
  
end

function resetAvail()
  tankAvailable = false;
  healAvailable = false;
  dpsAvailable = false;
end

function bonusBags:CheckForRewards()
  
  local eligible, forTank, forHealer, forDamage, itemCount, money, xp = GetLFGRoleShortageRewards(best, 1);
  local foundOne = false;
  resetAvail()
  if (forTank and tank) then
    foundOne = true;
    tankAvailable = true;
  end

  if (forHealer and heal) then
    foundOne = true;
    healAvailable = true; 
  end

  if(forDamage and dps) then
    foundOne = true;
    damageAvailable = true;
  end
    
  if (foundOne) then
    bonusBags:loadCheck()
    endTimer()
  end
end

function setTimer()
  timer = bonusBags:ScheduleRepeatingTimer("CheckForRewards", 5)
end

function endTimer()
  bonusBags:CancelTimer(timer)
end

--[[Custom Frames]]--
function bonusBags:loadFrame(input)
  local buttonText = 'Not Scanning'
  if (scanning) then
    buttonText = 'Scanning'
  end
  
	local checkGroup = AceGUI:Create("SimpleGroup")
	checkGroup:SetFullWidth(false)
	checkGroup:SetFullHeight(false)
	checkGroup:SetLayout("List")
  
	local tankbox = AceGUI:Create("CheckBox")
  tankbox:SetLabel('Tank')
  --tankbox:SetDisabled(tank)
  tankbox:SetValue(tank)
  tankbox:SetCallback("OnValueChanged", function(value)
      tank = value;
    end)
  checkGroup:AddChild(tankbox)
  
	local healbox = AceGUI:Create("CheckBox")
  healbox:SetLabel('Heal')
  --healbox:SetDisabled(heal)
  healbox:SetValue(heal)
  healbox:SetCallback("OnValueChanged", function(value)
      heal = value;
    end)
  checkGroup:AddChild(healbox)
	
  local dpsbox = AceGUI:Create("CheckBox")
  dpsbox:SetLabel('Damage')
  --dpsbox:SetDisabled(dps)
  dpsbox:SetValue(dps)
  dpsbox:SetCallback("OnValueChanged", function(value)
      dps = value;
    end)
  checkGroup:AddChild(dpsbox)
  
  
	local btna = AceGUI:Create("Button")
	btna:SetWidth(170)
	btna:SetText(buttonText)
	btna:SetCallback("OnClick", function()
      if (not scanning) then
        setTimer()
        btna:SetText("Scanning")
        scanning = true;
      else
        endTimer()
        btna:SetText("Not Scanning")
        scanning = false;
      end
	end)
  
	local frame = AceGUI:Create("Frame")
	frame:SetTitle("bonusBags")
	frame:SetStatusText("Get your bags!")
  frame:SetWidth(300)
	frame:SetHeight(200)
	frame:SetLayout("List")
	_G["bonusBagsFrame"] = frame
	tinsert(UISpecialFrames, "bonusBagsFrame")
	frame:AddChildren(checkGroup, btna)
end

function bonusBags:loadCheck(input)
  PlaySound("RaidWarning", "Master")
  FlashClientIcon()
  scanning = false;
  
  local frame = AceGUI:Create("Frame")
	frame:SetTitle("Queue Ready")
  frame:SetWidth(375)
	frame:SetHeight(200)
	frame:SetLayout("List")
	_G["bonusBagsQueueFrame"] = frame
	tinsert(UISpecialFrames, "bonusBagsQueueFrame")
  
  local group = AceGUI:Create("SimpleGroup")
	group:SetFullWidth(true)
	group:SetFullHeight(false)
	group:SetLayout("Flow")
  
  local tankIcon = AceGUI:Create("Icon")
  tankIcon:SetImage("Interface\\LFGFrame\\UI-LFG-ICON-ROLES", 0, 0.25, .26, 0.51)
  tankIcon:SetDisabled(not tankAvailable)
  tankIcon:SetImageSize(64,64)
  
  local healIcon = AceGUI:Create("Icon")
  healIcon:SetImage("Interface\\LFGFrame\\UI-LFG-ICON-ROLES", .26, 0.51, 0, 0.25)
  healIcon:SetDisabled(not healAvailable)
  healIcon:SetImageSize(64,64)
  
  local dpsIcon = AceGUI:Create("Icon")
  dpsIcon:SetImage("Interface\\LFGFrame\\UI-LFG-ICON-ROLES", .26, 0.51, .26, 0.51)
  dpsIcon:SetDisabled(not dpsAvailable)
  dpsIcon:SetImageSize(64,64)
  group:AddChildren(tankIcon, healIcon, dpsIcon)
  
  local button = AceGUI:Create("Button")
  button:SetText("Queue")
  button:SetWidth(340)
  button:SetHeight(50)
  button:SetCallback("OnClick", function()
      joinQueue()
    end)
  
  frame:AddChildren(group, button)
end

--[[Chat Commands]]--

bonusBags:RegisterChatCommand("bb", "loadFrame")