--[[
    版本号组成： [主版本号].[子版本号].[尾版本号]-<特殊后缀>
大规模改动的版本，主版本号+1，其余版本号清零，如1.3.2 -->2.0.0
每个小范围内改动（添加新物品/新生物或新功能）的版本，子版本号+1，尾版本号清零，如2.1.0-->2.2.0
每个用于修复bug的版本，尾版本号+1。 如2.1.1修复bug 2.1.1 --> 2.1.2。
特殊的发布版本，加特殊后缀。hotfix - 紧急修复bug版本，beta - 内测版 ， dev - 开发版
]]
name="作物种子"--mod的名字
author="北甍"--mod作者
version="1.0.0"--版本号
description=[[
    喂鸟吃农作物随机给1-2个作物种子和普通种子
]]
--mod的介绍

forumthread=""--steam模组下载的地址
api_version=10 --这里让其他玩家知道你的mod是否过时了，更新它以匹配游戏中的当前版本。

dst_compatible=true --用于判断是否和饥荒联机版兼容

dont_starve_compatible=false
reign_of_giants_compatible=false --10,11判定是否和饥荒单机兼容
shipwrecked_compatible=false--海滩不可兼容

all_clients_require_mod=true --打开这个mod开服后进入服务器的人必须有本mod(大部分服务器mod都为true)
client_only_mod=false--客机mod

icon_atlas="modicon.xml" --剪裁mod图标图片的文件
icon="modicon.tex" --mod的图标

server_filter_tags={
    "北甍","作物种子"
}--确定你的mod标签，人物，物品，pet宠物

--配置选项
local function AddTitle(title)
	return {
		name = "null",
		label = title,
		options = {
				{ description = "", data = 0 }
		},
		default = 0,
	}
end

configuration_options={
    {
        name="seeds",--选项标识
        label="多一个对应作物种子概率",
        options={
            {description="%100",data=1},
            {description="%90",data=0.9},
			{description="%80",data=0.8},
            {description="%70",data=0.7},
			{description="%60",data=0.6},
            {description="%50",data=0.5},
			{description="%40",data=0.4},
            {description="%30",data=0.3},
			{description="%20",data=0.2},
            {description="%10",data=0.1},
        },
        default=0.5
    },
}
