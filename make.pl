# SPDX-License-Identifier: AGPL-3.0

use strict;
use warnings;

use File::Which;

my $bin = which('zig');
if (! $bin) {
  die 'zig not found';
}

`zig cc src/test.zig src/node.c -o test -I ./include`;
`zig cc src/inogen.zig src/node.c -o test-nodezig -I ./include`;
`gcc src/ll.c src/node.c -o low-level -I ./include -g`;

