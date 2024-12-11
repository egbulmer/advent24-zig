const std = @import("std");
const input = @embedFile("day8_input.txt");

const map_size = 50;
const max_points = 4;

const Point = struct {
    x: i16,
    y: i16,

    pub fn index(self: Point) i16 {
        if (self.x < 0 or self.x >= map_size or self.y < 0 or self.y >= map_size) return -1;
        return self.y * map_size + self.x;
    }
};

const Frequency = struct {
    points: [max_points]Point = undefined,
    len: u8 = 0,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    var frequencies = std.AutoHashMap(u8, Frequency).init(allocator);
    defer frequencies.deinit();

    var row_it = std.mem.tokenizeScalar(u8, input, '\n');
    var y: i16 = 0;

    while (row_it.next()) |row| : (y += 1) {
        for (row, 0..) |ch, x| {
            if (ch == '.') continue;
            const point = Point{ .x = @intCast(x), .y = y };
            var frequency = frequencies.get(ch) orelse Frequency{};
            frequency.points[frequency.len] = point;
            frequency.len += 1;
            try frequencies.put(ch, frequency);
        }
    }

    var antinodes = std.AutoHashMap(i16, void).init(allocator);
    defer antinodes.deinit();

    var freq_it = frequencies.iterator();
    while (freq_it.next()) |entry| {
        const freq = entry.value_ptr;
        for (0..freq.len - 1) |i| {
            for (i + 1..freq.len) |j| {
                const indices = findAntinodes(freq.points[i], freq.points[j]);
                if (indices[0] >= 0) try antinodes.put(indices[0], {});
                if (indices[1] >= 0) try antinodes.put(indices[1], {});
            }
        }
    }

    std.debug.print("Answer = {d}\n", .{antinodes.count()});
}

fn findAntinodes(p1: Point, p2: Point) [2]i16 {
    const a1 = Point{ .x = p1.x + (p1.x - p2.x), .y = p1.y + (p1.y - p2.y) };
    const a2 = Point{ .x = p2.x + (p2.x - p1.x), .y = p2.y + (p2.y - p1.y) };
    return [2]i16{ a1.index(), a2.index() };
}
