-------------------------------------------------------------------------------
--                  __  ____  __                       _                     --
--                  \ \/ /  \/  | ___  _ __   __ _  __| |                    --
--                   \  /| |\/| |/ _ \| '_ \ / _` |/ _` |                    --
--                   /  \| |  | | (_) | | | | (_| | (_| |                    --
--                  /_/\_\_|  |_|\___/|_| |_|\__,_|\__,_|                    --
--                                                                           --
-------------------------------------------------------------------------------

import System.Cmd
import Data.List(isPrefixOf, find, sort, sortBy)
import Data.Maybe

-------------------------------------------------------------------------------
-- Import modules                                                           {{{
-------------------------------------------------------------------------------
import qualified Data.Map as M
import qualified XMonad.StackSet as W
import Control.Monad (liftM2)          -- myManageHookShift
import Data.Monoid
import System.IO                       -- for xmobar
import XMonad.Config.Desktop (desktopLayoutModifiers)

import XMonad
import qualified XMonad.StackSet as W  -- myManageHookShift

import XMonad.Actions.CopyWindow
import XMonad.Actions.CycleWS
import qualified XMonad.Actions.FlexibleResize as Flex -- flexible resize
import XMonad.Actions.FloatKeys
import XMonad.Actions.UpdatePointer
import XMonad.Actions.WindowGo
import XMonad.Actions.MouseGestures

import XMonad.Hooks.DynamicLog         -- for xmobar
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks        -- avoid xmobar area
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.FadeInactive       -- xcompmgr での透過に使う

import XMonad.Layout
import XMonad.Layout.DragPane          -- see only two window
import XMonad.Layout.Gaps
import XMonad.Layout.NoBorders         -- In Full mode, border is no use
import XMonad.Layout.PerWorkspace      -- Configure layouts on a per-workspace
import XMonad.Layout.ResizableTile     -- Resizable Horizontal border
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.Simplest
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spacing           -- this makes smart space around windows
import XMonad.Layout.ToggleLayouts     -- Full window at any time
import XMonad.Layout.TwoPane
import XMonad.Layout.Named             -- named layout

import XMonad.Prompt
import XMonad.Prompt.Window            -- pops up a prompt with window names
import XMonad.Util.EZConfig            -- removeKeys, additionalKeys
import XMonad.Util.Run
import XMonad.Util.Run(spawnPipe)      -- spawnPipe, hPutStrLn
import XMonad.Util.SpawnOnce
import XMonad.Util.WorkspaceCompare

import XMonad.Actions.CycleWS

import Graphics.X11.ExtraTypes.XF86


--------------------------------------------------------------------------- }}}
-- local variables                                                          {{{
-------------------------------------------------------------------------------
modm = mod4Mask

-- Color Setting
colorBarbg     = "#2e2930"
colorActive    = "#a8bf93"
colorNonActive = "#769164"

-- Border width
borderwidth = 0


--------------------------------------------------------------------------- }}}
-- main                                                                     {{{
-------------------------------------------------------------------------------
main :: IO ()
main = do
    wsbar <- spawnPipe "xmobar $HOME/.xmonad/xmobarrc"
    xmonad . docks . ewmh $ defaultConfig                                   -- docks (for xmobar), ewmh (for libreoffice ,etc...)
        { borderWidth        = borderwidth                                   -- border width
        --, terminal           = "urxvtc; if [ $? -eq 2 ]; then urxvtd -q -o -f; urxvtc; fi"                                       -- terminal
        , terminal           = "urxvt"                                     -- terminal
        , normalBorderColor  = colorNonActive                                -- border color then active
        , focusedBorderColor = colorActive                                   -- border color then non active
        , workspaces         = myWorkspaces
        , modMask            = modm                                          -- mod key
        , startupHook        = do
                                spawn "xscreensaver -no-splash"                 -- start up program
                                spawn "~/alias/display.sh auto"
                                spawn "wmname LG3D"                         -- for Android Studio (https://qiita.com/matoruru/items/506e27ee60f7053a39a8)
        , layoutHook         = myLayout                  -- layout
         -- xmobar setting
        , logHook            = do
                                myLogHook wsbar >> updatePointer (0.5, 0.5) (0, 0)
                                fadeInactiveLogHook 0xdddddddd
        }
-------------------------------------------------------------------- }}}
-- Keymap: window operations                                         {{{
------------------------------------------------------------------------
        `additionalKeysP`
        [ ("M-f", sendMessage ToggleLayout)
        , ("M-s", spawn "xscreensaver-command --lock")
        , ("M-p", spawn "rofi -show drun")
        , ("M-S-r", do
            spawn "~/alias/display.sh auto"
            screenWorkspace 1 >>= flip whenJust (windows.W.view)
            (windows . W.greedyView) "8"
            screenWorkspace 0 >>= flip whenJust (windows.W.view)
            (windows . W.greedyView) "1")
        , ("M-n", moveTo Next validWS)
        , ("M-b", moveTo Prev validWS)
        -- 以下ゴミs
        -- , ("M-r", (withWindowSet $ \ws -> return . map $ (W.tag &&& W.integrate' . W.stack) (W.workspaces ws)))
        --, ("M-r", if W.view == 1 then (windows . W.greedyView) "2" else (windows . W.greedyView) "1")
        ]
-------------------------------------------------------------------- }}}
-- Keymap: window operations                                         {{{
------------------------------------------------------------------------
        `additionalMouseBindings`
        [ ( ( modm, button1 ), mouseGesture gestures )
        ]

gestures = M.fromList
            [ ( [ L ], \_ -> prevWS )
            , ( [ D ], \_ -> prevWS )
            , ( [ U ], \_ -> nextWS )
            , ( [ R ], \_ -> nextWS )
            ]


validWSName :: String -> Bool
validWSName "NSP" = False
validWSName name
    | "Shy" `isPrefixOf` name = False
    | otherwise               = True

validWS :: WSType
validWS = WSIs $ return validWS'

validWS' :: W.Workspace WorkspaceId l a -> Bool
--validWS' w = validWSName (W.tag w) && isJust (W.stack w)
validWS' w = validWSName (W.tag w)
  where


-------------------------------------------------------------------- }}}
-- Workspaces:                                                       {{{
------------------------------------------------------------------------
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8"]


--------------------------------------------------------------------------- }}}
-- myLayout:          Handle Window behaveior                               {{{
-------------------------------------------------------------------------------
gapwidth = 3
gwU = 10                                                                -- upper gap
gwD = 15                                                                -- downer gap
gwL = 12                                                                -- left gap
gwR = 12                                                                -- right gap
tall = (ResizableTall 1 (1/110) (3/5) [])
two = TwoPane (1/110) (3/5)
vertical = tall
horizontal = Mirror tall
vertical_two = two
horizontal_two = Mirror two
myLayout = toggleLayouts ( noBorders $ named "F" Full ||| avoidStruts( named "F" Full) )
            $ avoidStruts( gaps [(U, gwU),(D, gwD),(L, gwL),(R, gwR)]
            $ (named "H" $ spacing gapwidth $ horizontal) ||| ( named "V" $ spacing gapwidth $ vertical ) ||| ( named "Ht" $ spacing gapwidth $ horizontal_two )  ||| ( named "Vt" $ spacing gapwidth $ vertical_two ) ||| ( named "S" $ spacing gapwidth $ Simplest ))


--------------------------------------------------------------------------- }}}
-- myLogHook:         loghock settings                                      {{{
-------------------------------------------------------------------------------
myLogHook h = dynamicLogWithPP $ wsPP { ppOutput = hPutStrLn h}


--------------------------------------------------------------------------- }}}
-- myWsBar:           xmobar setting posision                               {{{
-------------------------------------------------------------------------------
-- xdotool key "super+2" でワークスペース2にとべる
wsPP = xmobarPP { ppOrder           = \(ws:l:t:_) -> [l,ws,t]
                --, ppCurrent         = xmobarColor colorActive      colorBarbg . \s -> "<action=`xdotool key \"super+" ++ s ++ "\"`><icon=layout_unempty.xbm/></action>"
                --, ppCurrent         = xmobarColor colorActive      colorBarbg . \s -> "<action=`pavucontrol`><icon=layout_unempty.xbm/></action>"
                , ppCurrent         = xmobarColor colorActive      colorBarbg . \s -> "<icon=layout_unempty.xbm/>"
                , ppUrgent          = xmobarColor colorNonActive   colorBarbg . \s -> "<icon=layout_unempty.xbm/>"
                , ppVisible         = xmobarColor colorActive      colorBarbg . \s -> "<icon=layout_empty.xbm/>"
                , ppHidden          = xmobarColor colorNonActive   colorBarbg . \s -> "<icon=layout_unempty.xbm/>"
                , ppHiddenNoWindows = xmobarColor colorNonActive   colorBarbg . \s -> "<icon=layout_empty.xbm/>"
                , ppTitle           = xmobarColor colorActive      colorBarbg . \s -> shorten 30 s
                , ppLayout          = xmobarColor colorActive "" . myLayoutPrinter
                , ppOutput          = putStrLn
                , ppWsSep           = " "
                , ppSep             = " "
                }

myLayoutPrinter :: String -> String
myLayoutPrinter "F" = "<icon=layout_Simple.xbm/>"
myLayoutPrinter "S" = "<icon=layout_Simple.xbm/>"
myLayoutPrinter "H" = "<icon=layout_Horizontal.xbm/>"
myLayoutPrinter "V" = "<icon=layout_Vertical.xbm/>"
myLayoutPrinter "Ht" = "Ht"
myLayoutPrinter "Vt" = "Vt"

