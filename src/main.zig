const std = @import("std");

fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();
        const Node = struct { value: T, next: ?*Node };

        head: ?*Node,

        fn init() Self {
            return .{
                .head = null,
            };
        }

        fn deinit(self: *Self, allocator: std.mem.Allocator) void {
            var it = self.head;

            while (it) |curr| {
                const next_node = curr.next;
                allocator.destroy(it);
                it = next_node;
            }
        }

        fn add(self: *Self, allocator: std.mem.Allocator, value: T) !void {
            const new_node = try allocator.create(Node);
            new_node.* = .{
                .next = null,
                .value = value,
            };

            if (self.head == null) {
                self.head = new_node;
                return;
            }

            var it = self.head.?;

            while (it.next != null) {
                it = it.next.?;
            }

            it.next = new_node;
        }

        fn pop(self: *Self) ?T {
            if (self.head == null) return null;
            var prev: *Node = undefined;
            var iterator = self.head.?;

            while (iterator.next != null) : (iterator = iterator.next.?) {
                prev = iterator;
            }

            prev.next = null;

            return iterator.value;
        }

        fn remove(self: *Self, allocator: std.mem.Allocator, value: T) bool {
            var prev: *Node = undefined;
            var iterator = self.head;

            while (iterator) |curr| : (iterator = curr.next) {
                if (curr.value == value) {
                    prev.next = curr.next;
                    allocator.destroy(curr);

                    return true;
                }
                prev = curr;
            }

            return false;
        }

        fn front(self: *Self, allocator: std.mem.Allocator, value: T) !void {
            const new_node = try allocator.create(Node);
            new_node.* = .{
                .next = self.head,
                .value = value,
            };

            self.head = new_node;
        }

        fn print(self: *Self) !void {
            var stdout_buffer: [1024]u8 = undefined;
            var stdout = std.fs.File.stdout().writer(&stdout_buffer);
            var output = &stdout.interface;

            var it = self.head;
            while (it) |*curr| : (it = curr.*.next) {
                try output.print("{any} ", .{curr.*.*.value});
            }

            try output.print("\n", .{});
            try output.flush(); // could be better
        }
    };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var llist = LinkedList(i32).init();

    try llist.add(allocator, 1);
    try llist.add(allocator, 5);
    try llist.add(allocator, 2);

    try llist.print();

    const last_element = llist.pop();
    if (last_element) |element| {
        std.debug.print("Popped element: {d}\n", .{element});
    }

    try llist.front(allocator, 69);

    const val: i32 = 1;
    _ = llist.remove(allocator, val);

    try llist.print();
}
