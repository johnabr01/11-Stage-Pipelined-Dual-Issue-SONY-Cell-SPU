instruction_table = {
    # ---------------- RR ----------------
    "ah":    {"type": "RR", "opcode": 0b00011001000},
    "a":     {"type": "RR", "opcode": 0b00011000000},
    "addx":  {"type": "RR", "opcode": 0b01101000000},
    "cg":    {"type": "RR", "opcode": 0b00011000010},
    "sfx":   {"type": "RR", "opcode": 0b01101000001},
    "bg":    {"type": "RR", "opcode": 0b00001000010},
    "sfh":   {"type": "RR", "opcode": 0b00001001000},
    "sf":    {"type": "RR", "opcode": 0b00001000000},
    "and":   {"type": "RR", "opcode": 0b00011000001},
    "or":    {"type": "RR", "opcode": 0b00001000001},
    "xor":   {"type": "RR", "opcode": 0b01001000001},
    "nand":  {"type": "RR", "opcode": 0b00011001001},
    "nor":   {"type": "RR", "opcode": 0b00001001001},
    #"clz":   {"type": "RR", "opcode": 0b01010100101},
    #"fsmh":  {"type": "RR", "opcode": 0b00110110101},
    #"fsm":   {"type": "RR", "opcode": 0b00110110100},
    "ceqh":  {"type": "RR", "opcode": 0b01111001000},
    "ceq":   {"type": "RR", "opcode": 0b01111000000},
    "cgth":  {"type": "RR", "opcode": 0b01001001000},
    "cgt":   {"type": "RR", "opcode": 0b01001000000},
    "clgth": {"type": "RR", "opcode": 0b01011001000},
    "clgt":  {"type": "RR", "opcode": 0b01011000000},
    "shlh":  {"type": "RR", "opcode": 0b00001011111},
    "shl":   {"type": "RR", "opcode": 0b00001011011},
    "roth":  {"type": "RR", "opcode": 0b00001011100},
    "rot":   {"type": "RR", "opcode": 0b00001011000},
    "fa":    {"type": "RR", "opcode": 0b01011000100},
    "fs":    {"type": "RR", "opcode": 0b01011000101},
    "fm":    {"type": "RR", "opcode": 0b01011000110},
    "mpy":   {"type": "RR", "opcode": 0b01111000100},
    "mpyu":  {"type": "RR", "opcode": 0b01111001100},
    #"cntb":  {"type": "RR", "opcode": 0b01010110100},
    "absdb": {"type": "RR", "opcode": 0b00001010011},
    "avgb":  {"type": "RR", "opcode": 0b00011010011},
    "sumb":  {"type": "RR", "opcode": 0b01001010011},
    "shlqbi":{"type": "RR", "opcode": 0b00111011011},
    "shlqby":{"type": "RR", "opcode": 0b00111011111},
    "rotqby":{"type": "RR", "opcode": 0b00111011100},
    "rotqbybi":{"type": "RR", "opcode": 0b00111001100},
    "rotqbi":{"type": "RR", "opcode": 0b00111011000},
    #"gbh":   {"type": "RR", "opcode": 0b00110110001},
    #"gb":    {"type": "RR", "opcode": 0b00110110000},
    "lqx":   {"type": "RR", "opcode": 0b00111000100},
    "stqx":  {"type": "RR", "opcode": 0b00101000100},

    # ---------------- RRR ----------------
    "fma": {"type": "RRR", "opcode": 0b1110},
    "fms": {"type": "RRR", "opcode": 0b1111},
    "mpya": {"type": "RRR", "opcode": 0b1100},  

    # ---------------- RI10 ----------------
    "ahi":   {"type": "RI10", "opcode": 0b00011101},
    "ai":    {"type": "RI10", "opcode": 0b00011100},
    "sfhi":  {"type": "RI10", "opcode": 0b00001101},
    "sfi":   {"type": "RI10", "opcode": 0b00001100},
    "andhi": {"type": "RI10", "opcode": 0b00010101},
    "andi":  {"type": "RI10", "opcode": 0b00010100},
    "orhi":  {"type": "RI10", "opcode": 0b00000101},
    "ori":   {"type": "RI10", "opcode": 0b00000100},
    "xorhi": {"type": "RI10", "opcode": 0b01000101},
    "xori":  {"type": "RI10", "opcode": 0b01000100},
    "ceqhi": {"type": "RI10", "opcode": 0b01111101},
    "ceqi":  {"type": "RI10", "opcode": 0b01111100},
    "cgthi": {"type": "RI10", "opcode": 0b01001101},
    "cgti":  {"type": "RI10", "opcode": 0b01001100},
    "clgthi":{"type": "RI10", "opcode": 0b01011101},
    "clgti": {"type": "RI10", "opcode": 0b01011100},
    "mpyi":  {"type": "RI10", "opcode": 0b01110100},
    "mpyui": {"type": "RI10", "opcode": 0b01110101},
    "lqd":   {"type": "RI10", "opcode": 0b00110100},
    "stqd":  {"type": "RI10", "opcode": 0b00100100},

    # ---------------- RI7 ----------------
    "shlhi": {"type": "RI7", "opcode": 0b00001111111},
    "shli":  {"type": "RI7", "opcode": 0b00001111011},
    "rothi": {"type": "RI7", "opcode": 0b00001111100},
    "roti":  {"type": "RI7", "opcode": 0b00001111000},
    "shlqbii":{"type": "RI7", "opcode": 0b00111111011},
    "shlqbyi":{"type": "RI7", "opcode": 0b00111111111},
    "rotqbyi":{"type": "RI7", "opcode": 0b00111111100},
    "rotqbii":{"type": "RI7", "opcode": 0b00111111000},
    "bi":   {"type": "RI7", "opcode": 0b00110101000},
    "biz":  {"type": "RI7", "opcode": 0b00100101000},
    "binz": {"type": "RI7", "opcode": 0b00100101001},
    "bihz": {"type": "RI7", "opcode": 0b00100101010},
    "bihnz":{"type": "RI7", "opcode": 0b00100101011},
    "clz":   {"type": "RI7", "opcode": 0b01010100101},
    "fsmh":  {"type": "RI7", "opcode": 0b00110110101},
    "fsm":   {"type": "RI7", "opcode": 0b00110110100},
    "cntb":  {"type": "RI7", "opcode": 0b01010110100},
    "gbh":   {"type": "RI7", "opcode": 0b00110110001},
    "gb":    {"type": "RI7", "opcode": 0b00110110000},

    # ---------------- RI16 ----------------
    "ilh":  {"type": "RI16", "opcode": 0b010000011},
    "ilhu": {"type": "RI16", "opcode": 0b010000010},
    "il":   {"type": "RI16", "opcode": 0b010000001},
    "iohl": {"type": "RI16", "opcode": 0b011000001},
    "fsmbi":{"type": "RI16", "opcode": 0b001100101},
    "lqa":  {"type": "RI16", "opcode": 0b001100001},
    "stqa": {"type": "RI16", "opcode": 0b001000001},
    "br":   {"type": "RI16", "opcode": 0b001100100},
    "bra":  {"type": "RI16", "opcode": 0b001100000},
    "brsl": {"type": "RI16", "opcode": 0b001100110},
    "brasl":{"type": "RI16", "opcode": 0b001100010},
    "brnz": {"type": "RI16", "opcode": 0b001000010},
    "brz":  {"type": "RI16", "opcode": 0b001000000},
    "brhnz":{"type": "RI16", "opcode": 0b001000110},
    "brhz": {"type": "RI16", "opcode": 0b001000100},

    # ---------------- SPECIAL ----------------
    "nop":  {"type": "SPECIAL", "opcode": 0b01000000001},
    "lnop": {"type": "SPECIAL", "opcode": 0b00000000001},
    "stop": {"type": "SPECIAL", "opcode": 0b00000000000}


    #IMPLEMENT RI18 instruction, i.e. ila
}

