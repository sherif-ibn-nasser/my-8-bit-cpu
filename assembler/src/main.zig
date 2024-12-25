const std = @import("std");

const Condition = enum {
    // ZF
    Z,
    E,
    // ~ZF
    NZ,
    NE,
    // SF
    S,
    // ~SF
    NS,
    // ~(ZF | (SF ^ VF))
    G,
    NLE,
    // ~(SF ^ VF)
    GE,
    NL,
    // SF ^ VF
    L,
    NGE,
    // ZF | (SF ^ VF)
    LE,
    NG,
    // ~(ZF | CF)
    A,
    NBE,
    // ~CF
    NC,
    AE,
    NB,
    // CF
    C,
    B,
    NAE,
    // ZF | CF
    BE,
    NA,
    // VF
    V,
    // ~VF
    NV,
    // PF
    P,
    // ~PF
    NP,
    // AF
    HC,
    // ~AF
    NHC,

    const Self = @This();

    pub fn get_op_code(self: Self) u32 {
        return switch (self) {
            // ZF
            .Z, .E => 0x08,
            // ~ZF
            .NZ, .NE => 0x10,
            // SF
            .S => 0x20,
            // ~SF
            .NS => 0x30,
            // ~(ZF | (SF ^ VF))
            .G, .NLE => 0x40,
            // ~(SF ^ VF)
            .GE, .NL => 0x50,
            // SF ^ VF
            .L, .NGE => 0x60,
            // ZF | (SF ^ VF)
            .LE, .NG => 0x70,
            // ~(ZF | CF)
            .A, .NBE => 0x80,
            // ~CF
            .NC, .AE, .NB => 0x90,
            // CF
            .C, .B, .NAE => 0xA0,
            // ZF | CF
            .BE, .NA => 0xB0,
            // VF
            .V => 0xC0,
            // ~VF
            .NV => 0xD0,
            // PF
            .P => 0xE0,
            // ~PF
            .NP => 0xF0,
            // AF
            .HC => 0xE1,
            // ~AF
            .NHC => 0xF1,
        };
    }
};

const Instruction = enum {
    NOP,
    HLT,
    JMP,
    MOV,
    MUL,
    DIV,
    CMP,
    TEST,
    AND,
    ANDN,
    OR,
    NOR,
    XOR,
    XNOR,
    ADD,
    SUB,
    NOT,
    NEG,
    INC,
    DEC,
    SHR,
    SHL,
    SAR,
    MIRROR,

    const Self = @This();

    pub fn get_op_code(self: Self) u32 {
        return switch (self) {
            .MOV => 4,
            .CMP => 8,
            .TEST => 10,
            .AND => 0,
            .ANDN => 1,
            .OR => 2,
            .NOR => 3,
            .XOR => 4,
            .XNOR => 5,
            .ADD => 6,
            .SUB => 7,
            .NOT => 8,
            .NEG => 9,
            .INC => 10,
            .DEC => 11,
            .SHR => 12,
            .SHL => 13,
            .SAR => 14,
            .MIRROR => 15,
            else => 0,
        };
    }
};

const Reg = enum(u32) {
    AL = 0,
    BL = 1,
    CL = 2,
    DL = 3,
};

pub fn main() !void {
    // Get an allocator.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const path_null = std.os.argv[1];
    const path = std.mem.span(path_null);

    // Open a file.
    const in_file = try std.fs.cwd().openFile(path, .{});
    defer in_file.close();

    // const out_file = try std.fs.cwd().createFile("app.hex", .{});

    // Read the file into a buffer.
    const stat = try in_file.stat();
    const buffer = try in_file.readToEndAlloc(allocator, stat.size);
    defer allocator.free(buffer);

    // Iterate over the buffer.
    const instructions = std.mem.splitAny(u8, buffer, " ,\r\n");

    var iter = InstIter{ .iter = instructions };

    var i: u32 = 0;
    while (iter.next()) |inst| {
        const bytecode = map(inst, &iter);
        std.debug.print("{X:0>8}: {X:0>8}\n", .{ i, bytecode });
        i += 1;
    }
}

const InstIter = struct {
    iter: std.mem.SplitIterator(u8, .any),
    buf: [1024]u8 = undefined,

    const Self = @This();

    pub fn next(self: *Self) ?[]const u8 {
        const next_inst = self.iter.next() orelse return null;
        if (std.mem.eql(u8, next_inst, "")) {
            return self.next();
        } else {
            const len = next_inst.len;
            if (len > self.buf.len) {
                return null; // Handle the case where the buffer is too small
            }
            _ = std.ascii.upperString(self.buf[0..len], next_inst);
            return self.buf[0..len];
        }
    }
};

