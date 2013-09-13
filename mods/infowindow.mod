print("Loading infowindow Mod ok!")
--[[
 local w=window.new() --监控窗体
    w.name="status_window"
	w.height=480,
	w.width=240,
    w:addText("label1","目前工作:长乐帮")
	w:addText("label2","目前过程:询问job")
    w:refresh()
	-----http://tool.chinaz.com/Tools/OnlineColor.aspx     ----在线调色板工具
--]]


--定义窗口名字
require "movewindow"  -- pull in this module
window={
  new=function()
    local w={}
	w.items={}
	setmetatable(w,{__index=window})
	return w
  end,
  name="myStatusWin",
  background_colour = 0x909090,
  FRAME_BACKGROUND=ColourNameToRGB("#DDDDDD"),
  CIRCLEFRAME_BACKGROUND=ColourNameToRGB("#000000"),
  TEXT_COLOR==ColourNameToRGB("#00FFFF"),
  WINDOW_BORDER=ColourNameToRGB("#FFFFFF"),
  TITLE="pkuxkx信息窗口",
  TITLE_HEIGHT=15,
  height=480,
  width=240,

  --定义状态条的属性
  gauge_left = 10,
  gauge_height = 13,
  gauge_right = 200,
  box_colour = 0xD3D3D3,
  --定义显示用的字体属性
  font_id = "myFont",
  font_name = "宋体",
  font_height = 20,
  font_size = 12,
  vertical = 8,
  items={},
}

local varlist=GetVariableList()
local windows = WindowList()

if windows then
	for _, P_win in ipairs (windows) do
	local tm_mw="mw_"..P_win.."_infoWindow"
		for k,v in pairs(varlist) do
			if k==string.lower(tm_mw) then
				WindowDelete(P_win)  -- delete it
				DeleteVariable(tm_mw)
			end
		end
	end
end
--============================================
--Funtions
--============================================

function window:init(height,width,refresh)
    local win=self.name
	SetVariable("mw_"..win.."_infoWindow",1)
 -- print("初始化状态窗口->"..self.name)
  local windows = WindowList()
  local exist=false
  if windows then
   for _, v in ipairs (windows) do
     if v==win then
	   exist=true
	 end
   end
  end -- if any
 if height==nil then height=self.height end
 if width==nil then width=self.width end
 --------------2012.01.28.1607
	local mu=function(flags, hotspot_id) self:MouseUp(flags, hotspot_id) end
	local lc=function(flags, hotspot_id,win) self:LeftClickOnly(flags, hotspot_id,win) end

	local windowinfo  = movewindow.install(win, miniwin.pos_top_right,0,true, nil, {mouseup=mu, mousedown=lc, dragmove=lc, dragrelease=lc})
	--------------2012.01.28.1607

		if exist==false or refresh==true then
       print("创建窗体!!")
	   ----print(windowinfo.window_left,windowinfo.window_top,width,height,windowinfo.window_mode,windowinfo.window_flags)

		WindowCreate(win,0,0,width,height,6,4,self.FRAME_BACKGROUND)
    else
		if WindowInfo(win,5)==false then  --窗体不显示状态
          return
        end
	end

 -- print("初始化字体 "..self.font_name)
	 check(WindowFont (win, self.font_id, self.font_name, self.font_size, false, false, false, false))
	 WindowRectOp (win, miniwin.rect_fill, 0,0,width,height, ColourNameToRGB("#FFFFFF"))  -- raised, filled, softer, flat

		----[[Frame]]-----圆角的框架Start
		WindowCircleOp (win,

				miniwin.circle_round_rectangle, -- round rectangle
                2, 2, width-2 , height-2 ,	 -- Left, Top, Right, Bottom
                ColourNameToRGB("#FFFFFF"), miniwin.pen_solid, 1.5,   -- pen width 2
                self.CIRCLEFRAME_BACKGROUND, miniwin.brush_solid,  -- brush
                10,   -- width of the ellipse used to draw the rounded corner
                10)   -- height of the ellipse used to draw the rounded corner
		----[[Frame]]-----圆角的框架End
	movewindow.add_drag_handler (win, 0, 0, 0, 0, 10)  -- both-ways arrow cursor (10)
	 WindowShow (win,true)  -- show it
