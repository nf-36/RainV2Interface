# Documentation

## Initiating the interface / library.
```lua
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Iujan/RainV2Interface/main/Interface.lua", true))()
```

## Initiating the Window.
```lua
local window = library:BeginMenu({ Title = "Title" }); --> Options[1] = Title (Only one option needed, set to default if not passed)
```

## Creating a Tab
```lua
local tab = window:BeginTab("Tab 1")
```

## Creating a Toggle / Switch.
* `Name`      = Name of the element.  `string`
* `Default`   = Default value of the element. `boolean`
* `OnChanged` = Callback / Listener of the element. Will be called whenever the element is changed. `function -> value`

```lua
local toggle = tab:CreateBoolean({
    Name = "Toggle",
    Default = false,
    OnChanged = function(value) 
        print(value)
    end
})
```

## Creating a Slider.
* `Name`      = Name of the element.  `string`
* `Default`   = Default value of the element. `table | number`
* `Range`     = Range values of the element.  `table`
* `OnChanged` = Callback / Listener of the element. Will be called whenever the element is changed. `function -> value` 

```lua
local slider = tab:CreateSlider({
    Name = "Slider",
    Range = { 1, 100 },
    Default = { 50 },
    OnChanged = function(value) 
        print(value)
    end
})
```

## Creating a Text Field / Input.
* `Name`      = Name of the element.  `string`
* `Default`   = Default text of the element. `string`
* `End`       = Ending type of the text box. `string` -> `Clips` -> `Truncate`
* `OnChanged` = Callback / Listener of the element. Will be called whenever the element is changed. `function -> text` 

```lua
local text = tab:CreateTextField({
    Name = "Text",
    Default = "default",
    Ends = "Clips",
    OnChanged = function(text) 
        print(text)
    end
})
```

## Creating a Dropdown / Combo.
* `Name`      = Name of the element.  `string`
* `Default`   = Default text of the element. `table | string`
* `Options`   = Options to render in the dropdown. `table`
* `OnChanged` = Callback / Listener of the element. Will be called whenever the element is changed. `function -> option` 

```lua
local dropdown = tab:CreateDropdown({
    Name = "Dropdown",
    Options = { "1", "2", "3", "4" },
    Default = { "2" },
    OnChanged = function(option) 
        print(option)
    end
})
```

## Creating a ColorPicker.
* `Name`      = Name of the element.  `string`
* `Default`   = Default text of the element. `Color3`
* `OnChanged` = Callback / Listener of the element. Will be called whenever the element is changed. `function -> color` 

```lua
local colorpicker = tab:CreateColorPicker({
    Name = "Color Picker",
    Default = Color3.fromRGB(255, 255, 255),
    OnChanged = function(color) 
        print(color)
    end
})
```
