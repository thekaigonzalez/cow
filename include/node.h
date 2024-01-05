// SPDX-License-Identifier: AGPL-3.0

#ifndef NODE_H
#define NODE_H 1

#include <stdint.h>
#include <stdlib.h>

#include "defs.h"

/*
  holds different types for inodes, `FILE` is the definition for a node that
  strictly holds a file's contents in ASCII/Unicode format, since COW is 32-bit

  files specify a directory, directories are labels which point to other files.

  links point to other files.
*/
enum cow_inode_t
{
  NFILE,     // regular file, contains the file's contents, without encoding
  NDIR,      // a directory, which files can be accessed through.
  NLINK,     // a link to another file
  NOT_INODE, // not an inode
};

struct cow_inode
{
  int32_t dir;                 // the directory this file is in
  int32_t name;                // the name of the file
  int32_t link;                // the link to another file (it's name hashed)
  int32_t data[MAX_FILE_SIZE]; // the file's contents
  int32_t corrupt;             // whether the inode is corrupted
  uint32_t size;               // the size of the file

  enum cow_inode_t ftype; // the type of the inode
};

struct cow_info
{
  size_t inode_count;      // the amount of inodes in the given input
  size_t corrupted_inodes; // the amount of corrupted inodes
  size_t is_valid;         // whether the input is corrupted
  size_t inodes_size;      // the size of the input in bytes
};

/* hashes a string into a 32-bit number */
const int32_t mash (const char *);

/* walks SRC and sets all information to RESULT
returns the offset to the next node, meaning how many bytes to skip over.
 */
const int32_t inodefwd (const int32_t *src, struct cow_inode *result);

/* updates an examination on SRC */
const int inodeex (const int32_t *src, struct cow_info *info);

#endif
