local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")



local menu_watcher =
    sbar.add(
        "item",
        {
            drawing = false,
            updates = false
        }
    )
local space_menu_swap =
    sbar.add(
        "item",
        {
            drawing = false,
            updates = true
        }
    )
sbar.add("event", "swap_menus_and_spaces")

local max_items = 15
local menu_items = {}
for i = 1, max_items, 1 do
    local menu =
        sbar.add(
            "item",
            "menu." .. i,
            {
                drawing = false,
                icon = {
                    drawing = false
                },
                background = {
                    drawing = false
                },
                label = {
                    padding_left = 5,
                    padding_right = 5,
                    color = (i == 1 and colors.dolphin_grey or colors.bar.foreground),
                    font = {
                        size = 12,
                        style = settings.font.style_map[i == 1 and "Bold" or "Regular"]
                    }
                },
                click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s " .. i
            }
        )

    menu_items[i] = menu
end

sbar.add(
    "bracket",
    { "/menu\\..*/" },
    {
        background = {
            alpha = 0,
            color = colors.bar.bg
        }
    }
)

local menu =
    sbar.add(
        "item",
        "menu.padding",
        {
            drawing = false
        }
    )

local function update_menus(env)
    sbar.exec(
        "$CONFIG_DIR/helpers/menus/bin/menus -l",
        function(menus)
            sbar.set(
                "/menu\\..*/",
                {
                    drawing = false
                }
            )
            menu:set(
                {
                    drawing = true
                }
            )
            local id = 1
            for menu in string.gmatch(menus, "[^\r\n]+") do
                if id < max_items then
                    menu_items[id]:set(
                        {
                            label = menu,
                            drawing = true
                        }
                    )
                else
                    break
                end
                id = id + 1
            end
        end
    )
end

menu_watcher:subscribe("front_app_switched", update_menus)

space_menu_swap:subscribe(
    "swap_menus_and_spaces",
    function(env)
        local drawing = menu_items[1]:query().geometry.drawing == "on"

        if drawing then
            menu_watcher:set(
                {
                    updates = false
                }
            )
            sbar.set(
                "/apple\\..*/",
                {
                    drawing = true
                }
            )

            sbar.set(
                "/menu\\..*/",
                {
                    drawing = false
                }
            )
            sbar.set(
                "/space\\..*/",
                {
                    drawing = true
                }
            )
            sbar.set(
                "/add_space\\..*/",
                {
                    drawing = true
                }
            )
        else
            menu_watcher:set(
                {
                    updates = true
                }
            )
            sbar.set(
                "/apple\\..*/",
                {
                    drawing = true
                }
            )

            sbar.set(
                "/space\\..*/",
                {
                    drawing = false
                }
            )
            sbar.set(
                "/add_space\\..*/",
                {
                    drawing = false
                }
            )

            update_menus()
        end
    end
)



return menu_watcher