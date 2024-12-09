const std = @import("std");
const input = @embedFile("day5_input.txt");

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');

    var rules = std.StringHashMap(void).init(allocator);
    defer rules.deinit();

    // We use peek() here because when we reach the first report line we don't want the iterator
    // to advanced to it.
    while (line_it.peek()) |rule| {
        if (rule.len > 5) break;
        rules.put(rule, {}) catch unreachable;
        _ = line_it.next();
    }

    var result: u32 = 0;

    var report: [24]u32 = undefined;
    var rule: [5]u8 = undefined;

    while (line_it.next()) |update| {
        var num_it = std.mem.tokenizeScalar(u8, update, ',');

        var i: usize = 0;
        while (num_it.next()) |s| {
            report[i] = std.fmt.parseInt(u32, s, 10) catch unreachable;
            i += 1;
        }

        const n = i;

        i -= 1;
        while (i >= 1) : (i -= 1) {
            _ = std.fmt.bufPrint(&rule, "{d}|{d}", .{ report[i - 1], report[i] }) catch unreachable;
            if (!rules.contains(&rule)) break;
        }

        const correct_order = i == 0;
        if (correct_order) {
            const middle_num = report[n / 2];
            result += middle_num;
        }
    }

    std.debug.print("Answer = {d}\n", .{result});
}
