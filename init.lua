-- Copyright (c) 2016 dy008
-- https://github.com/dy008/NodeMcuForLEWEI50Test
--

gpio.write(0, gpio.HIGH)    -- LED OFF
gpio.mode(0, gpio.OUTPUT)

local disp 
function init_OLED(sda,scl) --Set up the u8glib lib
     sla = 0x3c
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g.ssd1306_128x32_i2c(sla)
     disp:setFont(u8g.font_6x10)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
end
init_OLED(7,6) -- SDA->D7 SCL->D6

disp:firstPage()
repeat
disp:drawFrame(0,0,127,32) 
disp:drawStr(10,10,"Coffee Temp Contrl") 
disp:drawStr(40,20,"TK-1819A")
disp:drawStr(31,30,"MAKE BY DY008") 
until disp:nextPage() == false 

enduser_setup.start(
  function()
    print("Connected to wifi as:" .. wifi.sta.getip())
    print("Let's Go...")
    sntp.sync('1.pool.ntp.org',
        function(sec, usec, server, info)
        rtctime.set(sec+28800, usec)
        print('sync', sec, usec, server)
        end,
        
        function()
        print('failed!')
        end,
        autorepeat
    )    
  end,
  function(err, str)
    print("enduser_setup: Err #" .. err .. ": " .. str)
    node.restart()
  end
)

dofile("run.lua")


--[[
wifi.setmode(wifi.STATION)
wifi.sta.config("KmhlsGroup","kmhls8214658")
wifi.sta.connect()

cnt = 0
tmr.alarm(1, 1000, 1, function()
    if (wifi.sta.getip() == nil) and (cnt < 10) then
        print(".")
        cnt = cnt + 1
    else
        tmr.stop(1)
        if (cnt < 10) then
            print("IP:"..wifi.sta.getip())
            sntp.sync('1.pool.ntp.org',
                function(sec, usec, server, info)
                    rtctime.set(sec+28800, usec)
                    print('sync', sec, usec, server)
                end,
        
                function()
                print('failed!')
                end,
                autorepeat)
            dofile("run.lua")
        else
            node.restart()
        end
    end
end)
--]]