end


function window:LeftClickOnly(flags, hotspot_id, win)
   if bit.band (flags, miniwin.hotspot_got_rh_mouse) ~= 0 then
      return true
   end
   return false
end
function window:MouseUp(flags, hotspot_id)
   if bit.band (flags, miniwin.hotspot_got_rh_mouse) ~= 0 then
      self:right_click_menu(hotspot_id)
   else
      self:refresh()
   end
   keepscrolling = ""
   return true
end
function window:right_click_menu(hotspot_id)
	local win=self.name
	local result = WindowMenu(win,WindowInfo (win, 14),WindowInfo (win, 15),"^北大侠客行Info|-|隐藏|-|默认设置|300*500|400*700|600*900")
	   print(result)
      if result ~= "" then
	     if result=="隐藏" then
	       --print("hide")
	       WindowShow(win,false)
		   return
		elseif result=="默认设置" then
		    self:init(self.height,self.width,true)
		elseif result=="300*500" then
		    self:init(300,500,true)
		elseif result=="400*700" then
		    self:init(400,700,true)
		elseif result=="600*900" then
			self:init(600,900,true)
        end
		 self:refresh()
	   end
  end
--画状态条方法
--sPrompt 状态条前显示的字
--Percent 状态百分比
--sGoodColor 正常时候的颜色
--sMediumColor 当状态小于50%的时候的颜色
--sBadColor 当状态小于30%的时候的颜色
--sText 显示在状态条内的文字
--bTextOnly 当参数等于1的时候不做颜色的填充
function window:DoGauge (sPrompt, Percent, sGoodColor, sMediumColor, sBadColor, sText, bTextOnly)

  --画框架
  self:drawFrame(sPrompt)

  --当bTextOnly不等于1的时候画状态条
  if ( bTextOnly ~= 1 ) then
    --画状态条
    self:drawGauge(sPrompt, Percent, sGoodColor, sMediumColor, sBadColor)
  end

  --如果sText存在则显示sText
  self:drawText(sText,self.TEXT_COLOR)

  --计算下一个状态条的位置
  self.vertical = self.vertical + self.font_height
end -- function


--画框框的方法
function window:drawFrame(sPrompt)
  if (sPrompt~= nil) then
    local width = WindowTextWidth (self.name, self.font_id, sPrompt)

    WindowText (self.name, self.font_id, sPrompt, self.gauge_left - width + 5, self.vertical, 0, 0, 0x000000)

    -- frame rectangle
    WindowRectOp (self.name, 1,
            self.gauge_left+5, self.vertical,
            self.gauge_right, self.vertical + self.gauge_height,
            self.box_colour)
  end
end

--画状态条
function window:drawGauge(sPrompt, Percent, sGoodColor, sMediumColor, sBadColor)
    local colour
    --  Below 30% warn by sBadColor
    --  Below 50% warn by sMediumColor
    Percent = tonumber (Percent)
    if Percent <= 20 then
      colour = sBadColor
    elseif Percent <= 50 then
      colour = sMediumColor
    else
      colour = sGoodColor
    end -- if

    local pixels = (self.gauge_right - self.gauge_left - 1) * Percent / 100

    -- fill rectangle
    WindowRectOp (self.name, 2,
            self.gauge_left + 6, self.vertical + 1,
            self.gauge_left + pixels, self.vertical + self.gauge_height - 1,
            ColourNameToRGB (colour))
end

--显示文字
function window:drawText(sText,color)
    if color==nil then color= ColourNameToRGB ("#00FFFF") end
	if sText ~= nil then
      WindowText (self.name, self.font_id, sText, self.gauge_left, self.vertical, 0, 0, ColourNameToRGB (color))
	   --计算下一个状态条的位置
      self.vertical = self.vertical + self.font_height
    end
	Redraw()
end

