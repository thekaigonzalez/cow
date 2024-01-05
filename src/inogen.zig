// SPDX-License-Identifier: AGPL-3.0

const std = @import("std");
const assert = std.debug.assert;

const defs = @cImport({
    @cInclude("defs.h"); // grabs INODE_BEGIN, INODE_END, and INODE_TYPES
});

const node = @cImport({
    @cInclude("node.h");
});

const mash = node.mash;

// generate inodes, allowing you to specify data and save to files

pub const inode = struct {
    name: i32,
    prop: i32,
    dir: i32 = -1,
    link: i32 = -1,
    which: i32 = defs.INODE_TYPE_FILE,

    data: std.ArrayList(i32),
    len: usize,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) inode {
        return inode{ .name = -1, .data = std.ArrayList(i32).init(allocator), .len = 0, .prop = defs.INODE_TYPE_FILE, .allocator = allocator };
    }

    pub fn append(self: *inode, value: i32) void {
        self.data.append(value) catch @panic("OOM");
        self.len += 1;
    }

    pub fn as_binary(self: *inode) []i32 {
        var format = std.ArrayList(i32).init(self.allocator);

        format.append(defs.INODE_BEGIN) catch @panic("OOM");
        format.append(self.which) catch @panic("OOM");
        format.append(self.name) catch @panic("OOM");
        format.append(self.dir) catch @panic("OOM");

        for (self.data.items) |item| {
            format.append(item) catch @panic("OOM");
        }

        format.append(defs.INODE_END) catch @panic("OOM");

        return format.toOwnedSlice() catch @panic("OOM");
    }

    pub fn setname(self: *inode, name: [*c]const u8) void {
        std.debug.print("setting name: {s}\n", .{name});
        self.name = @intCast(node.mash(name));
    }

    pub fn settypeflag(self: *inode, which: i32) void {
        self.which = which;
    }

    pub fn deinit(self: *inode) void {
        self.data.deinit();
    }
};

// allows an interface for iterating over inodes.
pub const inode_container = struct {
    inodes: std.ArrayList(inode),
    ptr: usize,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) inode_container {
        return inode_container{ .inodes = std.ArrayList(inode).init(allocator), .ptr = 0, .allocator = allocator };
    }

    pub fn append(self: *inode_container, n: inode) void {
        self.inodes.append(n) catch @panic("OOM");
    }

    /// returns a list of all inodes as binary
    pub fn rid(self: *inode_container) []i32 {
        var bytes = std.ArrayList(i32).init(self.allocator);

        for (0..self.inodes.items.len) |i| {
            bytes.appendSlice(self.inodes.items[i].as_binary()) catch @panic("OOM");
        }

        self.inodes.clearRetainingCapacity();

        return bytes.toOwnedSlice() catch @panic("OOM");
    }

    pub fn loadinodes(self: *inode_container, bytes: []i32) void {

        // load inodes

        // set ptr
        var pointer: i32 = 0;

        while (pointer < bytes.len) {
            var result: node.struct_cow_inode = undefined;

            // the current inode slice
            // skipping the beginning
            const now = bytes[@intCast(pointer)..];
            // how many bytes to skip
            const fwd = node.inodefwd(@ptrCast(now), &result);

            // if there was no movement
            if (fwd == 0 or fwd == -1) {
                break;
            }

            // add node info to new node
            var new = inode.init(self.allocator);

            // set basic information
            new.name = result.name;
            new.which = @intCast(result.ftype);
            new.dir = result.dir;

            var list = std.ArrayList(i32).init(self.allocator);
            defer list.deinit();

            // add all the data
            for (0..result.size) |i| {
                list.append(result.data[i]) catch @panic("OOM");
            }

            new.data = list.clone() catch @panic("OOM");

            self.append(new);

            pointer += fwd;
        }
    }
    // any functions beyond this point are designed
    // to sort and gather information on inodes,
    // like the common directories, etc.

    /// Get all nodes in (directory)
    pub fn getinodeswd(self: *inode_container, wd: i32) []inode {
        var nodes = std.ArrayList(inode).init(self.allocator);

        for (0..self.inodes.items.len) |i| {
            if (self.inodes.items[i].dir == wd) {
                nodes.append(self.inodes.items[i]) catch @panic("OOM");
            }
        }

        return nodes.toOwnedSlice() catch @panic("OOM");
    }

    pub fn deinit(self: *inode_container) void {
        self.inodes.deinit();
    }
};

pub fn main() !void {
    var Arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer Arena.deinit();

    const allocator = Arena.allocator();

    var test_node = inode.init(allocator);
    defer test_node.deinit();

    test_node.setname("test");
    test_node.append(1);
    test_node.append(2);
    test_node.append(3);
    test_node.append(4);

    var test_node2 = inode.init(allocator);
    defer test_node2.deinit();

    test_node2.setname("test again");
    test_node2.append(1);
    test_node2.append(2);
    test_node2.append(3);
    test_node2.append(4);
    test_node2.append(5);

    var container = inode_container.init(allocator);
    defer container.deinit();

    container.append(test_node);
    container.append(test_node2);

    const bytes = container.rid();

    std.debug.print("bytes = {any}\n", .{bytes});

    container.loadinodes(bytes);

    std.debug.print("inodes = {any}\n", .{container.inodes.items});

    std.debug.print("files with no directory:\n", .{});

    for (container.getinodeswd(-1)) |i| {
        std.debug.print("  filename hashed: {any}\n", .{i.name});
    }
}
