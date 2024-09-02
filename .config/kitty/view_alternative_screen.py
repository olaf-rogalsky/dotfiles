#!/usr/bin/python

import sys, os
sys.path.append("/usr/lib/kitty")
sys.path.append("/usr/lib/kitty/kittens")

from kittens.tui.loop import debug
from typing import List
import kitty, kitty.boss

def main(args: List[str]) -> str:
    #answer = input('txt')
    return sys.stdin.read()
    return answer

from kittens.tui.handler import result_handler

@result_handler(type_of_input='alternate')
def handle_result(args: List[str], answer: str, target_window_id: int, boss: kitty.boss.Boss) -> None:
    win = boss.window_id_map.get(target_window_id)
    win.paste_text(answer[0:100])

#handle_result.no_ui = True
#handle_result.type_of_input = "history"

if __name__ == "__main__":
    os.system("kitty @ kitten view_alternate_screen.py")
