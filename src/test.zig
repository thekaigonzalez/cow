// SPDX-License-Identifier: AGPL-3.0

const std = @import("std");
const C = @cImport({
  @cInclude("node.h");
  @cInclude("defs.h");
});

pub fn main() !void {
  const mash = C.mash;
    const bytes = [_]i32{
    C.INODE_BEGIN, C.INODE_TYPE_FILE, mash("hello"),     0, 1, 2, 3, C.INODE_END,
    C.INODE_BEGIN, C.INODE_TYPE_FILE, mash("hello") + 1, 2,  1, 2, 3, C.INODE_END,
  };

  var result: C.struct_cow_inode = undefined;

    const inodefwd = C.inodefwd(&bytes, &result);
    
    std.debug.print("offset = {any}\n", .{inodefwd});

  std.debug.print("`hello' hashed = {any}\n", .{mash("hello")});
}
