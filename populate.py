#!/usr/bin/python3
import sys
import os

# yosys only knows verilog, verilog is limited in how one may populate
# a BRAM. This bit of Python nonsense converts a text file to a bunch
# verilog 

# v stands for verilog
class v:
    arrayName = "verilog_array_name"       # varilog array we are populating
    i = 0                                  # the element in the array

    def p(char):
        print("{}[{}] = \"{}\";".format(v.arrayName, v.i, char))
        v.i += 1


def main() -> int:
    if (len(sys.argv) != 2):
        print("{}: Opens a file [array name].txt and writes verilog statements to stdout".format(sys.argv[0]))
        print("the varilog statements are suitable to populate an array in an initial block.")
        print("usage: {} [array name]".format(sys.argv[0]))
        exit(1)
    v.arrayName = os.path.splitext(sys.argv[1])[0]
    f = open("{}.txt".format(v.arrayName))
    esc = False
    while 1:
        # read by character
        char = f.read(1)
        if esc:
            if char == "e":
                v.p("\\033") # esc
                esc = False
                continue
            if char == "f":
                v.p("\\014") # FF = EOF
                esc = False
                break
        if char == "\\":
            esc = True
            continue
        if char == "\n":
            v.p("\\015")
            v.p("\\012")
            continue
        if not char:
            break

        v.p(char)
    f.close()
    return 0

if __name__ == '__main__':
    sys.exit(main())  # next section explains the use of sys.exit
