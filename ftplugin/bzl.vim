vim9script

if exists("g:has_loaded_bzl")
  finish
endif

g:has_loaded_bzl = 1

command! -nargs=0 BazelTestCurrent :call BazelTestCurrent()
command! -nargs=0 BazelBuildCurrent :call BazelBuildCurrent()
nnoremap <buffer> <leader>bt :BazelTestCurrent<cr>
nnoremap <buffer> <leader>bb :BazelBuildCurrent<cr>

# * Check if dispatch is installed before using it
# * Add BazelRunCurrent
# * This should be robustified so that tests can be run from within a go file.
def BazelTestCurrent()
  const bzl_target = GetNameOfTargetUnderCursor()
  if bzl_target ==# ""
    echom "ERROR: Could not find bazel target"
  endif
  const path = PathFromProjectRoot()
  execute ":Start -wait=always bazel test /" .. path .. ":" .. bzl_target
  call setpos(".", save_pos)
enddef

def BazelBuildCurrent()
  const bzl_target = GetNameOfTargetUnderCursor()
  if bzl_target ==# ""
    echom "ERROR: Could not find bazel target"
  endif
  const path = PathFromProjectRoot()
  echom ":Start -wait=always bazel build /" .. path .. ":" .. bzl_target
  execute ":Start -wait=always bazel build /" .. path .. ":" .. bzl_target
enddef

def GetNameOfTargetUnderCursor(): string
  const save_pos = getpos(".")
  search("^.*(", "b")
  search("name =")
  const line = getline(".")
  const result = matchstrpos(line, '".*"')
  const start_pos = result[1]
  const end_pos = result[2]
  if start_pos == -1 || end_pos == -1
    return ""
  endif
  # the matched word includes the surrounding quotes. Using start_pos + 1
  # removes the quote on the left side. Additionally, end_pos is the end
  # index + 1. So, using -2 to remove get the correct indexing and then
  # remove the right quote
  const bzl_target = line[start_pos + 1 : end_pos - 2]
  echom "Got bazel target: " .. bzl_target
  setpos(".", save_pos)
  return bzl_target
enddef

def PathFromProjectRoot(): string
  var path = expand("%:p:h")
  var parts = split(path, "/")
  var currentIndex = len(parts) - 1
  var home = getenv("HOME")
  var pathToReplace = home
  while currentIndex >= 0
    var currentParts = parts[0 : currentIndex]
    var pathSubset = "/" .. join(currentParts, "/")
    if pathSubset ==# home
      break
    endif
    if isdirectory(pathSubset .. "/.git")
      pathToReplace = pathSubset
      break
    endif
    currentIndex -= 1
  endwhile
  return path[len(pathToReplace) : ]
enddef
