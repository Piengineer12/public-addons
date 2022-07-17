Installation instructions (Windows):
1. In the Steam Library, right-click on Garry's Mod and press "Properties...".
2. Click on the Local Files tab on the left, then click on "Browse...".
3. Open the "bin" folder.
4. Put rotgb.fgd into the folder.
5. Open hammer.exe in the same folder.
6. Click on the Tools tab on the top menu bar, then click on Options.
7. To the right of the "Game Data files" panel in the Game Configurations tab, click on the Add buttton.
8. Load the rotgb.fgd file.

Entities added:
- gballoon_spawner
- gballoon_target
- logic_rotgb_cash
- logic_rotgb_timescale
- logic_rotgb_difficulty
- func_rotgb_nobuild
- func_nav_avoid
- func_nav_prefer
- filter_rotgb
- env_rotgb_text
- point_rotgb_spectator
- gballoon_base [!fgd]
- gballoon_tower_base [!fgd]
To view the Help of an entity, open the Entity Properties dialog, then click on "Help" near the top-right of the opened window.

Additional Notes:
'gballoon_base' and 'gballoon_tower_base' entities are not included within the .fgd file because they are not meant to be placed directly in a map. However, the entities mentioned above still can receive certain inputs. For the sake of documentation, their inputs are listed below. 'X' represents the value of the parameter override.

gballoon_base:
- Pop <integer>
Instantly pops the gBalloon plus X damage. If X is unspecified or -1, all layers of the gBalloon are popped.
Note: You should be using a trigger_hurt to pop the gBalloon instead, unless you know what you are doing.
- Stun <float>
Makes the gBalloon unable to move for X seconds.
- UnStun <void>
Removes stun from the gBalloon.
- Freeze <float>
Similar to Stun, except only one layer is frozen, and can only be popped by lead-poppers.
- UnFreeze <void>
Removes freeze from the gBalloon.

gballoon_tower_base:
- Stun <float>
Makes the tower unable to fire for X seconds.
- UnStun <void>
Removes stun from the tower.

Help and Support:
Post bugs and questions on the main discussion:
https://steamcommunity.com/workshop/filedetails/discussion/1616333917/1742231705671196872/