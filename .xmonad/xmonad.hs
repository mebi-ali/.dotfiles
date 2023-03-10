------------------------------------------------------------------------
-- import
------------------------------------------------------------------------


import XMonad hiding ( (|||) ) -- jump to layout
import XMonad.Layout.LayoutCombinators (JumpToLayout(..), (|||)) -- jump to layout
import XMonad.Config.Desktop
import System.Exit
import qualified XMonad.StackSet as W
import Graphics.X11.ExtraTypes.XF86

-- data
import Data.Char (isSpace)
import Data.List
import Data.Monoid
import Data.Maybe (isJust)
import Data.Ratio ((%)) -- for video
import qualified Data.Map as M

-- system
import System.IO (hPutStrLn) -- for xmobar

-- util
import XMonad.Util.Run (safeSpawn, unsafeSpawn, runInTerm, spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.SpawnNamedPipe
import XMonad.Util.EZConfig (additionalKeys, additionalMouseBindings)  
import XMonad.Util.NamedScratchpad
import XMonad.Util.NamedWindows
import XMonad.Util.WorkspaceCompare
import XMonad.Util.Cursor



-- hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks (avoidStruts, docksStartupHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.EwmhDesktops -- to show workspaces in application switchers
import XMonad.Hooks.ManageHelpers (isFullscreen, isDialog,  doFullFloat, doCenterFloat, doRectFloat) 
import XMonad.Hooks.Place (placeHook, withGaps, smart)
import XMonad.Hooks.UrgencyHook

-- actions
import XMonad.Actions.CopyWindow -- for dwm window style tagging
import XMonad.Actions.UpdatePointer -- update mouse postion

-- layout 
import XMonad.Layout.Renamed (renamed, Rename(Replace))
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import XMonad.Layout.GridVariants
import XMonad.Layout.ResizableTile
import XMonad.Layout.BinarySpacePartition


import Control.Monad

-- Actions
import XMonad.Actions.CopyWindow -- for dwm window style tagging
import XMonad.Actions.UpdatePointer -- update mouse postion



------------------------------------------------------------------------
-- variables
------------------------------------------------------------------------


myModMask = mod4Mask -- Sets modkey to super/windows key
myTerminal = "urxvt" -- Sets default terminal
myBorderWidth = 2 -- Sets border width for windows
myNormalBorderColor = "#839496"
myFocusedBorderColor = "#268BD2"
myppCurrent = "#cb4b16"
myppVisible = "#cb4b16"
myppHidden = "#268bd2"
myppHiddenNoWindows = "#93A1A1"
myppTitle = "#FDF6E3"
myppUrgent = "#DC322F"
myWorkspaces = ["1","2","3","4","5","6","7","8","9"]
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True
myClickJustFocuses :: Bool
myClickJustFocuses = False



------------------------------------------------------------------------
-- layout
------------------------------------------------------------------------


myLayout = avoidStruts (full ||| tiled ||| grid ||| bsp)
  where
     -- full
     full = renamed [Replace "Full"] 
          $ noBorders (Full)

     -- tiled
     tiled = renamed [Replace "Tall"] 
           $ spacingRaw True (Border 10 0 10 0) True (Border 0 10 0 10) True 
           $ ResizableTall 1 (3/100) (1/2) []

     -- grid
     grid = renamed [Replace "Grid"] 
          $ spacingRaw True (Border 10 0 10 0) True (Border 0 10 0 10) True 
          $ Grid (16/10)

     -- bsp
     bsp = renamed [Replace "BSP"] 
         $ emptyBSP

     -- The default number of windows in the master pane
     nmaster = 1
     
     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100




------------------------------------------------------------------------
-- Startup hook
------------------------------------------------------------------------


myStartupHook = do
    spawnOnce  "nitrogen --restore &"
    spawnOnce  "compton &"
    spawnNamedPipe "xmobar ~/.config/xmobar/xmobarrc" "xmobtop"
    spawnOnce "volumeicon &"
    spawnOnce  "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 0x292d3e --height 18 &"
------------------------------------------------------------------------
-- Window rules:
------------------------------------------------------------------------


myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , isFullscreen                  --> doFullFloat ]


------------------------------------------------------------------------
-- LogHooks:
------------------------------------------------------------------------


myLogHook pipeName = do
  mh <- getNamedPipe pipeName
  dynamicLogWithPP myPP { ppOutput = maybe (\_ -> return ()) hPutStrLn mh
                              }




------------------------------------------------------------------------
-- Xmobar:
------------------------------------------------------------------------

myBar = "xmobar"


-- Veriables
myTitleColor = "#eeeeee" -- color of window title
myTitleLength = 80 -- truncate window title to this length
myCurrentWSColor = "#e6744c" -- color of active workspace
myVisibleWSColor = "#c185a7" -- color of inactive workspace
myUrgentWSColor = "#cc0000" -- color of workspace with 'urgent' window
myCurrentWSLeft = "[" -- wrap active workspace with these
myCurrentWSRight = "]"
myVisibleWSLeft = "(" -- wrap inactive workspace with these
myVisibleWSRight = ")"
myUrgentWSLeft = "{" -- wrap urgent workspace with these
myUrgentWSRight = "}"


-- Custom PP, configure it as you like. It determines what is being written to the bar.
myPP = xmobarPP { ppTitle = xmobarColor "#2DACB7" "" . shorten 50
                      , ppCurrent = xmobarColor "#E5AC39" "" . wrap "[" "]"
                      , ppHiddenNoWindows = xmobarColor "#2D2D4C" ""
                      , ppUrgent = xmobarColor "#E55C50" "#E5F4FF"
                      , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" ""   -- Hidden workspaces in xmobar
                      }



------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
------------------------------------------------------------------------





------------------------------------------------------------------------
-- MouseBindings:
------------------------------------------------------------------------



myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]





-- Key binding to toggle the gap for the bar.
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)



------------------------------------------------------------------------
-- main
------------------------------------------------------------------------


main = do
    xmproc0 <- spawnPipe "/usr/bin/xmobar -x 0  /home/mebi-ali/.config/xmobar/xmobarrc"
    --xmproc1 <- spawnPipe "/usr/local/bin/xmobar -x 1 /home/djwilcox/.config/xmobar/xmobarrc"
    xmonad $  ewmh desktopConfig
        { manageHook = ( isFullscreen --> doFullFloat ) <+> manageDocks <+> myManageHook <+> manageHook desktopConfig
        , startupHook        = myStartupHook
        , layoutHook         = myLayout
        , handleEventHook    = handleEventHook desktopConfig
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , terminal           = myTerminal
        , modMask            = myModMask
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , logHook = myLogHook "xmobtop" <+> logHook desktopConfig  
          }
	 `additionalKeys`
	[
		-- Mute
		((0, xF86XK_AudioMute), spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
 	        
		-- Decrease
		, ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ -10%")
  		
		-- Increase
		, ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ +10%")
	
		-- Brightness Up
		, ((0, xF86XK_MonBrightnessUp), spawn "lux -a 10%")
 		
		-- Brightness Down
		, ((0, xF86XK_MonBrightnessDown), spawn "lux -s 10%")

		-- Brave Browser
		,((mod4Mask, xK_w), spawn "brave-browser &")

		--d_menu
		, ((mod4Mask, xK_d), spawn "rofi -show run")

		--ScreenShot
		, ((mod4Mask .|. controlMask .|. shiftMask, xK_p),
	          spawn "xfce4-screenshooter")
	
	 

	]
	



------------------------------------------------------------------------
-- Defualt Keys:
------------------------------------------------------------------------


help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]