pub fn map(inst: []const u8, iter: *InstIter) u32 {
    var bytecode: u32 = 0;

    var mut_inst = inst;

    if (inst[inst.len - 1] == '?' and inst.len > 1) {
        const condition = std.meta.stringToEnum(Condition, inst[0 .. inst.len - 1]) orelse {
            std.debug.panic("Illegal condition `{s}`", .{inst});
        };

        mut_inst = iter.next() orelse {
            std.debug.panic("Expected instruction after condition `{s}`", .{inst});
        };

        bytecode = condition.get_op_code() << 3 * 8;
    }

    const en = std.meta.stringToEnum(Instruction, mut_inst) orelse {
        const num = std.fmt.parseUnsigned(i8, mut_inst, 0) catch {
            return 5;
        };

        std.debug.print("Num: {d}", .{num});
        // switch (num) {
        //     .int => {
        //         if (num.int > 0xFF) {
        //             std.debug.panic("Numbers should be between 0 and 0xFF", .{});
        //         }
        //         std.debug.print("Int: {X:0>2}", .{num.int});
        //     },
        //     .failure => {
        //         std.debug.print("Fail", .{});
        //     },
        //     else => {
        //         const x: u8 = 0xff;

        //         std.debug.print("Else int: {d}", .{x});
        //     },
        // }
        return 5;
    };

    switch (en) {
        .HLT => {
            bytecode = 0x01 << @intCast(2 * 8);
        },
        .JMP => {
            const arg = iter.next() orelse {
                std.debug.panic("Expected arg after JMP", .{});
            };

            const arg_mapped_to_reg = std.meta.stringToEnum(Reg, arg);

            if (arg_mapped_to_reg == null) {
                bytecode |= 0x02 << @intCast(2 * 8) | @as(u32, map_to_num(arg)) << 8;
            } else {
                bytecode |= 0x03 << @intCast(2 * 8) | @intFromEnum(arg_mapped_to_reg.?);
            }

            // TODO: support labels
        },
        .MUL => {
            const reg1 = iter.next() orelse {
                std.debug.panic("Expected 1st reg for MUL", .{});
            };
            const reg1_mapped = map_to_reg(reg1);

            const reg2 = iter.next() orelse {
                std.debug.panic("Expected 2nd reg for MUL", .{});
            };
            const reg2_mapped = map_to_reg(reg2);

            bytecode |= 0x06 << @intCast(2 * 8) | reg1_mapped << 8 | reg2_mapped;
        },
        .DIV => {
            const reg1 = iter.next() orelse {
                std.debug.panic("Expected 1st reg for DIV", .{});
            };

            const reg1_mapped = map_to_reg(reg1);

            const reg2 = iter.next() orelse {
                std.debug.panic("Expected 2nd reg for DIV", .{});
            };
            const reg2_mapped = map_to_reg(reg2);

            bytecode |= 0x07 << @intCast(2 * 8) | reg1_mapped << 8 | reg2_mapped;
        },
        .NOT, .NEG, .INC, .DEC, .MIRROR => {
            const arg = iter.next() orelse {
                std.debug.panic("Expected reg after {s}", .{mut_inst});
            };

            const arg_mapped_to_reg = std.meta.stringToEnum(Reg, arg);

            if (arg_mapped_to_reg == null) {
                std.debug.panic("Expected reg after {s}", .{mut_inst});
            } else {
                bytecode |= (0x1 | en.get_op_code()) << @intCast(2 * 8) | @intFromEnum(arg_mapped_to_reg.?);
            }
        },
        .MOV, .CMP, .TEST => {
            const reg = iter.next() orelse {
                std.debug.panic("Expected reg after {s}", .{mut_inst});
            };

            const reg_mapped = map_to_reg(reg);

            const arg = iter.next() orelse {
                std.debug.panic("Expected 2nd arg after {s}", .{mut_inst});
            };

            const arg_mapped_to_reg = std.meta.stringToEnum(Reg, arg);

            if (arg_mapped_to_reg == null) {
                bytecode |= en.get_op_code() << @intCast(2 * 8) | reg_mapped << 8 | map_to_num(arg);
            } else {
                bytecode |= (en.get_op_code() + 1) << @intCast(2 * 8) | reg_mapped << 8 | @intFromEnum(arg_mapped_to_reg.?);
            }
        },
        else => {
            const reg = iter.next() orelse {
                std.debug.panic("Expected reg after {s}", .{mut_inst});
            };

            const reg_mapped = map_to_reg(reg);

            const arg = iter.next() orelse {
                std.debug.panic("Expected 2nd arg after {s}", .{mut_inst});
            };

            const arg_mapped_to_reg = std.meta.stringToEnum(Reg, arg);

            if (arg_mapped_to_reg == null) {
                bytecode |= (0x10 | en.get_op_code()) << @intCast(2 * 8) | reg_mapped << 8 | map_to_num(arg);
            } else {
                bytecode |= en.get_op_code() << @intCast(2 * 8) | reg_mapped << 8 | @intFromEnum(arg_mapped_to_reg.?);
            }
        },
    }
    return bytecode;
}

pub fn map_to_reg(buf: []const u8) u32 {
    return @intFromEnum(std.meta.stringToEnum(Reg, buf) orelse {
        std.debug.panic("Invalid regestier value `{s}`", .{buf});
    });
}

pub fn map_to_num(buf: []const u8) u8 {
    return std.fmt.parseInt(u8, buf, 0) catch {
        std.debug.panic("Invalid number arg `{s}`", .{buf});
    };
}
