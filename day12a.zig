const std = @import("std");
const input = @embedFile("day12_input.txt");

const width: usize = 140;
var height: usize = 0;
var garden: [width * width]u8 = undefined;

const Coord = struct {
    x: i32,
    y: i32,

    pub fn index(self: Coord) usize {
        return @as(usize, @intCast(self.y)) * height + @as(usize, @intCast(self.x));
    }
};

const Plot = struct {
    letter: u8,
    coords: std.AutoHashMap(Coord, void),

    pub fn create(letter: u8, allocator: std.mem.Allocator) Plot {
        return .{
            .letter = letter,
            .coords = std.AutoHashMap(Coord, void).init(allocator),
        };
    }

    pub fn deinit(self: *Plot) void {
        self.coords.deinit();
    }

    pub fn perimeter(self: Plot) usize {
        var result: usize = 0;
        var coord_it = self.coords.keyIterator();
        while (coord_it.next()) |coord| {
            for (adjacent(coord.*)) |neighbour| {
                if (!self.coords.contains(neighbour)) {
                    result += 1;
                }
            }
        }
        return result;
    }

    pub fn price(self: Plot) usize {
        return self.coords.count() * self.perimeter();
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    var row_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (row_it.next()) |row| : (height += 1) {
        std.mem.copyForwards(u8, garden[height * width ..], row);
    }

    var plotted = std.AutoHashMap(Coord, void).init(allocator);
    defer plotted.deinit();

    var plots = std.ArrayList(Plot).init(allocator);
    defer {
        for (plots.items) |*plot| plot.deinit();
        plots.deinit();
    }

    for (0..height) |y_index| {
        for (0..width) |x_index| {
            const coord = Coord{ .x = @intCast(x_index), .y = @intCast(y_index) };
            if (try findPlot(allocator, coord, &plotted)) |plot| {
                try plots.append(plot);
            }
        }
    }

    var total_cost: usize = 0;
    for (plots.items) |plot| {
        const price = plot.price();
        total_cost += price;
    }

    std.debug.print("Answer = {d}\n", .{total_cost});
}

fn at(coord: Coord) ?u8 {
    if (coord.x < 0 or coord.x >= width or coord.y < 0 or coord.y >= height) return null;
    return garden[coord.index()];
}

fn adjacent(to: Coord) [4]Coord {
    return [_]Coord{
        .{ .x = to.x - 1, .y = to.y },
        .{ .x = to.x + 1, .y = to.y },
        .{ .x = to.x, .y = to.y - 1 },
        .{ .x = to.x, .y = to.y + 1 },
    };
}

fn findPlot(allocator: std.mem.Allocator, coord: Coord, plotted: *std.AutoHashMap(Coord, void)) !?Plot {
    if (plotted.contains(coord)) return null;
    try plotted.put(coord, {});

    const letter = at(coord) orelse return null;

    var plot = Plot.create(letter, allocator);
    try plot.coords.put(coord, {});

    var to_scan = std.ArrayList(Coord).init(allocator);
    defer to_scan.deinit();

    var scanned = std.AutoHashMap(Coord, void).init(allocator);
    defer scanned.deinit();

    try to_scan.appendSlice(adjacent(coord)[0..4]);

    while (to_scan.items.len > 0) {
        const neighbour = to_scan.pop();

        if (scanned.contains(neighbour)) continue;
        try scanned.put(neighbour, {});

        const neighbour_letter = at(neighbour) orelse continue;

        if (letter == neighbour_letter) {
            try plot.coords.put(neighbour, {});
            try plotted.put(neighbour, {});

            for (adjacent(neighbour)) |p| {
                try to_scan.append(p);
            }
        }
    }

    return plot;
}
