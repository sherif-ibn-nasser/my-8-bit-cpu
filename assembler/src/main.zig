const std = @import("std");

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

    var iter = InstIter.init(allocator, instructions);
    defer iter.free();

    var i: u32 = 0;
    while (iter.next()) |inst| {
        const bytecode = map(inst, &iter);
        std.debug.print("{X:0>8}: {X:0>8}\n", .{ i, bytecode });
        i += 1;
    }
}

const InstIter = struct {
    iter: std.mem.SplitIterator(u8, .any),
    allocator: std.mem.Allocator,
    allocated_strings: std.ArrayList([]u8),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, iter: std.mem.SplitIterator(u8, .any)) Self {
        return Self{
            .iter = iter,
            .allocator = allocator,
            .allocated_strings = std.ArrayList([]u8).init(allocator),
        };
    }

    pub fn next(self: *Self) ?[]const u8 {
        const next_inst = self.iter.next() orelse return null;
        if (std.mem.eql(u8, next_inst, "")) {
            return self.next();
        } else {
            // Allocate memory for the new string
            var output: []u8 = self.allocator.alloc(u8, next_inst.len) catch return null;
            // Convert `next_inst` to uppercase and copy it to `output`
            _ = std.ascii.upperString(output, next_inst);
            // Add the allocation to the list for later cleanup
            _ = self.allocated_strings.append(output) catch return null;
            // Return the immutable version of `output`
            return output[0..];
        }
    }

    pub fn free(self: *Self) void {
        for (self.allocated_strings.items) |item| {
            self.allocator.free(item);
        }
        self.allocated_strings.deinit();
    }
};

pub fn map(inst: []const u8, iter: *InstIter) u32 {
    const en = std.meta.stringToEnum(Instruction, inst) orelse {
        const num = std.fmt.parseUnsigned(i8, inst, 0) catch {
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

    var bytecode: u32 = 0;

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
            const reg2 = iter.next() orelse {
                std.debug.panic("Expected 2nd reg for MUL", .{});
            };

            const reg1_mapped = map_to_reg(reg1);
            const reg2_mapped = map_to_reg(reg2);

            bytecode |= 0x06 << @intCast(2 * 8) | reg1_mapped << 8 | reg2_mapped;
        },
        .DIV => {
            const reg1 = iter.next() orelse {
                std.debug.panic("Expected 1st reg for DIV", .{});
            };
            const reg2 = iter.next() orelse {
                std.debug.panic("Expected 2nd reg for DIV", .{});
            };

            const reg1_mapped = map_to_reg(reg1);
            const reg2_mapped = map_to_reg(reg2);

            bytecode |= 0x07 << @intCast(2 * 8) | reg1_mapped << 8 | reg2_mapped;
        },
        .NOT, .NEG, .INC, .DEC, .MIRROR => {
            const arg = iter.next() orelse {
                std.debug.panic("Expected reg after {s}", .{inst});
            };

            const arg_mapped_to_reg = std.meta.stringToEnum(Reg, arg);

            if (arg_mapped_to_reg == null) {
                std.debug.panic("Expected reg after {s}", .{inst});
            } else {
                bytecode |= (0x1 | en.get_op_code()) << @intCast(2 * 8) | @intFromEnum(arg_mapped_to_reg.?);
            }
        },
        .MOV, .CMP, .TEST => {
            const reg = iter.next() orelse {
                std.debug.panic("Expected reg after {s}", .{inst});
            };

            const arg = iter.next() orelse {
                std.debug.panic("Expected 2nd arg after {s}", .{inst});
            };

            const reg_mapped = map_to_reg(reg);

            const arg_mapped_to_reg = std.meta.stringToEnum(Reg, arg);

            if (arg_mapped_to_reg == null) {
                bytecode |= en.get_op_code() << @intCast(2 * 8) | reg_mapped << 8 | map_to_num(arg);
            } else {
                bytecode |= (en.get_op_code() + 1) << @intCast(2 * 8) | reg_mapped << 8 | @intFromEnum(arg_mapped_to_reg.?);
            }
        },
        else => {
            const reg = iter.next() orelse {
                std.debug.panic("Expected reg after {s}", .{inst});
            };

            const arg = iter.next() orelse {
                std.debug.panic("Expected 2nd arg after {s}", .{inst});
            };

            const reg_mapped = map_to_reg(reg);

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
