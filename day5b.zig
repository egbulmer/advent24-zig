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
    while (line_it.peek()) |line| {
        if (line.len > 5) break;
        rules.put(line, {}) catch unreachable;
        _ = line_it.next();
    }

    var result: u32 = 0;
    var update_nums: [24]u32 = undefined;

    while (line_it.next()) |line| {
        var num_it = std.mem.tokenizeScalar(u8, line, ',');

        var i: usize = 0;
        while (num_it.next()) |s| {
            update_nums[i] = std.fmt.parseInt(u32, s, 10) catch unreachable;
            i += 1;
        }

        if (isOrdered(update_nums[0..i], rules)) continue;

        while (!isOrdered(update_nums[0..i], rules)) {
            reorder(update_nums[0..i], rules);
        }

        const middle_num = update_nums[i / 2];
        result += middle_num;
    }

    std.debug.print("Answer = {d}\n", .{result});
}

fn isOrdered(update: []u32, rules: anytype) bool {
    var rule: [5]u8 = undefined;
    var i: usize = update.len - 1;
    while (i >= 1) : (i -= 1) {
        _ = std.fmt.bufPrint(&rule, "{d}|{d}", .{ update[i - 1], update[i] }) catch unreachable;
        if (!rules.contains(&rule)) return false;
    }
    return true;
}

fn reorder(update: []u32, rules: anytype) void {
    var rule: [5]u8 = undefined;
    var i: usize = update.len - 1;
    while (i >= 1) : (i -= 1) {
        _ = std.fmt.bufPrint(&rule, "{d}|{d}", .{ update[i - 1], update[i] }) catch unreachable;
        if (!rules.contains(&rule)) {
            std.mem.swap(u32, &update[i - 1], &update[i]);
        }
    }
}
