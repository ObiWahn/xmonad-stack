import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO

-- Main
--import XMonad
import qualified XMonad.StackSet as W

-- General
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Util.EZConfig
import XMonad.Util.Scratchpad
--import XMonad.Hooks.DynamicLog
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.ManageHelpers
import XMonad.Util.NamedScratchpad
import XMonad.Util.WorkspaceCompare
import XMonad.Util.SpawnOnce

-- Layouts
import XMonad.Layout.Tabbed
import XMonad.Layout.Renamed
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Accordion

-- Actions
import XMonad.Actions.CycleWS
import XMonad.Actions.CopyWindow


-- https://github.com/drot/dotfiles/blob/master/.xmonad/xmonad.hs

-- Font and colors
--
myFont = "-xos4-terminus-medium-*-*-*-14-*-*-*-*-*-iso8859-2"
myBGColor = "#333333"
myFGColor = "#FFFDB3"
myWhiteColor = "#FFFFFF"
myBlackColor = "2b2b2b"
myRedColor = "#E0546A"
myGreenColor = "#3CC85E"
myLightGreenColor = "#2CFF2C"
myPurpleColor = "#B04AD9"
myBlueColor = "#5FB9E1"

mySep = "<fc=" ++ myGreenColor ++ "> ></fc><fc=" ++ myLightGreenColor ++ ">> </fc>"

--https://mail.haskell.org/pipermail/xmonad/2008-November/006650.html

-- Wrappers for title and workspaces
myTitleWrap     = wrap ("<fc=" ++ myFGColor    ++ ">< </fc>") ("<fc=" ++ myFGColor ++ "> ></fc>")
myWorkspaceWrap = wrap ("<fc=" ++ myFGColor    ++ ">[</fc>") ("<fc=" ++ myFGColor ++ ">]</fc>")
myUrgentWrap    = wrap ("<fc=" ++ myGreenColor ++ ">[</fc>") ("<fc=" ++ myGreenColor ++ ">]</fc>")


myManageHook = composeAll
    [ className =? "Gimp"      --> doFloat
    , className =? "Vncviewer" --> doFloat
    ]

--myLayouts = layoutHook defaultConfig ||| Full

main = do
    xmproc <- spawnPipe "~/.cabal/bin/xmobar ~/.xmobarrc-top2"
    xmonad $ defaultConfig
        { manageHook = manageDocks <+> myManageHook -- make sure to include myManageHook definition from above
                        <+> manageHook defaultConfig
        , startupHook = spawnOnce "~/.cabal/bin/xmobar ~/.xmobarrc-bottom"
        --, layoutHook = avoidStruts  $  smartBorders $ layoutHook defaultConfig
        , layoutHook = ( avoidStruts  $  smartBorders $ layoutHook defaultConfig ) ||| noBorders(Full)
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        --, ppTitle = xmobarColor myBlueColor "" . myTitleWrap . shorten 50
                        --, ppTitle = \x -> (xmobarColor myWhiteColor "" . shorten 50) x ++ mySep
                        , ppTitle = \x -> case () of
                            _| x == ""    -> ""
                             | otherwise  -> (xmobarColor myWhiteColor "" . shorten 50) x ++ mySep
                        , ppCurrent = xmobarColor myWhiteColor "" . myWorkspaceWrap
                        , ppUrgent = xmobarColor myPurpleColor "" . myUrgentWrap
                        , ppSep = mySep
                        , ppWsSep = "<fc=" ++ myLightGreenColor ++ ">:</fc>"
                        , ppLayout = xmobarColor myFGColor ""
                        , ppSort = fmap (.scratchpadFilterOutWorkspace) getSortByTag 
                        -- old
                        }
        , modMask = mod4Mask     -- Rebind Mod to the Windows key
        , borderWidth = 3
        , focusedBorderColor = myRedColor
        , normalBorderColor = myBGColor
-- http://xmonad.org/xmonad-docs/xmonad-contrib/XMonad-Util-EZConfig.html add/remove keys

        } `removeKeys`
        [ (mod4Mask               , xK_space) -- collides with vim completion
        ]
        `additionalKeys`
        [ ((mod4Mask              , xK_c),       sendMessage NextLayout)
        , ((mod4Mask              , xK_Up),      sendMessage NextLayout)
        -- , ((mod4Mask              , xK_Down),    sendMessage PreviousLayout)
        , ((mod4Mask              , xK_Right),   nextWS)
        , ((mod4Mask              , xK_Left),    prevWS)
        , ((mod4Mask              , xK_Return),  spawn $ XMonad.terminal defaultConfig) -- %! Launch terminal
        --, ((mod4Mask              , xK_Return),  spawn "gnome-terminal") -- %! Launch terminal
        , ((mod4Mask              , g),          spawn $ XMonad.terminal defaultConfig) -- %! Launch terminal
        , ((mod4Mask              , xK_p),       spawn $ "dmenu_run -fn '" ++ myFont ++ "'") -- %! Launch terminal
        , ((mod4Mask .|.shiftMask , xK_Return),  windows W.swapMaster) -- %! Swap the focused window and the master window<F12>
        , ((mod4Mask              , xK_v ),      windows copyToAll)
        , ((mod4Mask .|. shiftMask, xK_l),       spawn "slock")
        , ((mod4Mask              , xK_f),       spawn "iceweasel")
        , ((controlMask           , xK_Print),   spawn "cd ~; sleep 0.2; scrot -s")
        , ((0                     , xK_Print),   spawn "cd ~; scrot")
        , ((mod4Mask              , xK_s),       spawn "cd ~; scrot")

        -- XF86AudioLowerVolume
        , ((0                     , 0x1008ff11), spawn "amixer -q -c 0 set Master 2dB-")
        -- XF86AudioRaiseVolume
        , ((0                     , 0x1008ff13), spawn "amixer -q -c 0 set Master 2dB+")
        -- XF86AudioMute
        , ((0                     , 0x1008ff12), spawn "amixer -q set Master toggle")

        -- XF86Backlight
        , ((0                     , 0x1008ff02), spawn "xbacklight -inc 10")
        , ((0                     , 0x1008ff03), spawn "xbacklight -dec 10")

        -- XF86Explorer
        , ((0                     , 0x1008ff5d), spawn "~/.bin/key_xrandr.sh")

         -- XF86Search
        , ((0                     , 0x1008ff1b), spawn "/usr/local/bin/touchpad_lenovo.sh toggle")
        ]
