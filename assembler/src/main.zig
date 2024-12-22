const std = @import("std");

const Instruction = enum {
    nop,
    hlt,
    jmp,
    mov,
    mul,
    div,
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

    while (iter.next()) |inst| {
        _ = map(inst, &iter);
    }
}

const InstIter = struct {
    iter: std.mem.SplitIterator(u8, .any),

    const Self = @This();

    pub fn next(self: *Self) ?[]const u8 {
        const next_inst = self.iter.next() orelse return null;
        if (std.mem.eql(u8, next_inst, "")) {
            return self.next();
        } else {
            return next_inst;
        }
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
    switch (en) {
        .mov => {
            // const reg = iter.next() orelse {
            //     std.debug.panic("Expected arg after MOV", .{});
            // };
            // const arg = iter.next() orelse {
            //     std.debug.panic("Expected arg after MOV", .{});
            // };

            // std.debug.print("MOV REG:{s}, ARG:{s}", .{ reg, arg });
        },
        .jmp => {
            if (iter.next()) |inst2| {
                std.debug.print("..JMP {s}", .{inst2});
            }
        },
        else => {
            std.debug.print("ELse {s}", .{inst});
        },
    }
    return 0;
}
