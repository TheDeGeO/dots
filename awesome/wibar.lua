local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local calendar_popup = require("awful.widget.calendar_popup")
local gears = require("gears")
-- {{{ Wibar

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
mytextclock = wibox.widget{
  format = "󰥔 %I:%M %p",
  font = beautiful.clock_font,
  widget = wibox.widget.textclock
}

-- Create a properly centered textclock widget
local centered_clock = wibox.widget {
    nil,
    {
        mytextclock,
        valign = "center",
        halign = "center",
        widget = wibox.container.place
    },
    nil,
    expand = "none",
    layout = wibox.layout.align.horizontal
}

-- Create a calendar widget
local month_calendar = calendar_popup.month({
    start_sunday = false,
    week_numbers = true,
    style_month = beautiful.calendar_style_month,
    style_header = beautiful.calendar_style_header,
    style_weekday = beautiful.calendar_style_weekday,
    style_normal = beautiful.calendar_style_normal,
    style_focus = beautiful.calendar_style_focus,
})

-- Attach the calendar to the textclock widget
month_calendar:attach(mytextclock, "tc", { on_hover = true })

-- create music button textbox
local music_button = wibox.widget{
    widget = wibox.widget.textbox,
    text = " " .. io.popen("playerctl --player=spotify metadata title 2>/dev/null || echo 'No music playing'"):read("*all"),
    buttons = {
        awful.button({}, 1, function()
            awful.spawn("playerctl play-pause")
        end)
    }
}

-- Update music text every second
gears.timer {
    timeout = 1,
    call_now = true,
    autostart = true,
    callback = function()
        music_button.text = " " .. io.popen("playerctl --player=spotify metadata title 2>/dev/null || echo 'No music playing'"):read("*all")
    end
}

-- create music widget with cover art, song name, artist, album and play button
local music_widget = wibox.widget{
    
}


screen.connect_signal("request::desktop_decoration", function(s)
    -- Each screen has its own tag table.
    awful.tag(beautiful.tagstrings, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox {
        screen  = s,
        buttons = {
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc(-1) end),
            awful.button({ }, 5, function () awful.layout.inc( 1) end),
        }
    }
    s.mylayoutboxm = wibox.widget{
        s.mylayoutbox,
        widget = wibox.container.margin,
        margins = 3
    }

    -- Create a taglist widget
    local taglist_buttons = {
        awful.button({ }, 1, function(t) t:view_only() end),
        awful.button({ modkey }, 1, function(t)
                                        if client.focus then
                                            client.focus:move_to_tag(t)
                                        end
                                    end),
        awful.button({ }, 3, awful.tag.viewtoggle),
        awful.button({ modkey }, 3, function(t)
                                        if client.focus then
                                            client.focus:toggle_tag(t)
                                        end
                                    end),
        awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
        awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
    }

    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
        layout = {
            layout = wibox.layout.fixed.horizontal,
            spacing = 5,
        }
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({ }, 1, function (c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),
            awful.button({ }, 3, function() awful.menu.client_list { theme = { width = 250 } } end),
            awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
            awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
        }
    }



    -- Create a single wibar with centered clock
    s.mywibox = awful.wibar {
        position = "top",
        screen = s,
        widget = {
            widget = wibox.container.margin,
            margins = {
                top = 0,
                bottom = 0,
                left = 6,
                right = 6
            },
            {
                layout = wibox.layout.stack,
                -- Bottom layer (for left and right widgets)
                {
                    layout = wibox.layout.align.horizontal,
                    { -- Left widgets
                        layout = wibox.layout.fixed.horizontal,
                        s.mytaglist,
                        s.mypromptbox,
                    },
                    nil, -- No middle widget in the bottom layer
                    { -- Right widgets
                        layout = wibox.layout.fixed.horizontal,
                        music_button,
                        wibox.widget.systray(),
                        mykeyboardlayout,
                        s.mylayoutboxm,
                    },
                },
                -- Top layer (for centered clock)
                centered_clock
            }
        },
        margins = {
            top = beautiful.useless_gap,
            bottom = 0,
            left = beautiful.useless_gap * 2,
            right = beautiful.useless_gap * 2,
        },
        
    }
end)

-- }}}
