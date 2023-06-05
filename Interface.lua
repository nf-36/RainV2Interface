local Interface   = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local ElementProperties = {
    ["Boolean"] = {
        Enabled = Color3.fromRGB(0, 110, 255),
        Disabled = Color3.fromRGB(12, 12, 12),
        DisabledPosition = UDim2.new(0.1, -2, 0.5, 0),
        EnabledPosition = UDim2.new(0.5, -3, 0.5, 0),
    },
    ["Minimise"] = {
        Enabled = "rbxassetid://3926305904",
        Disabled =  "rbxassetid://3926305904"
    },
    Accent = Color3.fromRGB(0, 110, 255) 
}

local interface_name = crypt.base64.encode(tostring(Players.LocalPlayer.UserId))

if (gethui) then
    for i, gui in pairs(gethui():GetChildren()) do 
        if (gui.Name == interface_name) then
            gui:Destroy()
        end
    end
else
    for i, gui in pairs(CoreGui:GetChildren()) do 
        if (gui.Name == interface_name) then
            gui:Destroy()
        end
    end
end

local Rain = game:GetObjects("rbxassetid://13580655431")[1]
Rain.Name = interface_name

function Interface:BeginMenu(menu_options) 
    if not (Rain.Enabled) then
        Rain.Enabled = true
    end

    if (gethui) then
        Rain.Parent = gethui()
    elseif (syn.protect_gui) then
        syn.protect_gui(Rain)
        Rain.Parent = CoreGui
    elseif (CoreGui ~= nil) then
        Rain.Parent = CoreGui
    end

    local ElementClasses = {}

    local info = TweenInfo.new(.2, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
    local ContainerOpen = false
    local Container = nil

    local Connections = {}

    local TextHoverColor = Color3.fromRGB(0, 79, 182)

    local ElementsEnabled = true
    local SearchShowing = false
    local WindowMinimised = false

    local pickerFrame = nil
    local currentSelectedCP = nil
    local colorPickerShowing = false

    local Window = Rain:WaitForChild("Window")
    local Elements = Window:WaitForChild("Elements")
    local WindowSHolder = Window:WaitForChild("WindowSHolder")
    local Navigation = Window:WaitForChild("Navigation")

    Navigation.WindowTitle.Text = menu_options.Title

    Elements.ClipsDescendants = true

    local GreyOut = nil

    Window.Position = UDim2.new(0.35, 0, 0.15, 0)

    if (Navigation:WaitForChild("WindowTitle")) then
        Navigation.WindowTitle.Text = menu_options.Text or "Rain V2"
    end

    if (Elements:WaitForChild("TabDisplay"):WaitForChild("GreyOut")) then
        GreyOut = Elements.TabDisplay.GreyOut
        GreyOut.BackgroundTransparency = 0
    end

    TweenService:Create(GreyOut, TweenInfo.new(.8, Enum.EasingStyle.Quart), {
        BackgroundTransparency = 1
    }):Play()

    if (Navigation:WaitForChild("NavigationOptions")) then
        local max_size = 21
        local sizes = {
        	19,
        	15,
        	11
        }

        local hovering = false

        local p = Navigation.NavigationOptions
        local nol1, nol2, nol3 = p.NOLine1, p.NOLine2, p.NOLine3

        local function UpdateLines() 
        	if (hovering and not ContainerOpen) then
        		TweenService:Create(nol1, info, {
        			Size = UDim2.new(0, max_size, 0, 4)
        		}):Play()
        		TweenService:Create(nol2, info, {
        			Size = UDim2.new(0, max_size, 0, 4)
        		}):Play()
        		TweenService:Create(nol3, info, {
        			Size = UDim2.new(0, max_size, 0, 4)
        		}):Play()
        		TweenService:Create(p.NOStroke, info, {
        			Transparency = 0
        		}):Play()
        	elseif not (ContainerOpen) and not hovering then
        		TweenService:Create(nol1, info, {
        			Size = UDim2.new(0, sizes[1], 0, 4)
        		}):Play()
        		TweenService:Create(nol2, info, {
        			Size = UDim2.new(0, sizes[2], 0, 4)
        		}):Play()
        		TweenService:Create(nol3, info, {
        			Size = UDim2.new(0, sizes[3], 0, 4)
        		}):Play()
        		TweenService:Create(p.NOStroke, info, {
        			Transparency = 1
        		}):Play()
        	end
        end

        p.MouseEnter:Connect(function() 
            if (WindowMinimised) then
                return
            end

        	hovering = true
        	UpdateLines()
        end)

        p.MouseLeave:Connect(function()
            if (WindowMinimised) then
                return
            end

        	hovering = false
        	UpdateLines()
        end)

        if (p:WaitForChild("NOActivator") and Navigation:WaitForChild("NavigationOptionsContainer")) then
            Container = Navigation.NavigationOptionsContainer
            local Debounce = false

            local function UpdateContainer()
                if (WindowMinimised) then
                    return
                end

                if (ContainerOpen) then
                    ElementsEnabled = false
                    TweenService:Create(Container, info, {
                        Position = UDim2.new(0.5, 0, 0, 63)
                    }):Play()
                    TweenService:Create(GreyOut, info, {
                        BackgroundTransparency = 0.65
                    }):Play()

                    for i, e in pairs(Elements.TabDisplay:GetDescendants()) do 
                        if (e:IsA("TextBox")) then
                            e.Active = false
                            e.TextEditable = false
                        end
                    end
                else
                    ElementsEnabled = true
                    TweenService:Create(Container, info, {
                        Position = UDim2.new(0.5, 0, 0, 8)
                    }):Play()
                    TweenService:Create(GreyOut, info, {
                        BackgroundTransparency = 1
                    }):Play()

                    for i, e in pairs(Elements.TabDisplay:GetDescendants()) do 
                        if (e:IsA("TextBox")) then
                            e.Active = true
                            e.TextEditable = true
                        end
                    end
                end
            end

            p.NOActivator.MouseButton1Click:Connect(function()
                if (WindowMinimised) then
                    return
                end

                if not (Debounce) then
                    ContainerOpen = not ContainerOpen
                    UpdateContainer()

                    Debounce = true
                    task.wait(.2)
                    Debounce = false
                end
            end)
        end
    end

    local currentPage = nil
    local tabPageTemplate = nil
    local buttonTemplate = nil

    if (Navigation:WaitForChild("NavigationOptionsContainer"):WaitForChild("TabButtonDisplay"):WaitForChild("TBDContainer"):WaitForChild("TabButton")) then
        buttonTemplate = Navigation.NavigationOptionsContainer.TabButtonDisplay.TBDContainer.TabButton
        buttonTemplate.Visible = false
    end

    if (Elements:WaitForChild("TabDisplay"):WaitForChild("Tab1")) then
        tabPageTemplate = Elements.TabDisplay.Tab1
        tabPageTemplate.Visible = false
    end

    if (Navigation:WaitForChild("CloseInterface")) then
        local closeInterface = Navigation.CloseInterface

        closeInterface:FindFirstChild("CIStroke").Transparency = 1
        closeInterface:FindFirstChild("CIActivator").Position = UDim2.new(0.5, 0, 0.5, 0)

        Connections["close_enter"] = closeInterface.MouseEnter:Connect(function()
            if (WindowMinimised) then
                return
            end

            TweenService:Create(closeInterface:FindFirstChild("CIStroke"), info, {
                Transparency = 0
            }):Play()
        end)

        Connections["close_leave"] = closeInterface.MouseLeave:Connect(function()
            if (WindowMinimised) then
                return
            end

            TweenService:Create(closeInterface:FindFirstChild("CIStroke"), info, {
                Transparency = 1
            }):Play()
        end)

        Connections["close_interface"] = closeInterface:FindFirstChild("CIActivator").MouseButton1Click:Connect(function()
            for i, v in pairs(Rain:GetDescendants()) do 
                if (v:IsA("Frame")) then
                    TweenService:Create(v, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 1
                    }):Play()
                elseif (v:IsA("ImageLabel") or v:IsA("ImageButton")) then
                    TweenService:Create(v, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        ImageTransparency = 1
                    }):Play()
                elseif (v:IsA("TextLabel") or v:IsA("TextButton")) then
                    TweenService:Create(v, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        TextTransparency = 1, TextStrokeTransparency = 1, BackgroundTransparency = 1
                    }):Play()
                elseif (v:IsA("UIStroke")) then
                    TweenService:Create(v, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Transparency = 1
                    }):Play()
                end
            end

            task.wait(.5)

            Rain:Destroy()

            for i, v in pairs(Connections) do 
                v:Disconnect()
            end
        end)
    end

    if (Navigation:WaitForChild("SearchTab")) then
        local searchButton = Navigation:WaitForChild("SearchTab"):WaitForChild("STActivator")
        local searchBar = Navigation:WaitForChild("SearchContainer")
        
        Navigation:WaitForChild("SearchTab"):WaitForChild("STStroke").Transparency = 1

        searchBar.SCGrabber.BackgroundTransparency = 1

        local HiddenPosition = UDim2.new(0.5, 0, 0, 3)
        local HiddenSize = UDim2.new(1, -140, 0, 30)
        local ShowingPosition = UDim2.new(0.5, 0, 0, -50)
        local ShowingSize = UDim2.new(1, 0, 0, 30)

        local function UpdateSearchBar() 
            if (SearchShowing) then
                searchBar.SCInput.Visible = true

                TweenService:Create(searchBar, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                    Position = ShowingPosition, Size = ShowingSize
                }):Play()
            else
                TweenService:Create(searchBar, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                    Position = HiddenPosition, Size = HiddenSize
                }):Play()

                searchBar.SCInput.Visible = false

                searchBar.SCInput.Text = ""
                for i, comp in ipairs(currentPage:WaitForChild("TabElementContainer"):GetChildren()) do 
                    if (comp:IsA("Frame")) then
                        comp.Visible = true
                    end
                end
            end
        end

        pcall(UpdateSearchBar)

        Connections["search_enter"] = Navigation:WaitForChild("SearchTab").MouseEnter:Connect(function()
            if (WindowMinimised) then
                return
            end

            TweenService:Create(Navigation:WaitForChild("SearchTab"):FindFirstChild("STStroke"), info, {
                Transparency = 0
            }):Play()
        end)

        Connections["search_leave"] = Navigation:WaitForChild("SearchTab").MouseLeave:Connect(function()
            if (WindowMinimised) then
                return
            end

            TweenService:Create(Navigation:WaitForChild("SearchTab"):FindFirstChild("STStroke"), info, {
                Transparency = 1
            }):Play()
        end)

        Connections["grabber_enter"] = searchBar.SCGrabber.MouseEnter:Connect(function()
            if (WindowMinimised) then
                return
            end

            TweenService:Create(searchBar.SCGrabber, info, {
                BackgroundTransparency = 0
            }):Play()
        end)

        Connections["grabber_leave"] = searchBar.SCGrabber.MouseLeave:Connect(function()
            if (WindowMinimised) then
                return
            end

            TweenService:Create(searchBar.SCGrabber, info, {
                BackgroundTransparency = 1
            }):Play()
        end)

        local Debounce = false
        Connections["show_s_bar"] = searchButton.MouseButton1Click:Connect(function()
            if (WindowMinimised) then
                return
            end

            if not (Debounce) then
                SearchShowing = not SearchShowing
                UpdateSearchBar()

                Debounce = true
                task.wait(.2)
                Debounce = false
            end
        end)

        Connections["filter_query"] = searchBar:WaitForChild("SCInput"):GetPropertyChangedSignal("Text"):Connect(function()
            if (WindowMinimised) then
                return
            end

            if not (SearchShowing) then
                return
            end

            local query = searchBar.SCInput.Text:lower()
            for i, comp in ipairs(currentPage:WaitForChild("TabElementContainer"):GetChildren()) do 
                --> Filter, and show the first result, show any that also match
                if (comp:IsA("Frame")) then
                    local compName = comp:FindFirstChildOfClass("TextLabel")
                    if (compName.Name:find("Title")) then
                        local compText = compName.Text:lower()
                        if (compText:find(query, 1, true)) then
                            comp.Visible = true
                        else
                            comp.Visible = false
                        end
                    end
                end
            end
        end)

        Connections["clear_query"] = searchBar:WaitForChild("SCClearQuery").MouseButton1Click:Connect(function()
            if (WindowMinimised) then
                return
            end

            searchBar.SCInput.Text = ""
            for i, comp in ipairs(currentPage:WaitForChild("TabElementContainer"):GetChildren()) do 
                if (comp:IsA("Frame")) then
                    comp.Visible = true
                end
            end
        end)

        coroutine.wrap(function()
            local dragging = false
            local dragInput, dragStart, startPos = nil, nil, nil

            local function UpdateDrag(input)
                local delta = input.Position - dragStart
                local newPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)

                local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(searchBar, tweenInfo, { Position = newPosition }):Play()
            end

            Connections["drag_start"] = searchBar.InputBegan:Connect(function(input)
                if (WindowMinimised) then
                    return
                end

                if (input.UserInputType == Enum.UserInputType.MouseButton1) and SearchShowing then
                    dragging, dragStart, startPos = true, input.Position, searchBar.Position

                    input.Changed:Connect(function()
                        if (input.UserInputState == Enum.UserInputState.End) then
                            dragging = false
                        end
                    end)
                end
            end)

            Connections["drag_move"] = searchBar.InputChanged:Connect(function(input)
                if (WindowMinimised) then
                    return
                end

                if (input.UserInputType == Enum.UserInputType.MouseMovement) and SearchShowing then
                    dragInput = input
                end
            end)

            Connections["drag_update"] = UserInputService.InputChanged:Connect(function(input)
                if (WindowMinimised) then
                    return
                end

                if (input == dragInput and dragging) and SearchShowing then
                    pcall(UpdateDrag, input)
                end
            end)
        end)()
    end

    if (Navigation:WaitForChild("MinimiseInterface")) then
        local miniContainer = Navigation.MinimiseInterface
        local miniActivator = miniContainer:WaitForChild("MIActivator")

        Connections["mini_enter"] = miniContainer.MouseEnter:Connect(function()
            TweenService:Create(miniContainer:FindFirstChildOfClass("UIStroke"), info, {
                Transparency = 0
            }):Play()
        end)

        Connections["mini_leave"] = miniContainer.MouseLeave:Connect(function()
            TweenService:Create(miniContainer:FindFirstChildOfClass("UIStroke"), info, {
                Transparency = 1
            }):Play()
        end)
        
        local i = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        local function UpdateOnMinimised() 
            if (WindowMinimised) then
                local WindowTween = TweenService:Create(Window, i, {
                    Size = UDim2.new(0, 450, 0, 60)
                })

                TweenService:Create(miniActivator, TweenInfo.new(.1), { ImageTransparency = 1 }):Play()
                miniActivator.Image = ElementProperties.Minimise.Enabled
                TweenService:Create(miniActivator, TweenInfo.new(.1), { ImageTransparency = 0 }):Play()

                WindowTween.Completed:Connect(function(playbackState)
                    local accent = Navigation:FindFirstChild("NavigationAccentHolder"):FindFirstChild("NavigationAccent")
                    TweenService:Create(accent.Parent, i, { Size = UDim2.new(1, 0, 0, 3) }):Play()          -- 7
                    TweenService:Create(accent, i, { Size = UDim2.new(0, 0, 0, 1) }):Play()                 -- 1
                    local optionExpand = Navigation:FindFirstChild("NavigationOptions")
                    local searchTabs   = Navigation:FindFirstChild("SearchTab")

                    for _, v in pairs(optionExpand:GetChildren()) do 
                        if (v:IsA("Frame")) then
                            TweenService:Create(v, i, { BackgroundTransparency = 1 }):Play()
                        end
                    end

                    for _, v in pairs(searchTabs:GetChildren()) do 
                        if (v:IsA("ImageButton")) then
                            TweenService:Create(v, i, { ImageTransparency = 1 }):Play()
                        end
                    end

                    local windowTitle = Navigation:FindFirstChild("WindowTitle")

                    TweenService:Create(windowTitle, i, { Position = UDim2.new(0.038, 0, 0.036, 0) }):Play()

                    if (SearchShowing) then
                        SearchShowing = false

                        TweenService:Create(searchBar, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                            Position = HiddenPosition, Size = HiddenSize
                        }):Play()
        
                        searchBar.SCInput.Visible = false
        
                        searchBar.SCInput.Text = ""
                        for i, comp in ipairs(currentPage:WaitForChild("TabElementContainer"):GetChildren()) do 
                            if (comp:IsA("Frame")) then
                                comp.Visible = true
                            end
                        end
                    end
                end)

                WindowTween:Play()
            else
                local WindowTween = TweenService:Create(Window, i, {
                    Size = UDim2.new(0, 450, 0, 500)
                })

                TweenService:Create(miniActivator, TweenInfo.new(.1), { ImageTransparency = 1 }):Play()
                miniActivator.Image = ElementProperties.Minimise.Disabled
                TweenService:Create(miniActivator, TweenInfo.new(.1), { ImageTransparency = 0 }):Play()

                WindowTween.Completed:Connect(function(playbackState)
                    local accent = Navigation:FindFirstChild("NavigationAccentHolder"):FindFirstChild("NavigationAccent")
                    TweenService:Create(accent.Parent, i, { Size = UDim2.new(1, 0, 0, 7) }):Play()          -- 7
                    TweenService:Create(accent, i, { Size = UDim2.new(1, 0, 0, 1) }):Play()                 -- 1
                    local optionExpand = Navigation:FindFirstChild("NavigationOptions")
                    local searchTabs   = Navigation:FindFirstChild("SearchTab")
                    for _, v in pairs(optionExpand:GetChildren()) do 
                        if (v:IsA("Frame")) then
                            TweenService:Create(v, i, { BackgroundTransparency = 0 }):Play()
                        end
                    end

                    for _, v in pairs(searchTabs:GetChildren()) do 
                        if (v:IsA("ImageButton")) then
                            TweenService:Create(v, i, { ImageTransparency = 0 }):Play()
                        end
                    end

                    local windowTitle = Navigation:FindFirstChild("WindowTitle")

                    TweenService:Create(windowTitle, i, { Position = UDim2.new(0.131, 0, 0.036, 0) }):Play()
                end)

                WindowTween:Play()
            end
        end

        local Debounce = false
        Connections["mini_click"] = miniActivator.MouseButton1Click:Connect(function()
            if (SearchShowing) then
               return 
            end

            if (not Debounce) then
                WindowMinimised = not WindowMinimised
                UpdateOnMinimised()

                Debounce = true
                task.wait(.4)
                Debounce = false
            end
        end)
    end

    if (Elements:WaitForChild("ColorPicker")) then
        pickerFrame = Elements.ColorPicker

        for _, v in ipairs(pickerFrame:GetDescendants()) do 
            if (v:IsA("Frame")) then v.BackgroundTransparency = 1 end
            if (v:IsA("TextLabel")) then v.TextTransparency = 1 end
            if (v:IsA("TextButton")) then v.TextTransparency = 1 end
            if (v:IsA("ImageLabel")) then v.ImageTransparency = 1 end
        end

        pickerFrame.Visible = false

        local cDisplay = pickerFrame:WaitForChild("CPDisplay")
        local cColors = pickerFrame:WaitForChild("CPColors")
        local cBrightness = pickerFrame:WaitForChild("CPBrightness")

        cBrightness.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

        local numGradientColors = 360

        local function generateGradientColors()
            local colorSequence = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), -- Red at the left side
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)), -- Green in the middle
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255)) -- Blue at the right side
            }

            cColors:FindFirstChildOfClass("UIGradient").Color = colorSequence
        end

        generateGradientColors()

        --> Update current color on color picker show.
        Connections["update_on_open"] = cDisplay:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
            if (colorPickerShowing) then
                TweenService:Create(cDisplay, TweenInfo.new(.1, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = currentSelectedCP.Default
                }):Play()

                cBrightness:FindFirstChildOfClass("UIGradient").Color = ColorSequence.new(
                    Color3.fromRGB(currentSelectedCP.Default.R,currentSelectedCP.Default.G,currentSelectedCP.Default.B,
                    Color3.new(0, 0, 0)
                ))
            end
        end)

        local function UpdateColorBrightness(posX, color, darkness)
            local sizeX = cBrightness.AbsoluteSize.X
            local offsetX = cBrightness.AbsolutePosition.X
            local normalizedX = (posX - offsetX) / sizeX
        
            -- Adjust the brightness of the selected color based on the darkness value (0-1)
            local newSelectedColor = color:Lerp(Color3.new(0, 0, 0), darkness)
        
            cBrightness:FindFirstChildOfClass("UIGradient").Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, newSelectedColor),
                ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
            }
        end
        
        local function UpdateColorChange(posX)
            local sizeX = cColors.AbsoluteSize.X
            local offsetX = cColors.AbsolutePosition.X
            local normalizedX = (posX - offsetX) / sizeX
        
            local colorSequence = cColors:FindFirstChild("UIGradient").Color
            local keypoints = colorSequence.Keypoints
        
            local k1, k2
            for i = 1, #keypoints - 1 do
                if keypoints[i + 1].Time >= normalizedX then
                    k1 = keypoints[i]
                    k2 = keypoints[i + 1]
                    break
                end
            end
        
            local c1 = k1.Value
            local c2 = k2.Value
            local t1 = k1.Time
            local t2 = k2.Time
        
            local t = (normalizedX - t1) / (t2 - t1)
            local color = c1:Lerp(c2, t)
        
            local darkness = 0
        
            UpdateColorBrightness(posX, color, darkness)
        
            TweenService:Create(cDisplay, TweenInfo.new(.3, Enum.EasingStyle.Quad), {
                BackgroundColor3 = color
            }):Play()

            local suc, req = pcall(currentSelectedCP.OnChanged, color)
            assert(suc, req)
        end
        
        local darknessDragging = false
        
        Connections["update_color_brightness"] = cBrightness:WaitForChild("CPDBActivator").MouseButton1Down:Connect(function()
            if not colorPickerShowing then
                return
            end
        
            darknessDragging = true
        end)
        
        Connections["update_darkness"] = cBrightness.CPDBActivator.MouseMoved:Connect(function()
            if (darknessDragging) then
                local mouse = UserInputService:GetMouseLocation()
                local darkness = (mouse.X - cBrightness.AbsolutePosition.X) / cBrightness.AbsoluteSize.X

                darkness = math.clamp(darkness, 0, 1)
        
                local colorSequence = cBrightness:FindFirstChild("UIGradient").Color
                local keypoints = colorSequence.Keypoints
        
                local k1 = keypoints[1]
                local k2 = keypoints[#keypoints]
        
                local c1 = k1.Value
                local c2 = k2.Value
                local t1 = k1.Time
                local t2 = k2.Time
        
                local t = (darkness - t1) / (t2 - t1)
                local color = c1:Lerp(c2, t)
                
                TweenService:Create(cDisplay, TweenInfo.new(.3, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = color
                }):Play()

                local suc, req = pcall(currentSelectedCP.OnChanged, color)
                assert(suc, req)
            end
        end)
        
        Connections["update_darkness"] = cBrightness.CPDBActivator.MouseButton1Up:Connect(function() 
            if (darknessDragging) then
                darknessDragging = false
            end
        end)          

        Connections["update_darkness_leave"] = cBrightness.CPDBActivator.MouseLeave:Connect(function() 
            if (darknessDragging) then
                darknessDragging = false
            end
        end)          

        local dragging = false

        Connections["update_on_mouse"] = cColors:WaitForChild("CPCActivator").MouseButton1Down:Connect(function() 
            if not (colorPickerShowing) then
                return
            end
            
            dragging = true
            local mouse = UserInputService:GetMouseLocation()
            pcall(UpdateColorChange, mouse.X) 
        end)

        Connections["update_on_mouse_move"] = cColors:WaitForChild("CPCActivator").MouseMoved:Connect(function() 
            if not (colorPickerShowing and dragging) then
                return
            end
            
            local mouse = UserInputService:GetMouseLocation()
            pcall(UpdateColorChange, mouse.X) 
        end)

        Connections["update_on_mouse_leave"] = cColors:WaitForChild("CPCActivator").MouseButton1Up:Connect(function() 
            if not (colorPickerShowing) then
                return
            end
            
            if (dragging) then
                dragging = false
            end
        end)

        Connections["update_on_mouse_leave"] = cColors:WaitForChild("CPCActivator").MouseLeave:Connect(function() 
            if not (colorPickerShowing) then
                return
            end
            
            if (dragging) then
                dragging = false
            end
        end)

        Connections["continue_enter"] = pickerFrame:WaitForChild("CPContinue").MouseEnter:Connect(function()
            TweenService:Create(pickerFrame:WaitForChild("CPContinue").CPCActivator, TweenInfo.new(.2, Enum.EasingStyle.Quad), {
                TextColor3 = Color3.fromRGB(190, 190, 190)
            }):Play()
        end) 

        Connections["continue_leave"] = pickerFrame:WaitForChild("CPContinue").MouseLeave:Connect(function()
            TweenService:Create(pickerFrame:WaitForChild("CPContinue").CPCActivator, TweenInfo.new(.2, Enum.EasingStyle.Quad), {
                TextColor3 = Color3.fromRGB(89, 89, 89)
            }):Play()
        end) 
    
        Connections["continue_color_picker"] = pickerFrame:WaitForChild("CPContinue"):WaitForChild("CPCActivator").MouseButton1Click:Connect(function() 
            colorPickerShowing = false

            currentSelectedCP.Default = cDisplay.BackgroundColor3

            TweenService:Create(GreyOut, info, {
                BackgroundTransparency = 1
            }):Play()

            for _, v in ipairs(pickerFrame:GetDescendants()) do 
                if (v:IsA("Frame")) then TweenService:Create(v, info, { BackgroundTransparency = 1 }):Play() end
                if (v:IsA("TextLabel")) then TweenService:Create(v, info, { TextTransparency = 1 }):Play() end
                if (v:IsA("TextButton")) then TweenService:Create(v, info, { TextTransparency = 1 }):Play() end
                if (v:IsA("ImageLabel")) then TweenService:Create(v, info, { ImageTransparency = 1 }):Play() end
            end

            task.wait(info.DelayTime)

            pickerFrame.Visible = false
            ElementsEnabled = true
        end)
    end

    local TabHandler = {}
    local Tabs = {}

    function TabHandler:BeginTab(TabName) 
        local tabClass = {
            Name = TabName,
            Showing = false,
            TabDisplay = nil,
            TabButton = nil
        }

        local cuh = Navigation.NavigationOptionsContainer.TabButtonDisplay.TBDContainer
        cuh.CanvasSize = UDim2.new(
            cuh.CanvasSize.X.Scale, cuh.CanvasSize.X.Offset + 25,
            0, 0
        )
        
        local tabButton = buttonTemplate:Clone()
        tabButton.Parent = Navigation.NavigationOptionsContainer.TabButtonDisplay.TBDContainer
        tabButton.Visible = true

        tabButton:WaitForChild("TabButtonTitle").Text = TabName

        tabClass.TabButton = tabButton

        local tabDisplay = tabPageTemplate:Clone()
        tabDisplay.Parent = Elements.TabDisplay
        tabDisplay.Name = TabName
        tabDisplay.Visible = false

        local templates = Instance.new("Folder", tabPageTemplate)
        templates.Name = "Templates"

        if (tabDisplay:WaitForChild("TabElementContainer")) then
            for i, v in pairs(tabDisplay:WaitForChild("TabElementContainer"):GetChildren()) do 
                if (v:IsA("Frame")) then
                    v.Visible = false

                    v.Parent = templates
                end
            end
        end

        if (#Tabs == 0) then
            tabClass.Showing = true
            tabDisplay.Visible = true
            currentPage = tabDisplay
            local Text = tabButton:WaitForChild("TabButtonTitle")
            TweenService:Create(Text, info, {
                TextColor3 = ElementProperties.Accent
            }):Play()
        else
            tabClass.Showing = false
            tabDisplay.Visible = false
            currentPage = Tabs[1].TabDisplay
            local Text = tabButton:WaitForChild("TabButtonTitle")
            TweenService:Create(Text, info, {
                TextColor3 = Color3.fromRGB(179, 179, 179)
            }):Play()
        end

        tabClass.TabDisplay = tabDisplay

        local ElementHandler = {}

        local cuh2 = tabDisplay:WaitForChild("TabElementContainer")

        cuh2.CanvasSize = UDim2.new(0, 0, 1, 0)

        function ElementHandler:CreateBoolean(BooleanOptions) 
            local BooleanOptions = BooleanOptions or {
                Name = BooleanOptions.Name,
                Enabled = BooleanOptions.Enabled or false,
                OnChanged = BooleanOptions.OnChanged or function(v) print(v) end
            }

            cuh2.CanvasSize = cuh2.CanvasSize + UDim2.new(0, 0, 0, 50)

            local booleanClass = {
                Update = nil
            }

            local booleanTemplate = nil

            if (templates:WaitForChild("BooleanElement")) then
                booleanTemplate = templates:WaitForChild("BooleanElement")
                booleanTemplate.Visible = false
            end

            local booleanElement = booleanTemplate:Clone()
            booleanElement.Parent = tabDisplay:WaitForChild("TabElementContainer")
            booleanElement.Visible = true

            local booleanTitle = booleanElement:WaitForChild("BETitle")
            booleanTitle.Text = BooleanOptions.Name

            local booleanDisplay = booleanElement:WaitForChild("BEDisplay")
            local booleanIndicator = booleanDisplay:WaitForChild("BEIndicator")

            local Enabled = BooleanOptions.Enabled
            local EnabledColor = ElementProperties.Accent

            local function UpdateBooleanDisplay() 
                if (Enabled) then
                    TweenService:Create(booleanDisplay, info, {
                        ImageColor3 = EnabledColor
                    }):Play()
                    TweenService:Create(booleanIndicator, info, {
                        Position = ElementProperties.Boolean.EnabledPosition
                    }):Play()
                else
                    TweenService:Create(booleanDisplay, info, {
                        ImageColor3 = ElementProperties.Boolean.Disabled
                    }):Play()
                    TweenService:Create(booleanIndicator, info, {
                        Position = ElementProperties.Boolean.DisabledPosition
                    }):Play()
                end
            end

            pcall(UpdateBooleanDisplay)

            local Debounce = false
            local booleanButton = booleanDisplay:FindFirstChild("BEActivator")
            Connections["booleanbegin_c"] = booleanButton.MouseButton1Click:Connect(function()
                if not (ElementsEnabled) then
                    return
                end
                -- print("ok")
                if not (Debounce) then
                    Enabled = not Enabled
                    local suc, req = pcall(BooleanOptions.OnChanged, Enabled)
                    if not (suc) then
                        error(req)
                    end

                    UpdateBooleanDisplay()

                    Debounce = true
                    task.wait(.2)
                    Debounce = false
                end
            end)

            booleanClass.Type = "boolean"
            booleanClass.Update = function(Type, NewValue) 
                if not ((typeof(Type) == "string")) then
                    return
                end 

                if ((Type == "Accent")) then
                    EnabledColor = NewValue

                    if (Enabled) then
                        booleanDisplay.ImageColor3 = EnabledColor
                    end
                end
            end

            table.insert(ElementClasses, booleanClass)
        end

        function ElementHandler:CreateSlider(SliderOptions) 
            local SliderOptions = SliderOptions or {
                Name = SliderOptions.Name,
                Range = SliderOptions.Range or { 0, 100 },
                Default = SliderOptions.Default or { 50 } or 50,
                OnChanged = SliderOptions.OnChanged or function(value) 
                    print(value)
                end
            }

            cuh2.CanvasSize = cuh2.CanvasSize + UDim2.new(0, 0, 0, 50)

            local sliderClass = {
                Update = nil
            }

            local sliderTemplate = nil

            if (templates:WaitForChild("SliderElement")) then
                sliderTemplate = templates.SliderElement
                sliderTemplate.Visible = false
            end

            local sliderElement = sliderTemplate:Clone()
            sliderElement.Parent = tabDisplay.TabElementContainer
            sliderElement.Visible = true

            local sliderTitle = sliderElement.SETitle
            sliderTitle.Text = SliderOptions.Name

            local sliderValue = sliderElement:WaitForChild("SEValue")
            local sliderFillFrame = sliderElement:WaitForChild("SEFillFrame")
            local sliderFill = sliderFillFrame:WaitForChild("SEFill")
            local sliderActivator = sliderFillFrame:WaitForChild("SEActivator")

            local min, max, default = SliderOptions.Range[1], SliderOptions.Range[2], (SliderOptions.Default[1] or SliderOptions.Default)
            local dragging, value = false, default

            local AccentColor = ElementProperties.Accent

            sliderValue.Text = string.format("%.f", tostring(default))
            sliderValue.TextColor3 = AccentColor

            sliderFill.BackgroundColor3 = AccentColor

            default = math.clamp(default, min, max)

            local function UpdateFill() 
                local fillPercent = (value - min) / (max - min)
                sliderValue.Text = string.format("%.f", tostring(value))
                TweenService:Create(sliderFill, TweenInfo.new(.1, Enum.EasingStyle.Quart), {
                    Size = UDim2.new(fillPercent, 0, 1, 0)
                }):Play()
            end

            local function SetValue(newValue) 
                value = math.floor(math.clamp(newValue, min, max))
                pcall(UpdateFill)
                local suc, req = pcall(SliderOptions.OnChanged, value)
                if not (suc) then
                    error(req)
                end
            end

            Connections["sliderbegin_c"] = sliderActivator.MouseButton1Down:Connect(function()
                if not (ElementsEnabled) then
                    return
                end
                
                dragging = true
                local pos = UserInputService:GetMouseLocation()
                if (dragging) then
                    local percent = (pos.X - sliderFillFrame.AbsolutePosition.X) / sliderFillFrame.AbsoluteSize.X
                    local newValue = min + (max - min) * percent
                    pcall(SetValue, newValue)
                end
            end)

            Connections["sliderend_c"] = sliderActivator.MouseButton1Up:Connect(function()
                if not (ElementsEnabled) then
                    return
                end
                
                dragging = false
            end)

            Connections["sliderenc_c2"] = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
                if (input.UserInputType.Name == "MouseButton1") then
                    if (dragging) then
                        dragging = false
                    end
                end
            end)

            Connections["slidermove_c"] = UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
                if not (ElementsEnabled) then
                    return
                end

                if (input.UserInputType == Enum.UserInputType.MouseMovement) then
                    local pos = UserInputService:GetMouseLocation()
                    if (dragging) then
                        local percent = (pos.X - sliderFillFrame.AbsolutePosition.X) / sliderFillFrame.AbsoluteSize.X
                        local newValue = min + (max - min) * percent
                        pcall(SetValue, newValue)
                    end
                end
            end)

            sliderClass.Type = "slider"
            sliderClass.Update = function(Type, NewValue) 
                if not ((typeof(Type) == "string")) then
                    return
                end 

                if ((Type == "Accent")) then
                    AccentColor = NewValue

                    sliderFill.BackgroundColor3 = AccentColor
                    sliderValue.TextColor3 = AccentColor
                end
            end

            pcall(SetValue, newValue)
            table.insert(ElementClasses, sliderClass)
        end

        function ElementHandler:CreateTextField(TextFieldOptions)
            local TextFieldOptions = TextFieldOptions or {
                Name = TextFieldOptions.Name or "Text Field Name",
                Default = TextFieldOptions.Default or "default",
                End = TextFieldOptions.End or "Clip",
                OnChanged = TextFieldOptions.OnChanged or function(text) 
                    print(text)
                end
            }

            cuh2.CanvasSize = cuh2.CanvasSize + UDim2.new(0, 0, 0, 50)

            local textfieldClass = {
                Update = nil
            }

            local textfieldTemplate = nil

            if (templates:WaitForChild("TextElement")) then
                textfieldTemplate = templates.TextElement
                textfieldTemplate.Visible = false
            end

            local textfieldElement = textfieldTemplate:Clone()
            textfieldElement.Parent = tabDisplay.TabElementContainer
            textfieldElement.Visible = true

            local tefTitle = textfieldElement:WaitForChild("TETitle")
            tefTitle.Text = TextFieldOptions.Name

            local AccentColor = ElementProperties.Accent

            local Focused = false
            local tefInput = textfieldElement:WaitForChild("TEField"):WaitForChild("TEFInput")
            local tefStroke = textfieldElement:WaitForChild("TEField"):WaitForChild("TEFStroke")

            tefInput.ClearTextOnFocus = false

            local endType = function() 
                if (TextFieldOptions.End == "Clip") then
                    textfieldElement:WaitForChild("TEField").ClipsDescendants = true
                    textfieldElement:WaitForChild("TEField").TextTruncate = Enum.TextTruncate.None
                elseif (TextFieldOptions.End == "Truncate") then
                    textfieldElement:WaitForChild("TEField").ClipsDescendants = false
                    textfieldElement:WaitForChild("TEField").TextTruncate = Enum.TextTruncate.AtEnd
                end
            end

            tefInput.Active = ElementsEnabled

            pcall(endType)

            Connections["tef_began"] = tefInput.Focused:Connect(function()
                if not (ElementsEnabled) then
                    return
                end

                Focused = true
                TweenService:Create(tefStroke, info, {
                    Color = AccentColor
                }):Play()
            end)

            Connections["tef_lose"] = tefInput.FocusLost:Connect(function(enterPressed)
                if not (ElementsEnabled) then
                    return
                end
                
                Focused = false
                TweenService:Create(tefStroke, info, {
                    Color = Color3.fromRGB(26, 26, 26)
                }):Play()

                if (enterPressed) then
                    local suc, req = pcall(TextFieldOptions.OnChanged, tefInput.Text)
                    if not (suc) then
                        error(req)
                    end
                end
            end)

            textfieldClass.Type = "textfield"
            textfieldClass.Update = function(Type, NewValue) 
                if not ((typeof(Type) == "string")) then
                    return
                end 

                if ((Type == "Accent")) then
                    AccentColor = NewValue

                    if (Focused) then
                        tefStroke.Color = AccentColor
                    end
                end
            end
            
            table.insert(ElementClasses, textfieldClass)
        end

        function ElementHandler:CreateDropdown(DropdownOptions) 
            local DropdownOptions = DropdownOptions or {
                Name = DropdownOptions.Name or "Dropdown",
                Options = DropdownOptions.Options or { "1", "2", "3" },
                Default = DropdownOptions.Default or { "1" } or "1",
                OnChanged = DropdownOptions.OnChanged or function(option) 
                    print(option)
                end
            }

            cuh2.CanvasSize = cuh2.CanvasSize + UDim2.new(0, 0, 0, 50)

            local dropdownClass = {
                Update = nil
            }

            local dropdownTemplate = nil

            if (templates:WaitForChild("ComboElement")) then
                dropdownTemplate = templates.ComboElement
                dropdownTemplate.Visible = false
            end
            
            local dropdownElement = dropdownTemplate:Clone()
            dropdownElement.Parent = tabDisplay.TabElementContainer
            dropdownElement.Visible = true

            local ddTitle = dropdownElement["CETitle"]
            ddTitle.Text = DropdownOptions.Name

            local ddSelectedOption = dropdownElement["CEContainer"]["CESelectedOption"]
            local ddActivator = ddSelectedOption["CESOActivator"]
            local ddState = ddSelectedOption["CESOState"]

            local AccentColor = ElementProperties.Accent

            local ddOptionSize = 8
            local ddOptionOffset = 0
            local ddOptionsContainer = dropdownElement["CEOptions"]
            ddOptionsContainer.Position = UDim2.new(1, 300, 0, 75)
            ddOptionsContainer.Size = UDim2.new(0, 215, 0, ddOptionSize)
            ddOptionsContainer["CEOption"].Visible = false

            if (table.find(DropdownOptions.Options, DropdownOptions.Default[1]) or table.find(DropdownOptions.Options, DropdownOptions.Default)) then
                ddSelectedOption.Text = DropdownOptions.Default[1] or DropdownOptions.Default
            end

            local ddOptionTemplate = ddOptionsContainer["CEOption"]

            local Selected = DropdownOptions.Default[1] or DropdownOptions.Default
            local DropdownOpen = false

            local function UpdateContainerSize() 
                TweenService:Create(ddOptionsContainer, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 215, 0, ddOptionSize)
                }):Play()
            end

            local function UpdateDropdown() 
                if (DropdownOpen) then
                    TweenService:Create(ddState, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Rotation = 180
                    }):Play()
                    TweenService:Create(ddOptionsContainer, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = UDim2.new(1, -6, 0, 75)
                    }):Play()
                else
                    TweenService:Create(ddState, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Rotation = 0
                    }):Play()
                    TweenService:Create(ddOptionsContainer, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = UDim2.new(1, 300, 0, 75)
                    }):Play()
                end
            end

            pcall(UpdateDropdown)

            local Debounce = false
            Connections["dd_activate"] = ddActivator.MouseButton1Click:Connect(function() 
                if (not Debounce) then
                    DropdownOpen = not DropdownOpen
                    pcall(UpdateDropdown)

                    Debounce = true
                    task.wait(.1)
                    Debounce = false
                end
            end)

            coroutine.wrap(function() 
                for i, option in ipairs(DropdownOptions.Options) do 
                    local newOption = ddOptionTemplate:Clone()
                    newOption.Parent = ddOptionsContainer
                    newOption.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                    newOption.Position = UDim2.new(0, 0, 0, ddOptionOffset)
                    newOption.Visible = true

                    newOption.Text = option

                    Connections["mouse_enter_ddoption" .. tostring(i)] = newOption.MouseEnter:Connect(function() 
                        TweenService:Create(newOption, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                        }):Play()
                    end)

                    Connections["mouse_leave_ddoption" .. tostring(i)] = newOption.MouseLeave:Connect(function() 
                        TweenService:Create(newOption, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                        }):Play()
                    end)

                    Connections["mouse_click_ddoption" .. tostring(i)] = newOption["CEOActivator"].MouseButton1Click:Connect(function()
                        ddSelectedOption.Text = option
                        Selected = option
                        
                        for i, v in ipairs(ddOptionsContainer:GetChildren()) do 
                            if v:IsA("TextLabel") then
                                local optionText = v.Text
                                local optionImage = v:WaitForChild("CEOImage")
                                if optionText == Selected then
                                    TweenService:Create(optionImage, TweenInfo.new(.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                        ImageTransparency = 0
                                    }):Play()
                                else
                                    TweenService:Create(optionImage, TweenInfo.new(.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                        ImageTransparency = 1
                                    }):Play()
                                end
                            end
                        end                        

                        local suc, req = pcall(DropdownOptions.OnChanged, option)
                        assert(suc, req)
                    end)

                    ddOptionOffset += 20
                    ddOptionSize += 20
                    pcall(UpdateContainerSize)
                end

                local defaultOption = DropdownOptions.Default[1] or DropdownOptions.Default

                for i, v in ipairs(ddOptionsContainer:GetChildren()) do 
                    if (v:IsA("TextLabel")) then
                        local opt = v.Text
                        local optImage = v:WaitForChild("CEOImage")
                        local isDef = opt == defaultOption

                        if (isDef) then
                            TweenService:Create(v:WaitForChild("CEOImage"), TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                ImageTransparency = 0
                            }):Play()
                        else
                            TweenService:Create(v:WaitForChild("CEOImage"), TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                ImageTransparency = 1
                            }):Play()
                        end
                    end
                end
            end)()
            
            dropdownClass.Type = "dropdown"
            dropdownClass.Update = function(Type, NewValue) 
                if not ((typeof(Type) == "string")) then
                    return
                end 

                if ((Type == "Accent")) then
                    AccentColor = NewValue

                    for i, v in ipairs(ddOptionsContainer:GetChildren()) do 
                        if (v:IsA("TextLabel")) then
                            v:WaitForChild("CEOImage").ImageColor3 = AccentColor
                        end
                    end
                end
            end

            table.insert(ElementClasses, dropdownClass)
        end

        function ElementHandler:CreateColorPicker(ColorPickerOptions) 
            local ColorPickerOptions = ColorPickerOptions or {
                Name = ColorPickerOptions.Name or "Color Picker",
                Default = ColorPickerOptions.Default or ElementProperties.Accent,
                OnChanged = ColorPickerOptions.OnChanged or function(color) 
                    print(color.R, color.G, color.B)
                end
            }

            cuh2.CanvasSize = cuh2.CanvasSize + UDim2.new(0, 0, 0, 50)

            local colorpTemplate = nil

            if (templates:WaitForChild("ColorElement")) then
                colorpTemplate = templates.ColorElement
                colorpTemplate.Visible = false
            end

            local colorElement = colorpTemplate:Clone()
            colorElement.Parent = tabDisplay.TabElementContainer
            colorElement.Visible = true

            local colorTitle = colorElement:WaitForChild("CETitle")
            colorTitle.Text = ColorPickerOptions.Name

            Connections["ColorExpand"]  = colorElement:WaitForChild("CEExpand"):WaitForChild("arrow_forward").MouseButton1Click:Connect(function()
                if not (ElementsEnabled) then
                    return
                end
                
                currentSelectedCP = ColorPickerOptions
                colorPickerShowing = true
                pickerFrame.Visible = true
                ElementsEnabled = false

                TweenService:Create(GreyOut, info, {
                    BackgroundTransparency = 0.65
                }):Play()

                for _, v in ipairs(pickerFrame:GetDescendants()) do 
                    if (v:IsA("Frame") and v.Name ~= "CPSHolder" and v.Name ~= "CPPanel") then TweenService:Create(v, info, { BackgroundTransparency = 0 }):Play() end
                    if (v:IsA("TextLabel")) then TweenService:Create(v, info, { TextTransparency = 0 }):Play() end
                    if (v:IsA("TextButton")) then TweenService:Create(v, info, { TextTransparency = 0 }):Play() end
                    if (v:IsA("ImageLabel")) then TweenService:Create(v, info, { ImageTransparency = 0.12 }):Play() end
                end
                
                task.wait(.1)

                TweenService:Create(colorElement:WaitForChild("CEExpand"):WaitForChild("arrow_forward"), info, {
                    Position = UDim2.new(0.5, 0, 0.5, 0), ImageColor3 = Color3.fromRGB(65, 65, 65)
                }):Play()
            end)

            Connections["ColorEnter"] = colorElement:WaitForChild("CEExpand"):WaitForChild("arrow_forward").MouseEnter:Connect(function()
                if not (ElementsEnabled) then
                    return
                end
                
                TweenService:Create(colorElement:WaitForChild("CEExpand"):WaitForChild("arrow_forward"), info, {
                    Position = UDim2.new(0.5, 4, 0.5, 0), ImageColor3 = Color3.fromRGB(97, 97, 97)
                }):Play()
            end)

            Connections["ColorLeave"] = colorElement:WaitForChild("CEExpand"):WaitForChild("arrow_forward").MouseLeave:Connect(function()
                if not (ElementsEnabled) then
                    return
                end
                
                TweenService:Create(colorElement:WaitForChild("CEExpand"):WaitForChild("arrow_forward"), info, {
                    Position = UDim2.new(0.5, 0, 0.5, 0), ImageColor3 = Color3.fromRGB(65, 65, 65)
                }):Play()
            end)
        end

        tabButton.MouseEnter:Connect(function()
            if (tabButton:WaitForChild("TabButtonTitle")) and not tabClass.Showing and ContainerOpen then
                local Text = tabButton:WaitForChild("TabButtonTitle")
                TweenService:Create(Text, info, {
                    TextColor3 = TextHoverColor
                }):Play()
            end
        end)

        tabButton.MouseLeave:Connect(function()
            if (tabButton:WaitForChild("TabButtonTitle")) and not tabClass.Showing and ContainerOpen then
                local Text = tabButton:WaitForChild("TabButtonTitle")
                TweenService:Create(Text, info, {
                    TextColor3 = Color3.fromRGB(179, 179, 179)
                }):Play()
            end
        end)

        tabButton.TabButtonActivator.MouseButton1Click:Connect(function()
            if not (tabClass.Showing) and ContainerOpen then
                tabClass.Showing = true
                tabDisplay.Visible = true
                currentPage = tabDisplay
                local Text = tabButton:WaitForChild("TabButtonTitle")
                TweenService:Create(Text, info, {
                    TextColor3 = ElementProperties.Accent
                }):Play()

                for _, v in pairs(Tabs) do 
                    if v ~= tabClass and v.Showing then
                        v.Showing = false
                        v.TabDisplay.Visible = false
                        TweenService:Create(v.TabButton:WaitForChild("TabButtonTitle"), info, {
                            TextColor3 = Color3.fromRGB(179, 179, 179)
                        }):Play()
                    end
                end
            end
        end)

        table.insert(Tabs, tabClass)
        return ElementHandler
    end

    coroutine.wrap(function() 
        local dragging = false
        local dragInput, dragStart, startPos = nil, nil, nil

        local function UpdateDrag(input)
            local delta = input.Position - dragStart
            local newPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)

            local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(Window, tweenInfo, { Position = newPosition }):Play()
        end

        Connections["drag_start"] = Navigation.InputBegan:Connect(function(input) 
            if (input.UserInputType == Enum.UserInputType.MouseButton1) then
                dragging, dragStart, startPos = true, input.Position, Window.Position

                input.Changed:Connect(function()
                    if (input.UserInputState == Enum.UserInputState.End) then
                        dragging = false
                    end
                end)
            end
        end)

        Connections["drag_move"] = Navigation.InputChanged:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseMovement) then
                dragInput = input
            end
        end)

        Connections["drag_update"] = UserInputService.InputChanged:Connect(function(input)
            if (input == dragInput and dragging) then
                pcall(UpdateDrag, input)
            end
        end)
    end)()

    task.defer(function()
        

        local RainbowAccent = false
        local Settings = TabHandler:BeginTab("Settings")

        local rainbowThread = nil

        local rainbowThread = nil

        Settings:CreateBoolean({
            Name = "Rainbow Accent",
            Default = false,
            OnChanged = function(value)
                RainbowAccent = value
                local hue = 0
                local saturation = 1
                local lightness = 0.5
                local step = 0.01

                if value then
                    rainbowThread = RunService.Heartbeat:Connect(function()
                        if value then
                            hue = hue + step
                            if hue > 1 then
                                hue = 0
                            end

                            local function hueToRgb(p, q, t)
                                if t < 0 then
                                    t = t + 1
                                end
                                if t > 1 then
                                    t = t - 1
                                end
                                if t < 1 / 6 then
                                    return p + (q - p) * 6 * t
                                end
                                if t < 1 / 2 then
                                    return q
                                end
                                if t < 2 / 3 then
                                    return p + (q - p) * (2 / 3 - t) * 6
                                end
                                return p
                            end

                            local function hslToRgb(h, s, l)
                                local r, g, b

                                if s == 0 then
                                    r, g, b = l, l, l
                                else
                                    local q = l < 0.5 and l * (1 + s) or l + s - l * s
                                    local p = 2 * l - q
                                    r = hueToRgb(p, q, h + 1 / 3)
                                    g = hueToRgb(p, q, h)
                                    b = hueToRgb(p, q, h - 1 / 3)
                                end

                                return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
                            end

                            local rainbowColor = Color3.fromRGB(hslToRgb(hue, saturation, lightness))

                            for _, k in ipairs(ElementClasses) do
                                k.Update("Accent", rainbowColor)
                            end

                            task.wait(.01)
                        end
                    end)
                else
                    if rainbowThread then
                        rainbowThread:Disconnect()
                    end
                end
            end
        })


        Settings:CreateColorPicker({ Name = "Accent Color", Default = ElementProperties.Accent, OnChanged = function(color) 
            if not (RainbowAccent) then
                ElementProperties.Accent = color

                for i, k in ipairs(ElementClasses) do 
                    k.Update("Accent", color)
                end
            end
        end })

        Settings:CreateColorPicker({ Name = "Text Hover Color", Default = ElementProperties.Accent, OnChanged = function(color) 
            if not (RainbowAccent) then
                TextHoverColor = color
            end
        end })
    end)

    return TabHandler
end

return Interface