def check_width(value, bits, name):
    if not (0 <= value < (1 << bits)):
        raise ValueError(f"{name} must fit in {bits} bits")


def build_rr(op, rb, ra, rt):
    check_width(op, 11, "opcode")
    check_width(rb, 7, "rb")
    check_width(ra, 7, "ra")
    check_width(rt, 7, "rt")

    return (op << 21) | (rb << 14) | (ra << 7) | rt

def build_rrr(op, rt, rb, ra, rc):
    check_width(op, 4, "opcode")
    check_width(rt, 7, "rt")
    check_width(rb, 7, "rb")
    check_width(ra, 7, "ra")
    check_width(rc, 7, "rc")

    return (op << 28) | (rt << 21) | (rb << 14) | (ra << 7) | rc

def build_ri7(op, i7, ra, rt):
    check_width(op, 11, "opcode")
    check_width(i7, 7, "i7")
    check_width(ra, 7, "ra")
    check_width(rt, 7, "rt")

    return (op << 21) | (i7 << 14) | (ra << 7) | rt

def build_ri10(op, i10, ra, rt):
    check_width(op, 8, "opcode")
    check_width(i10, 10, "i10")
    check_width(ra, 7, "ra")
    check_width(rt, 7, "rt")

    return (op << 24) | (i10 << 14) | (ra << 7) | rt

def build_ri16(op, i16, rt):
    check_width(op, 9, "opcode")
    check_width(i16, 16, "i16")
    check_width(rt, 7, "rt")

    return (op << 23) | (i16 << 7) | rt

def build_ri18(op, i18, rt):
    check_width(op, 7, "opcode")
    check_width(i18, 18, "i18")
    check_width(rt, 7, "rt")

    return (op << 25) | (i18 << 7) | rt

def build_special(op):
    check_width(op, 11, "opcode")

    return (op << 21)

