---------------------------------------------------------------------------
-- File name   : pkukxk_frame2011.lua
-- Description : 此文件为《一个脚本框架》文件的总框架调用文件。
--
-- Author: 胡小子littleknife (applehoo@126.com)
-- Version:	2012.01.05.1221
---------------------------------------------------------------------------
print("----**********************************************************----")
print("::>>框架模块载入Start<<::")

loadlist={

	-----"pkuxkx_config.lua",
	"system.mod",
	"hook.mod",
	----------------------------
	"status.mod",
	"alias.mod",
	"walk.mod",
	"fight.mod",
	-----------------------------------

	"blocker.mod",
	"rest.mod",
	"infowindow.mod",

	"quest.mod",
	"endfunction.mod",

  }
  for i=1,#loadlist do
      loadmod(loadlist[i])
  end

print("::>>框架模块载入Over<<::")
print("----**********************************************************----")
