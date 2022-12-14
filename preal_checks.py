#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# # $File$
# 
# Summary: verifies that all preals declared have associated checks
# Author: Ben Trettel (<http://trettel.us/>)
# Last updated: $Date$
# Revision: $Revision$
# Project: [Daphne](https://github.com/btrettel/daphne)
# License: [LGPLv3](https://www.gnu.org/licenses/lgpl-3.0.en.html)

import argparse
import sys

# TODO: <https://en.wikipedia.org/wiki/The_Power_of_10:_Rules_for_Developing_Safety-Critical_Code>: > 5. Use a minimum of two runtime assertions per function.>

# <https://stackoverflow.com/a/14981125/1124489>
def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

parser = argparse.ArgumentParser(description="verifies that all preals declared have associated checks")
parser.add_argument("files", help="one or more files to read", nargs="+")
parser.add_argument("-v", "--version", action="version", version="0.1.0")
args = parser.parse_args()

filename_list = args.files

errors_found = False

for filename in filename_list:
    with open(filename, 'r') as f:
        variable_set = set()
        check_set = set()
        
        line = f.readline()
        line_number = 0
        continued = False
        while line:
            line = line.replace('\n', '').strip()
            line = line.split("!")[0]
            
            if continued:
                line = old_line + line
                continued = False
            
            line_number += 1
            
            if line.endswith("&"):
                continued = True
                old_line = line[:-1]
                
                # advance line
                line = f.readline()
                
                continue
            
            if line.startswith("type(preal)"):
                if not ("::" in line):
                    errors_found = True
                    print_line_with_error(filename, line_number, line, "Double colons required in type declarations.")
                else:
                    line_variable_list_string = line.split("::")[1].strip()
                    
                    line_variable_list = line_variable_list_string.split(",")
                    
                    for line_variable in line_variable_list:
                        variable_set.add(line_variable.strip())
            
            if line.startswith("call CHECK_FLAG("):
                end_index = line.index(")")
                check_set.add(line[16:end_index].strip())
            
            # advance line
            line = f.readline()
        
        for variable in variable_set:
            if not variable in check_set:
                eprint("preal not checked:", variable)
                errors_found = True

if errors_found:
    exit(1)
