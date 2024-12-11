const std = @import("std");
const input = @embedFile("day7_input.txt");

const max_numbers = 12;

pub fn main() void {
    var total: i64 = 0;
    var numbers: [max_numbers]i64 = undefined;

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        const idx = std.mem.indexOf(u8, line, ":").?;
        const value = std.fmt.parseInt(i64, line[0..idx], 10) catch unreachable;

        var num_it = std.mem.tokenizeScalar(u8, line[idx + 1 ..], ' ');
        var i: usize = 0;
        while (num_it.next()) |num_str| : (i += 1) {
            numbers[i] = std.fmt.parseInt(i64, num_str, 10) catch unreachable;
        }

        if (solvable(value, numbers[0], numbers[1..i])) {
            total += value;
        }
    }

    std.debug.print("Answer = {d}\n", .{total});
}

fn solvable(value: i64, result: i64, numbers: []i64) bool {
    if (numbers.len == 0) return value == result;
    if (value < result) return false;

    const n = numbers[0];

    return solvable(value, result + n, numbers[1..]) or
        solvable(value, result * n, numbers[1..]);
}
