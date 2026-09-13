local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/UnclearGhxst/lib/refs/heads/main/Nexonix_Local.lua?v=20260913"))()

local KeybindList = Library:KeybindList({ Name = "Keybind List" })

local Window = Library:Window({ Logo = "rbxassetid://77749228793011" })
do
    local TabOne   = Window:Page({ Icon = "rbxassetid://129245697782918" })
    local TabTwo   = Window:Page({ Icon = "rbxassetid://129245697782918" })
    local TabThree = Window:Page({ Icon = "rbxassetid://129245697782918" })
    local TabFour  = Window:Page({ Icon = "rbxassetid://129245697782918" })

    -- =====================================================================
    -- TAB 1: Main (Side 1) & Skin Manager (Side 2 - where Weapon was)
    -- =====================================================================
    do
        local Main        = TabOne:Section({ Name = "Main", Side = 1 })
        local SkinManager = TabOne:Section({ Name = "Skin Manager", Side = 2 })

        -- Toggle: All Buttons
        local AllButtons  = Main:Toggle({
            Name = "All Buttons",
            Flag = "AllButtons",
            Default = false,
            Tooltip = "Toggle all buttons",
            Callback = function(Value)
                print("All Buttons:", Value)
            end
        })

        -- Keybind attached to the All Buttons toggle
        AllButtons:Keybind({
            Name = "Key",
            Flag = "AllButtonsKey",
            Default = Enum.KeyCode.E,
            Mode = "Toggle",
            Callback = function(Value)
                print("All Buttons Keybind:", Value)
            end
        })

        -- Button
        Main:Button({
            Name = "Button",
            Tooltip = "Main action button",
            Callback = function()
                print("Main Button Clicked")
            end
        })

        -- -----------------------------------------------------------------
        -- Side 2: Skin Manager (placed where Weapon was)
        -- -----------------------------------------------------------------
        local selectedSkinSlot = "A"

        local function parseSlot(val)
            if not val or val == (Library.DEFAULT_SKIN_NAME or "Big Dick") then return 0 end
            for i = 1, 6 do
                local name = Library.GetSlotName and Library.GetSlotName(i) or ("Slot " .. i)
                if val:match("^" .. name) or val:match("^Slot " .. i) or val == tostring(i) then
                    return i
                end
            end
            for _, letter in { "A", "B", "C", "D" } do
                local name = Library.GetSlotName and Library.GetSlotName(letter) or ("Slot " .. letter)
                if val:match("^" .. name) or val:match("^Slot " .. letter) or val == letter then
                    return letter
                end
            end
            return val
        end

        -- Helper: get a clean display name from a raw dropdown value
        local function getSlotDisplayName(val)
            if not val or val == (Library.DEFAULT_SKIN_NAME or "Big Dick") then
                return Library.DEFAULT_SKIN_NAME or "Big Dick"
            end
            for i = 1, 6 do
                local name = Library.GetSlotName and Library.GetSlotName(i) or ("Slot " .. i)
                if val:find(name, 1, true) or val:find("Slot " .. i, 1, true) or val == tostring(i) then
                    return name
                end
            end
            return val
        end

        -- Dropdown menu: Skin Slot
        local SkinSlotDropdown

        local function updateSkinSlotLabel(value)
            if SkinSlotDropdown then
                SkinSlotDropdown:SetText("Skin Slot (" .. tostring(getSlotDisplayName(value)) .. ")")
            end
        end

        local function refreshSkinSlotDropdown(value)
            if Library.GetSkinsList then
                Library:GetSkinsList(SkinSlotDropdown)
            end
            if value and SkinSlotDropdown.Set then
                SkinSlotDropdown:Set(value)
            end
            updateSkinSlotLabel(value or SkinSlotDropdown.Value)
        end

        SkinSlotDropdown = SkinManager:Dropdown({
            Name = "Skin Slot",
            Flag = "SkinSlot",
            Scrollable = #(Library.ListSkinNames and Library.ListSkinNames() or {}) > 5,
            Default = (Library.GetSlotName and Library.GetSlotName(1)) or "Slot 1",
            Items = (Library.BuildSlotNamesList and Library.BuildSlotNamesList()) or { "A", "B", "C", "D" },
            Callback = function(Value)
                selectedSkinSlot = parseSlot(Value)
                updateSkinSlotLabel(Value)
            end
        })
        updateSkinSlotLabel(SkinSlotDropdown.Value)

        -- Optional name used when saving the selected slot
        local SkinNameInput = SkinManager:Textbox({
            Name = "Skin Name",
            Placeholder = "Enter skin name...",
            Flag = "SaveSkinName",
            Numeric = false,
            Finished = true,
            Callback = function(Value)
                print("Typed Slot Name:", Value)
            end
        })

        -- Button: Save skin and optional name to slot
        SkinManager:Button({
            Name = "Save Skin Slot",
            Tooltip = "Save and name the selected skin slot",
            Callback = function()
                local slot = selectedSkinSlot or "A"
                if slot == 0 then
                    Library:Notification("Cannot overwrite default skin.", 3, Color3.fromRGB(255, 100, 100))
                    return
                end

                local newName = (Library.Flags["SaveSkinName"] or ""):gsub("^%s+", ""):gsub("%s+$", "")
                if newName ~= "" and Library.SetSlotName then
                    local renamed, renameError = Library.SetSlotName(slot, newName)
                    if not renamed then
                        local message = renameError == "NAME_EXISTS"
                            and "A skin with this name already exists."
                            or "Failed to name skin: " .. tostring(renameError or "error")
                        Library:Notification(message, 3, Color3.fromRGB(255, 100, 100))
                        return
                    end
                end

                if Library.SaveSkinToSlot then
                    local ok, err = Library.SaveSkinToSlot(slot)
                    if ok then
                        local savedName = Library.GetSlotName and Library.GetSlotName(slot) or tostring(slot)
                        refreshSkinSlotDropdown(savedName)
                        SkinNameInput:Set("")
                        Library:Notification("Saved " .. tostring(savedName) .. "!", 3,
                            Color3.fromRGB(0, 255, 120))
                    else
                        local currentName = Library.GetSlotName and Library.GetSlotName(slot)
                        refreshSkinSlotDropdown(currentName)
                        local message = err == "DUPLICATE" and "You already saved this skin."
                            or err == "LIMIT" and "You can only save 6 skins."
                            or "Failed to save skin: " .. tostring(err or "error")
                        Library:Notification(message, 3, Color3.fromRGB(255, 100, 100))
                    end
                else
                    Library:Notification("Saved skin to Slot " .. tostring(slot), 3, Color3.fromRGB(0, 255, 120))
                end
            end
        })

        -- Button: Load skin from slot
        SkinManager:Button({
            Name = "Load Skin from Slot",
            Tooltip = "Load skin from selected slot and apply to character",
            Callback = function()
                local slot = selectedSkinSlot or "A"
                if Library.ApplySkinFromSlot then
                    local ok, err = Library.ApplySkinFromSlot(slot)
                    if ok then
                        local label = slot == 0 and (Library.DEFAULT_SKIN_NAME or "Default") or
                            (Library.GetSlotName and Library.GetSlotName(slot) or tostring(slot))
                        Library:Notification("Loaded skin: " .. tostring(label) .. "!", 3, Color3.fromRGB(0, 180, 255))
                    else
                        Library:Notification("Failed to load skin: " .. tostring(err or "Empty slot"), 3,
                            Color3.fromRGB(255, 100, 100))
                    end
                else
                    Library:Notification("Loaded skin from Slot " .. tostring(slot), 3, Color3.fromRGB(0, 180, 255))
                end
            end
        })

        -- Button: Delete skin from slot
        SkinManager:Button({
            Name = "Delete Skin from Slot",
            Tooltip = "Delete skin from selected slot",
            Callback = function()
                local slot = selectedSkinSlot or "A"
                if slot == 0 then
                    Library:Notification("Cannot delete default skin.", 3, Color3.fromRGB(255, 100, 100))
                    return
                end
                if Library.DeleteSkinSlot then
                    Library.DeleteSkinSlot(slot)
                    if Library.GetSkinsList then
                        Library:GetSkinsList(SkinSlotDropdown)
                    end
                    Library:Notification("Deleted skin from slot " .. tostring(slot) .. ".", 3,
                        Color3.fromRGB(255, 74, 116))
                else
                    Library:Notification("Deleted skin from Slot " .. tostring(slot), 3, Color3.fromRGB(255, 74, 116))
                end
            end
        })
    end

    -- =====================================================================
    -- TAB 2: Weapon & Visuals
    -- =====================================================================
    do
        local WeaponSection  = TabTwo:Section({ Name = "Weapon", Side = 1 })
        local VisualsSection = TabTwo:Section({ Name = "Visuals", Side = 2 })

        local WeaponToggle   = WeaponSection:Toggle({
            Name = "Weapon Toggle",
            Flag = "WeaponToggle",
            Default = false,
            Tooltip = "Weapon toggle option",
            Callback = function(Value)
                print("Weapon Toggle:", Value)
            end
        })

        local ToggleSettings = WeaponToggle:Settings(200)

        ToggleSettings:Toggle({
            Name = "Sub Toggle",
            Flag = "SubToggle",
            Default = false,
            Callback = function(Value)
                print("Sub Toggle:", Value)
            end
        })

        ToggleSettings:Button({
            Name = "Sub Button",
            Callback = function()
                print("Sub Button Clicked")
            end
        })

        ToggleSettings:Slider({
            Name = "Sub Slider",
            Flag = "SubSlider",
            Min = 1,
            Max = 100,
            Default = 50,
            Suffix = "%",
            Decimals = 1,
            Callback = function(Value)
                print("Sub Slider:", Value)
            end
        })

        ToggleSettings:Dropdown({
            Name = "Sub Dropdown",
            Flag = "SubDropdown",
            Default = "First",
            Items = { "First", "Second", "Third", "Fourth", "Fifth", "Sixth" },
            Callback = function(Value)
                print("Sub Dropdown:", Value)
            end
        })

        ToggleSettings:Label({ Name = "Sub Color" }):Colorpicker({
            Flag = "SubColorpicker",
            Default = Color3.fromRGB(255, 255, 255),
            Callback = function(Value)
                print("Sub Color:", Value)
            end
        })

        WeaponToggle:Keybind({
            Name = "Weapon Keybind",
            Flag = "WeaponKeybind",
            Default = Enum.KeyCode.E,
            Mode = "Toggle",
            Callback = function(Value)
                print("Weapon Keybind:", Value)
            end
        })

        WeaponSection:RangeSlider({
            Name = "Range",
            Flag = "WeaponRange",
            Default = { 3, 5 },
            Gap = 16,
            Min = 0.1,
            Max = 10,
            Decimals = 0.1,
            Callback = function(value)
                warn("Range:", value[1], value[2])
            end
        })

        -- Visuals Section on Tab 2 Side 2
        VisualsSection:Toggle({
            Name = "Custom Cham",
            Flag = "SkinChams",
            Default = true,
            Callback = function(Value)
                print("Custom Cham:", Value)
            end
        })

        VisualsSection:Label({ Name = "Skin Color" }):Colorpicker({
            Flag = "SkinColor",
            Default = Color3.fromRGB(255, 74, 116),
            Callback = function(Value)
                print("Skin Color:", Value)
            end
        })

        VisualsSection:Slider({
            Name = "Glow Intensity",
            Flag = "SkinGlow",
            Min = 0,
            Max = 100,
            Default = 75,
            Suffix = "%",
            Decimals = 1,
            Callback = function(Value)
                print("Glow:", Value)
            end
        })
    end
end

Library:Notification("Nexonix Library Loaded!", 5, Color3.fromRGB(54, 60, 143))