def first_pass(lines):
    labels = {}           # label_name -> instruction address
    instructions = []     # list of tuples: (address, parsed line)
    addr = 0              # current instruction address in bytes

    for line in lines:
        parts = parse_line(line)
        if not parts:
            continue
        if parts[0].endswith(":"):
            label = parts[0][:-1] # take off the : from label
            labels[label] = addr #map addr to label key
        else:
            # store instruction for second pass
            instructions.append((addr, parts))
            addr += 4  # increment address (each instruction is 4 bytes)
    
    return labels, instructions

def parse_line(line) -> list:
    line = line.strip()
    if not line:
        return None
    
    parts = [token.strip() for token in line.split(',')]

    first = parts[0].split()
    parts = first + parts[1:]

    return parts

def parse_register(reg) -> int:
    reg = reg.lower() #convert to lowercase r
    if not reg.startswith("r"):
        raise ValueError(f"Invalid register: {reg}")
    
    val = int(reg[1:]) #strip leading r or R

    if not (0 <= val < 128):
        raise ValueError(f"Register out of range: {reg}")
    
    return val

def compute_branch_offset(target_addr, base_addr, bits):
    offset = (target_addr - base_addr) >> 2

    min_val = -(1 << (bits - 1))
    max_val = (1 << (bits - 1)) - 1

    if not (min_val <= offset <= max_val): # for safety
        raise ValueError(f"Branch offset out of range: {offset}")

    return offset & ((1 << bits) - 1)

def encode_instruction(mnemonic, operands, labels, current_addr):
    instr = instruction_table[mnemonic]
    instr_type = instr["type"]
    instr_op = instr["opcode"]

    # ---------------- RR ----------------
    if instr_type == "RR":
        rt, ra, rb = [parse_register(r) for r in operands]
        return build_rr(instr_op, rb, ra, rt)

    # ---------------- RRR ----------------
    elif instr_type == "RRR":
        rt, ra, rb, rc = [parse_register(r) for r in operands]
        return build_rrr(instr_op, rt, rb, ra, rc)

    # ---------------- RI10 ----------------
    elif instr_type == "RI10":
        rt = parse_register(operands[0])
        ra = parse_register(operands[1])
        i10 = int(operands[2], 0) & 0x3FF
        return build_ri10(instr_op, i10, ra, rt)

    # ---------------- RI7 ----------------
    elif instr_type == "RI7":
        if(mnemonic == "bi"):
            i7 = 0
            ra = parse_register(operands[0])
            rt = 0
        elif mnemonic in ["biz", "binz", "bihz", "bihnz", "clz", "fsmh", "fsm", "cntb", "gbh", "gb"]:
            i7 = 0
            rt, ra = [parse_register(r) for r in operands]
        else: #normal RI7 instruction
            rt = parse_register(operands[0])
            ra = parse_register(operands[1])
            i7 = int(operands[2], 0) & 0x7F

        return build_ri7(instr_op, i7, ra, rt)

    # ---------------- RI16 ----------------
    elif instr_type == "RI16":
        if mnemonic == "br":
            offset = compute_branch_offset(int(labels[operands[0]]), current_addr, 16)
            return build_ri16(instr_op, offset, 0) 
        elif mnemonic == "bra":
            address = compute_branch_offset(int(labels[operands[0]]), 0, 16) # for branch absolute, treat base address as 0
            return build_ri16(instr_op, address, 0)
        elif mnemonic == "brsl":
            offset = compute_branch_offset(int(labels[operands[1]]), current_addr, 16)
            rt = parse_register(operands[0])
            return build_ri16(instr_op, offset, rt) 
        elif mnemonic == "brasl":
            address = compute_branch_offset(int(labels[operands[1]]), 0, 16)
            rt = parse_register(operands[0])
            return build_ri16(instr_op, address, rt)
        elif mnemonic in ["brnz", "brz", "brhnz", "brhz"]:
            offset = compute_branch_offset(int(labels[operands[1]]), current_addr, 16)
            rt = parse_register(operands[0])
            return build_ri16(instr_op, offset, rt) 
        elif mnemonic in ["ilh", "ilhu", "il", "iohl", "fsmbi", "lqa", "stqa"]:
            rt = parse_register(operands[0])
            i16 = int(operands[1], 0) & 0xFFFF
            return build_ri16(instr_op, i16, rt)

    elif instr_type == "SPECIAL":
        return build_special(instr_op)

def assemble_text_file(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()
    
    # First pass: record labels
    labels, instructions = first_pass(lines)

    # Second pass: encode instructions and write it to output_file
    with open(output_file, 'w') as f:
        for i, (addr, parts) in enumerate(instructions):
            mnemonic = parts[0].lower()
            operands = parts[1:]
            data = encode_instruction(mnemonic, operands, labels, addr)

            if(i == len(instructions) - 1):
                f.write(f"{data:08x}")
            else:
                f.write(f"{data:08x}\n")

def main():
    input_file = "assembly.txt"
    output_file = "instructions.txt"
    assemble_text_file(input_file, output_file)

if __name__ == "__main__":
    main()