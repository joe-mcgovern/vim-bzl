vim9script

import autoload 'bzl.vim'

command! -nargs=0 BazelTest :call BazelTest()
nnoremap <buffer> <leader>bt :BazelTest<CR>

g:bzl_test_target_go = get(g:, "bzl_test_target_go", "go_default_test")

def BazelTest()
  const nearest = bzl.NearestDirWithBzlFile()
  if nearest ==# ""
    echom "ERROR: Could not locate nearest bazel file"
    return
  endif
  const bzlPath = bzl.ConvertAbsPathToBzlPath(nearest)
  const cmd = bzl.BufferTestTarget(get(g:, "bzl_test_target_go"))
  bzl.ExecuteCommand("test", bzlPath, cmd)
enddef
