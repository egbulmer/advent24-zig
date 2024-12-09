const std = @import("std");
const input = @embedFile("day3_input.txt");

pub fn main() void {
    // Length of "mul(x,y)", the shortest valid multiplication.
    const min_size = 8;
    // Length of "mul(xxx,yyy)" the longest valid multiplication.
    const max_size = min_size + 4;

    var result: i32 = 0;

    var win_it = std.mem.window(u8, input, max_size, 1);
    while (win_it.next()) |s| {
        // String must be long enough for valid operation.
        if (s.len < min_size) continue;
        // String must start with 'mul('.
        if (!std.mem.eql(u8, s[0..4], "mul(")) continue;

        var start: usize = 4;
        var end = start + 1;

        // Advance while looking at a digit character or until we hit the end.
        while (end < s.len and isDigit(s[end])) end += 1;
        if (end >= s.len) continue;

        const x = std.fmt.parseInt(i32, s[start..end], 10) catch continue;

        // End should be pointing at ',' immediately before the second parameter.
        start = end + 1;
        end = start + 1;

        // Advance while looking at digit character or until we hit the end. When we are done
        // check that end is looking at a ')'.
        while (end < s.len and isDigit(s[end])) end += 1;
        if (end >= s.len or s[end] != ')') continue;

        const y = std.fmt.parseInt(i32, s[start..end], 10) catch continue;

        result += x * y;
    }

    std.debug.print("Answer = {d}\n", .{result});
}

fn isDigit(ch: u8) bool {
    return ch >= '0' and ch <= '9';
}