--计算各类数值并在窗口中刷新状态条
function window:draw_bar ()
  --[[
  check (WindowRectOp (self.name, 2, 0, 0, 0, 0, self.background_colour))

  -- 画边框
  check (WindowRectOp (self.name, 5, 0, 0, 0, 0, 10, 15))
--]]
----[[Frame]]-----圆角的框架Start
		check(WindowCircleOp (self.name,

				3, -- round rectangle
                2, 2, self.width-2 , self.height-2 ,	 -- Left, Top, Right, Bottom
                self.CIRCLEFRAME_BACKGROUND, miniwin.pen_solid, 1.5,   -- pen width 2
                self.CIRCLEFRAME_BACKGROUND, miniwin.brush_solid,  -- brush
                10,   -- width of the ellipse used to draw the rounded corner
                10)   -- height of the ellipse used to draw the rounded corner
				)
		----[[Frame]]-----圆角的框架End
	---------------------------------------------------------------
		WindowFont (self.name, "f1", "宋体", 12, false, false, false, false)
		header_width = WindowTextWidth(self.name, "f1", self.TITLE)
		header_font_height=10
		WindowText(self.name, "f1", self.TITLE, (self.width-header_width)/2, ((self.TITLE_HEIGHT-header_font_height)/2)+10, self.width, self.TITLE_HEIGHT*2, 0xEEEEEE, false)

   WindowLine(self.name, 5, self.TITLE_HEIGHT*2+5, self.width, self.TITLE_HEIGHT*2+5, self.WINDOW_BORDER, 0 + 0x0200, 1)
  -- pixel to start at
  self.vertical = self.TITLE_HEIGHT*2+15

  --DoGauge ("精神: ", percentSpirit, "darkgreen", "mediumblue", "darkred", currSpirit.."/"..maxSpirit, 0)
  --DoGauge ("气血: ", percentHP, "darkgreen", "mediumblue", "darkred", currHp.."/"..maxHp, 0)
  --DoGauge ("精力: ", percentEnergy, "darkgreen", "mediumblue", "darkred", currEnergy.."/"..maxEnergy, 0)
  --DoGauge ("内力: ", percentMana, "darkgreen", "mediumblue", "darkred", currMana.."/"..maxMana, 0)
  --DoGauge ("食物: ", percentFood, "darkgreen", "mediumblue", "darkred", currFood.."/"..maxFood, 0)
  --DoGauge ("饮水: ", percentWater, "darkgreen", "mediumblue", "darkred", currWater.."/"..maxWater, 0)
  --DoGauge ("潜能: ", 100, "darkgreen", "mediumblue", "darkred", sPotential, 1)
  --DoGauge ("经验: ", 100, "darkgreen", "mediumblue", "darkred", sExp, 1)
  for _,i in ipairs(self.items) do
     if i.label~=nil then
		if i.color==nil then i.color=self.TEXT_COLOR end
      self:drawText(i.label,i.color)
	 elseif i.Percent~=nil then
	  self:DoGauge(i.sPrompt,i.Percent,i.sGoodColor,i.sMediumColor,i.sBadColor,i.sText,i.bTextOnly)
	 end
  end
  Redraw()
end -- draw_bar

--添加标签
function window:addText(id,text,color)
    local item={}
	if color==nil then color=self.TEXT_COLOR end
    for _,i in ipairs(self.items) do
      if i.id==id then
	     --print("text_id:",id)
	     item=i
		 item.label=text
		 item.color=color
         return
	  end
    end
   item.id=id
   item.label=text
   item.color=color
   table.insert(self.items,item)
   --Repaint ()  -- update window location
end
--添加进度条
function window:addGauge(id,sPrompt, Percent, sGoodColor, sMediumColor, sBadColor, sText, bTextOnly)
   local item={}
   for _,i in ipairs(self.items) do
      if i.id==id then
	     item=i
         item.sPrompt=sPrompt
         item.Percent=Percent
         item.sGoodColor=sGoodColor
         item.sMediumColor=sMediumColor
         item.sBadColor=sBadColor
         item.sText=sText
         item.bTextOnly=bTextOnly
		 return
	  end
   end
   item.id=id
   item.sPrompt=sPrompt
   item.Percent=Percent
   item.sGoodColor=sGoodColor
   item.sMediumColor=sMediumColor
   item.sBadColor=sBadColor
   item.sText=sText
   item.bTextOnly=bTextOnly
   table.insert(self.items,item)
end

--关闭窗口
function window:close()
   WindowDelete(self.name)
end

function close_byName(win_name)
   WindowDelete(win_name)
end

--开启
function window:refresh()
  self.vertical=8
  self:init()
  self:draw_bar()
end


