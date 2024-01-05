// SPDX-License-Identifier: AGPL-3.0

#ifndef DEFS_H
#define DEFS_H 1

#include <stdint.h>

#define MAX_FILE_SIZE (1 << 10)

#define INODE_BEGIN 0xFB     // the beginning of an inode
#define INODE_END 0xFF       // the end of an inode
#define INODE_TYPE_FILE 0xAB // the file type
#define INODE_TYPE_DIR 0xAC  // the directory type
#define INODE_TYPE_LNK 0xAD  // the link type

#endif
