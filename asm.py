# Simple assembler for ENGR 433 Spring 2023 lab project
# Mark Haun, 3 Dec 2023
import argparse
import re


mnemonics = { 'load':   0b00000000,
              'loadi0': 0b00000001,
              'loadi1': 0b00000011,
              'loadi2': 0b00000101,
              'loadi3': 0b00000111,
              'loads0': 0b00111001,
              'loads1': 0b00111011,
              'loads2': 0b00111101,
              'loads3': 0b00111111,
              'add':    0b00001000,
              'addi':   0b00001001,
              'shr':    0b00010001,
              'shl':    0b00011001,
              'and':    0b00100000,
              'andi':   0b00100001,
              'or':     0b00101000,
              'ori':    0b00101001,
              'xor':    0b00110000,
              'xori':   0b00110001,
              'store':  0b01000000,
              'br':     0b10000000,
              'brz':    0b10000100,
              'brnz':   0b10001000,
              'brp':    0b10001100,
              'brn':    0b10010000,
              'wait':   0b10111100,
              'ssegl':  0b11000000,
              'ssegi':  0b11000001,
              'ssegh':  0b11000100,
              'ledl':   0b11001000,
              'ledh':   0b11001100
}

immed_ops = ['loadi0', 'loadi1', 'loadi2', 'loadi3', 'addi', 'andi', 'ori', 'xori', 'ssegi']
reg_ops = ['load', 'add', 'and', 'or', 'xor', 'store']
branch_ops = ['br', 'brz', 'brnz', 'brp', 'brn']

# Parse the command line
parser = argparse.ArgumentParser(prog='asm', description='Convert an ENGR433 source file into program-memory init data')
parser.add_argument('infile', help='Source file to assemble', type=open)
parser.add_argument('outfile', help='Destination RAM init file (default program.data)', nargs='?', type=argparse.FileType('w'), default='program.data')
args = parser.parse_args()


pmem = []

# The magic regex that makes everything happen :)
p = re.compile(r'^(\w+:)?\s+(\w+)\s+(#[bxa-f\d]+|\w+)?')

with open(args.infile.name) as asm:
    addr = 0
    labels = {}
    # Pass 1
    for line in asm:
        r = p.match(line)
        if r is not None:
            if r.group(1) is not None:
                labels[r.group(1)[:-1]] = addr
            addr += 1

    #print(labels)
            
    # Pass 2
    asm.seek(0)
    lineno = 1
    for line in asm:
        r = p.match(line)
        if r is not None:
            mnemonic = r.group(2)
            operand = r.group(3)
            if mnemonic in mnemonics:
                if mnemonic in immed_ops:
                    # Instruction with immediate-mode operand
                    if operand is not None and operand[0] == '#':
                        i_op = int(operand[1:], 0)
                        #print('{:s} = {:d}'.format(operand[1:], i_op))
                        if i_op >= 0 and i_op < 1024:
                            pmem.append((mnemonics[mnemonic] << 10) | i_op)
                        else:
                            print("error: operand {:s} outside allowed range for instruction {:s} (line {:d})".format(operand, mnemonic, lineno))
                    else:
                        print("error: invalid operand {:s} for instruction {:s} (line {:d})".format(operand, mnemonic, lineno))

                elif mnemonic in reg_ops:
                    # Instruction with register-mode operand
                    if operand is not None and operand[0] == 'r':
                        pmem.append((mnemonics[mnemonic] << 10) | int(operand[1:], 0))
                    else:
                        print("error: invalid operand {:s} for instruction {:s} (line {:d})".format(operand, mnemonic, lineno))

                elif mnemonic in branch_ops:
                    # Branch instruction
                    if operand is not None and operand in labels:
                        if labels[operand] >= len(pmem):
                            # jumping forwards
                            pmem.append((mnemonics[mnemonic] << 10) | labels[operand] - len(pmem))
                        else:
                            # jumping backwards---need proper 12-bit signed offset
                            pmem.append((mnemonics[mnemonic] << 10) | 4096 - (len(pmem) - labels[operand]))
                    else:
                        print("error: invalid label {:s} for branch instruction {:s} (line {:d})".format(operand, mnemonic, lineno))
                
                else:
                    # Instruction without operand
                    if operand is not None:
                        print("error: not expecting an operand with instruction {:s} (line {:d})".format(mnemonic, lineno))
                    else:
                        pmem.append(mnemonics[mnemonic] << 10)
                        
            else:
                print("error: invalid instruction {:s} (line {:d})".format(mnemonic, lineno))

        lineno += 1
                
    # Extend pmem to full 2048 words (required by Xilinx tools)
    pmem.extend([0] * (2048-len(pmem)))
    
with open(args.outfile.name, 'w') as asm:
    for word in pmem:
        asm.write("{:018b}\n".format(word))

