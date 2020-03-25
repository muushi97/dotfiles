-------------------------------------------------------------------------------
--                  __  ____  __       _                                     --
--                  \ \/ /  \/  | ___ | |__   __ _ _ __                      --
--                   \  /| |\/| |/ _ \| '_ \ / _` | '__|                     --
--                   /  \| |  | | (_) | |_) | (_| | |                        --
--                  /_/\_\_|  |_|\___/|_.__/ \__,_|_|                        --
--                                                                           --
-------------------------------------------------------------------------------

Config { font = "xft:Cica:size=11"                  -- font (xftってのがフォントにアクセスしてる)
       , bgColor = "#282828"                        -- back ground color
       , fgColor = "#d8d8d8"                        -- fore ground color
       , position = TopSize C 100 20                -- bar position
       , lowerOnStart = True                        -- if true bar lower other windows
       , hideOnStart = False                        -- bar is hidden when to start
       , allDesktops = True                         -- all desktop use bar
       , overrideRedirect = True                    -- 普通のwindow扱いしないならTrue
       , pickBroadest = False                       -- クソデカモニター君に bar を出すなら True
       , persistent = True                          -- bar が hidden かどうか関係なしに表示するならTrue
       , borderWidth = 0
       , iconRoot = "/home/kohei/dotfiles/icons"
       , commands = [ Run MultiCpu              [ "-t"       , "<fc=#cccccc><icon=cpu.xbm/></fc><total>%"
                                                , "-L"       , "40"
                                                , "-H"       , "85"
                                                , "--normal" , "#d3d7cf"
                                                , "--high"   , "#c16666"
                                                ] 50

                    , Run Memory                [ "-t"       , "<icon=mem.xbm/><usedratio>%"
                                                , "-L"       , "40"
                                                , "-H"       , "90"
                                                , "--normal" , "#d3d7cf"
                                                , "--high"   , "#c16666"
                                                ] 10

                    , Run Battery               [ "-t"       , "<acstatus>"
                                                , "-L"       , "30"
                                                , "-H"       , "80"
                                                , "--low"    , "#c16666"
                                                , "--normal" , "#d3d7cf"
                                                , "--high"   , "#00ff00"
                                                , "--"
                                                    , "-o"   , "<icon=bat.xbm/><left>%(<timeleft>)"          -- 通常
                                                    , "-O"   , "<fc=#ffff00><icon=bat.xbm/></fc><left>%"     -- 充電中
                                                    , "-i"   , "<icon=bat.xbm/><left>%"                      -- 充電終わり
                                                ] 50

                    , Run Network "enp0s31f6"   [ "-t"       , "<dev>:D<rx>, U<tx>"
                                                , "-L"       , "0"
                                                , "-H"       , "32"
                                                , "--normal" , "green"
                                                , "--high"   , "red"
                                                ] 10

                    , Run Network "wlp4s0"      [ "-t"       , "<icon=wireless.xbm/>D<rx>, U<tx>"
                                                , "-L"       , "0"
                                                , "-H"       , "32"
                                                , "--normal" , "green"
                                                , "--high"   , "red"
                                                ] 10
                    , Run Date "%m/%d %H:%M %a" "date" 30
                    , Run Com "/home/kohei/dotfiles/fcitx-judge.sh" [] "fcitx" 5
                    , Run StdinReader
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%StdinReader% }{ <fc=#d8d8d8,#006600><action=`pavucontrol`><icon=speaker.xbm/></action></fc> <action=`nm-connection-editor`>%wlp4s0%</action> %multicpu% %memory% %battery% <action=`fcitx-configtool`>%fcitx%</action> <fc=#c7a273>%date%</fc> <action=`rofi -show system`>🔌</action> "
       }



