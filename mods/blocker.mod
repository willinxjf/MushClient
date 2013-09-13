print("Loading blocker mod is ok!")

blocker={}

----blocker.exp若为-1，则无法处理此blocker，必须绕行。

blocker["虚通"]={id="xu tong",exp=50000}
blocker["虚明"]={id="xu ming",exp=50000}
blocker["虚通伸手"]={id="xu tong",exp=50000}
blocker["虚明伸手"]={id="xu ming",exp=50000}
blocker["校尉"]={id="xiao wei",exp=50000}
blocker["采花子"]={id="caihua zi",exp=0}
blocker["衙役"]={id="ya yi",exp=50000}
blocker["摘星子"]={id="zhaixing zi",exp=400000}
blocker["出尘子伸手"]={id="wuchen zi",exp=0}
blocker["劳德诺"]={id="lao denuo",exp=0}
blocker["鳌府侍卫"]={id="shi wei",exp=50000}
blocker["鳌拜"]={id="ao bai",exp=200000}

blocker["周绮"]={id="zhou yi",exp=790000}
blocker["蒋四根"]={id="jiang sigen",exp=790000}
blocker["石双英"]={id="shi shuangying",exp=790000}
blocker["卫春华"]={id="wei chunhua",exp=790000}
blocker["杨成协"]={id="yang chengxie",exp=790000}
blocker["徐天宏长刀一摆，"]={id="xu tianhong",exp=790000}
blocker["常伯志飞身"]={id="chang bozhi",exp=790000}
blocker["常赫志"]={id="chang hezhi",exp=790000}
blocker["安健刚一把"]={id="an jiangang",exp=790000}
blocker["孟健雄一把"]={id="meng jianxiong",exp=790000}
blocker["赵半山笑嘻嘻地"]={id="zhao banshan",exp=790000}
blocker["周仲英"]={id="zhou zhongying",exp=790000}
blocker["陆菲青"]={id="lu feiqing",exp=790000}

------------------------------------------------------------------
blocker["衙役"]={id="ya yi",exp=0}
blocker["官兵们"]={id="guan bing",exp=0}
blocker["守军"]={id="guan bing",exp=-1}
blocker["绿萼"]={id="lv er",exp=-1}

----blocker["店小二"]={id="xiao er",exp=-1}
blocker["管家"]={id="guan jia",exp=-1}
blocker["陆大有"]={id="lu dayou",exp=0}
blocker["亲兵"]={id="qin bing",exp=0}
blocker["宋远桥"]={id="song yuanqiao",exp=0}
blocker["江百胜"]={id="jiang baisheng",exp=0}

blocked={}
blocked.actstr={
	"喝道：「威","拦住了","伸手拦住你","白了你一眼道",
	"满脸堆笑地走过来说",
	"拦住你说道：后面是本派重地",
	"你的经验不够，还是不要进去",
}
blocked.room={----以下房间的某方向禁入，即遍历过程忽略。
---- 方向=-1，说明禁入，方向=command，说明特殊方式处理命令为command。
-----2012.01.16
{roomname="老林尽头",dir={enter=-1,},},
{roomname="老林边缘",dir={enter=-1,},},
{roomname="天山脚下",dir={southwest=-1,},},
{roomname="太湖边",dir={south=-1,},},
{roomname="苗岭边缘",dir={southdown=-1,southup=-1},},
{roomname="桃源驿路",dir={south=-1,},},
{roomname="名人堂",dir={enter=-1,},},
}


blocked.obstacle={
"你小心翼翼往前挪动，遇到艰险难行处",
"青海湖畔美不胜收，你不由停下脚步，",
"你不小心被什么东西绊了一下",
"你的动作还没有完成，不能移动",
}

blocked.system={

"哎哟，你一头撞在墙上",
"巫师的房间还是",
"这里通向神的世界",
"此去往东是荒郊野岭",
"你抬头向上一望，我的妈呀",
"前面的小树林中不时发出几声惨叫声",
"店小二一下挡在楼梯前，白眼一翻：怎麽着，想白住啊",

"官兵拦住了你:“闲杂人等不得上",
"侍卫伸手拦住你说道：里面没什么好看的，",
"清兵说道：赶快滚开",
"王兴隆说道：“后面是我家，没事",
"丑雕神情冷漠地拦住了你的去路",
"你个大老爷们儿去那",
"应天府现在防备倭寇",
"库房重地",
"你像无头苍蝇一样在老林子",
"你发现前面似乎有人迹，加快了脚步赶过去",
"巴依说: 我把阿凡提关在我的客厅里了",
"道一说道: 你未经许可，不能",
"童百熊说道：「你不是我日月神教弟子，来我教干什么？",
"房间中已经有人在演习阵法，",
"管家挡住了你：我们家老爷",
"呼巴音手一伸，道：“这位施主，此处只有",
"桑结伸手拦住了你，一指门旁的牌子道：“没看到牌子么？",
 "你不是全真派的,还想去白洗澡",
 "招待拦住你说：对不起，我们这里是要收费的",
 "守卫喝道：闲杂人等，不得乱闯",
 "树林太茂密了，你虽然能看见西面",
}
 -----神龙教弟子大声喝道：本教重地，外人不得入内！
blocked.obstacletri=linktri(blocked.obstacle)
blocked.systemtri=linktri(blocked.system)
blocked.npctri=function()
	local _str=""
	local _blstr=""

	for k,v in pairs(blocker) do
			_str=_str..k.."|"
	end

	first_str="(>)*( )*("..rtrim("|",_str)..")"

	_str=""

	for k,v in pairs(blocked.actstr) do
			_str=_str..v.."|"
	end
	end_str="("..rtrim("|",_str)..")\\w*"
	_blstr=first_str..end_str
	return _blstr

end
WalkObstacle=0
-----流程：run(searchfor["step"])->遇到blocker触发->blocker.check(检查函数）然后分头处理。
blocked.sysblock=function(n,l,w)
	if blocked.system[w[3]]~=nil	then
		blocked.bypass(bianli.exits)
			else
		print("Error::new system blocked::")
	end
end
blocked.npcblock=function(n,l,w)
	WalkObstacle=1
	if blocker[w[3]].exp>(me.hp.exp)*1 or blocker[w[3]].exp==-1 then
		blocked.bypass(bianli.exits)
		return
	else
		do_fight(blocker[w[3]].id,"hit",blocked.block_step,blocked.block_step)
	end

end

blocked.block_step=function()
	Execute(searchfor["step"])
end
-------???
blocked.obsblock=function()
	WalkObstacle=1
	------print("WalkObstacle::",WalkObstacle)
---行走障碍，由行走函数处理。
end
------????
blocked.bypass=function(cexits)----绕过blocker继续遍历。对应于systemblocker和exp>me.exp情况。

	EnableTriggerGroup("q_bianli",true)

	_searchforlevel=_searchforlevel-1
	if (_searchforlevel<=1) then
			callhook(hooks.searchfrofail)
			_searchforpath=""
	end
		_searchforpath=rtrim(searchfor["step"]..";",_searchforpath)

	if searchfor["nextcmd"](cexits)~=false then
		run(searchfor["step"])
		else
		Note("::blockerExits is over!::")
	end
end

blocked.update=function()
	local npctri=blocked.npctri()
	local systri=blocked.systemtri
	local obstri=blocked.obstacletri

	addtri("blocker_npc",npctri,"blocker","blocked.npcblock")
	addtri("blocker_system",systri,"blocker","blocked.sysblock")
	addtri("blocker_obstacle",obstri,"blocker","blocked.obsblock")
end
blocked.update()

