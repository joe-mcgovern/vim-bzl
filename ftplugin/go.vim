vim9script

import autoload 'bzl.vim'

command! -nargs=0 BazelFile :call BazelFile()
command! -nargs=0 BazelTest :call BazelTest()
nnoremap <buffer> <leader>bt :BazelTest<CR>

g:bzl_test_target_go = get(g:, "bzl_test_target_go", "go_default_test")

def BazelTest()
  const bzlPath = BzlPath()
  if bzlPath ==# ""
    return
  endif
  bzl.ExecuteCommand("test", bzlPath, BufferTestTarget())
enddef


def BazelFile()
  const bzlPath = BzlPath()
  if bzlPath ==# ""
    return
  endif
  echom "Would use bazel file: " .. bzlPath
enddef

def BzlPath(): string
  const nearest = bzl.NearestDirWithBzlFile(BufferTestTarget())
  if nearest ==# ""
    echom "ERROR: Could not locate nearest bazel file"
    return ""
  endif
  return bzl.ConvertAbsPathToBzlPath(nearest)
enddef

def BufferTestTarget(): string
  return bzl.BufferTestTarget(get(g:, "bzl_test_target_go"))
enddef
