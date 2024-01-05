// src/ll.c
// SPDX-License-Identifier: AGPL-3.0

#include "node.h"

#include <stdio.h>

int
main (void)
{
  const int32_t TEST_NAME = 0x41;
  const int32_t bytes[] = {
    INODE_BEGIN, INODE_TYPE_FILE, TEST_NAME,     -1, 1, 2, 3, INODE_END,
    INODE_BEGIN, INODE_TYPE_FILE, TEST_NAME + 1, 2,  1, 2, 3, INODE_END,
  };

  struct cow_info info;

  if (inodeex (bytes, &info))
    {
      return 1;
    }

  printf("corrupted inodes: %ld\n", info.corrupted_inodes);
  printf("inode count: %ld\n", info.inode_count);
  printf("is valid inode code: %ld\n", info.is_valid);
  printf("size of block: %ld bytes\n", info.inodes_size);

  // const int32_t *bytes_ptr = bytes;

  // struct cow_inode r, r2;

  // bytes_ptr = inodefwd (bytes_ptr, &r);
  // bytes_ptr = inodefwd (bytes_ptr, &r2);

  // printf ("%d\n", r.dir);
  // printf ("%d\n", r.name);

  // for (int i = 0; i < r.size; i++)
  //   {
  //     printf ("char: %d\n", r.data[i]);
  //   }

  // printf ("%d\n", r2.dir);
  // printf ("%d\n", r2.name);

  // for (int i = 0; i < r2.size; i++)
  //   {
  //     printf ("char: %d\n", r2.data[i]);
  //   }

  return 0;
}
