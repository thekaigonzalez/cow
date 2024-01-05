// src/node.c
// SPDX-License-Identifier: AGPL-3.0

#include "node.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

const int32_t
mash (const char *n)
{
  if (!n)
    {
      return 0;
    }

  uint32_t r = 0;

  while (*n)
    {
      r = r * 33 + *n++;
    }

  return r;
}

const int32_t
inodefwd (const int32_t *src, struct cow_inode *result)
{
  int32_t offset = 0;

  if (!src)
    {
      return 0;
    }

  if (*src != INODE_BEGIN)
    {
      printf("Err\n");
      return 0; // or handle error as needed
    }

  offset++;

  switch (*++src)
    {
      // TODO: implement directories and links
    case INODE_TYPE_FILE:
      {
        // file semantics
        // TYPE NAME DIR <contents> <END_INODE>

        offset++;
        result->ftype = NFILE;
        result->name = *++src;
        offset++;
        result->dir = *++src;
        offset++;
        result->size = 0;
        result->corrupt = 0;

        (void)(*src++); // skip past the dir

        offset++;

        while (*src != INODE_END)
          {
            result->data[result->size++] = *src++;
            offset++;
          }
      }
      break;
    default:
      return 0; // or handle error as needed
    }

  return offset; // return the updated pointer
}

const int
inodeex (const int32_t *src, struct cow_info *info)
{
  if (!src || !info || !(*src))
    {
      return 1;
    }

  info->is_valid = 1;
  info->corrupted_inodes = 0;
  info->inode_count = 0;
  info->inodes_size = 0;

  if (*src != INODE_BEGIN)
    {
      info->is_valid = 0;
    }

  size_t inodew_createcount = 0;
  size_t inode_count = 0;

  while (*src)
    {
      info->inodes_size++;

      if (!(*src))
        {
          return 1;
        }

      switch (*src)
        {
        case INODE_BEGIN:
          {
            inodew_createcount++;
          }
          break;
        case INODE_END:
          {
            inodew_createcount--;
            inode_count++; // only count proper inodes, corrupted inodes are
                           // stored in info->corrupted_inodes
          }
          break;
        default:
          break;
        }

      (void)(*src++);
    }

  if (inodew_createcount)
    {
      info->corrupted_inodes = inodew_createcount;
    }

  info->inode_count = inode_count;

  return 0;
}
