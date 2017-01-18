
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

--[[
local disp
function init_OLED() --Set up the u8glib lib
     spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8, 0)
     disp = u8g.ssd1306_128x64_hw_spi(8, 1, 2)  -- SCL->D5 SDA->D7 CS->D8 D/C->D1 RST->D2
     disp:setFont(u8g.font_6x10)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
end
init_OLED() --Run setting up
]]

gpio.mode(3, gpio.INT)    -- 开始制作输入

function stopmake()
    contup = false
    gpio.trig(3,"down",startmake)     -- start make coffee
end

cont1 = 0

function startmake()
    cont1 = 0
    contup = true
    gpio.trig(3,"high",stopmake)     -- stop make coffee
end
gpio.trig(3,"down",startmake)     -- start make coffee

T1 = 0
tmr.alarm(1, 1000, tmr.ALARM_AUTO, function()
         t=require("ds18b20")
         t.setup(4)         -- DS18B20 concet to D4 pin
         addrs=t.addrs()
         T1 = t.read(nil,t.C)
         t = nil
         ds18b20 = nil
         package.loaded["ds18b20"]=nil

         if T1 < 12 then
            gpio.write(0, gpio.HIGH)     -- Heater ON
            heaton = true
         elseif T1 > 12.5 then
            gpio.write(0, gpio.LOW)     -- Heater OFF
            heaton = false
         end
                   
         tm = rtctime.epoch2cal(rtctime.get())
         if contup  then
            cont1 = cont1 + 1
         end

         disp:firstPage()
         repeat
         disp:setFont(u8g.font_6x10) 
         disp:drawStr(0,7,string.format("%04d/%02d/%02d", tm["year"], tm["mon"], tm["day"]))
         disp:drawStr(80,7,string.format("%02d.%02d.%02d", tm["hour"], tm["min"], tm["sec"]))
         disp:drawLine(0, 9, 127, 9)
         disp:drawLine(93, 9, 93, 31)
         disp:drawCircle(85, 15, 2)        
         disp:setFont(u8g.font_profont29)
         disp:drawStr(0,32,string.format("%5.1f",T1))
         disp:drawStr(98,32,string.format("%2d",cont1))
         if heaton then
            disp:drawTriangle(85,21, 89,32, 81,32)
         end
         until disp:nextPage() == false
         end
)
