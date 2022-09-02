vim9script

command! -nargs=0 BazelTestCurrent :call BazelActionAgainstTargetUnderCursor("test")
command! -nargs=0 BazelBuildCurrent :call BazelActionAgainstTargetUnderCursor("build")
command! -nargs=0 BazelRunCurrent :call BazelActionAgainstTargetUnderCursor("run")
command! -nargs=1 BazelCurrent :call BazelActionAgainstTargetUnderCursor(<f-args>)
nnoremap <buffer> <leader>bt :BazelTestCurrent<cr>
nnoremap <buffer> <leader>bb :BazelBuildCurrent<cr>
nnoremap <buffer> <leader>br :BazelBuildCurrent<cr>

# * TODO: Check if dispatch is installed before using it
# * TODO: This should be robustified so that tests can be run from within a go file.
# Something like: Bazel test :go_default_library
# * TODO: Write function for getting nearest bazel file (current dir or above)
# * TODO: Write command that supports auto-completion for bzl target from
# within file
# * TODO: Write help doc
# * TODO: write readme
def BazelActionAgainstTargetUnderCursor(bzl_cmd: string)
  const bzl_target = GetNameOfTargetUnderCursor()
  if bzl_target ==# ""
    echom "ERROR: Could not find bazel target"
  endif
  const path = PathFromProjectRoot()
  execute ":Start -wait=always bazel " .. bzl_cmd .. " /" .. path .. ":" .. bzl_target
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
