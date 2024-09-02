#!/usr/bin/python

import sys, os
sys.path.append("/usr/lib/kitty")
sys.path.append("/usr/lib/kitty/kittens")

from kittens.tui.loop import debug
from typing import List
import kitty, kitty.boss

def main(args: List[str]) -> None:
    pass

def handle_result(args: List[str], answer: str, target_window_id: int, boss: kitty.boss.Boss) -> None:
    win = boss.window_id_map.get(target_window_id)
    if win.screen.disable_ligatures == 'cursor':
        win.screen.disable_ligatures = 'always'
    else:
        win.screen.disable_ligatures = 'cursor'
    #win.refresh()

handle_result.no_ui = True

if __name__ == "__main__":
    os.system("kitty @ kitten toggle_ligatures.py")
