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
    "clz":   {"type": "RR", "opcode": 0b01010100101},
    "fsmh":  {"type": "RR", "opcode": 0b00110110101},
    "fsm":   {"type": "RR", "opcode": 0b00110110100},
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
    "cntb":  {"type": "RR", "opcode": 0b01010110100},
    "absdb": {"type": "RR", "opcode": 0b00001010011},
    "avgb":  {"type": "RR", "opcode": 0b00011010011},
    "sumb":  {"type": "RR", "opcode": 0b01001010011},
    "shlqbi":{"type": "RR", "opcode": 0b00111011011},
    "shlqby":{"type": "RR", "opcode": 0b00111011111},
    "rotqby":{"type": "RR", "opcode": 0b00111011100},
    "rotqbybi":{"type": "RR", "opcode": 0b00111001100},
    "rotqbi":{"type": "RR", "opcode": 0b00111011000},
    "gbh":   {"type": "RR", "opcode": 0b00110110001},
    "gb":    {"type": "RR", "opcode": 0b00110110000},
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
    "nop":  {"type": "NOP", "opcode": 0b01000000001},
    "lnop": {"type": "NOP", "opcode": 0b00000000001},
    "stop": {"type": "STOP", "opcode": 0b00000000000}
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


def main():
    pass
