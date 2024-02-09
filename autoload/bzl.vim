vim9script

export def ExecuteCommand(command: string, path: string, target: string)
  const pathWithoutDotPrefix = substitute(path, '^\.', '', '')
  const cleanPath = substitute(pathWithoutDotPrefix, '^\/*', '', '')
  execute ":Start -wait=always bazel " .. command .. " //" .. cleanPath .. ":" .. target
enddef

export def ExecuteTest(path: string, target: string)
  ExecuteCommand("test", path, target)
enddef

export def ExecuteTestWithFilter(path: string, target: string, testFilter: string)
  ExecuteCommandWithOptions("test", path, target, "--test_filter='" .. testFilter .. "'")
enddef

export def ExecuteCommandWithOptions(command: string, path: string, target: string, args: string)
  const pathWithoutDotPrefix = substitute(path, '^\.', '', '')
  const cleanPath = substitute(pathWithoutDotPrefix, '^\/*', '', '')
  execute ":Start -wait=always bazel " .. command .. " //" .. cleanPath .. ":" .. target .. " " .. args
enddef

export def BufferTestTarget(default: string): string
  return get(b:, "bzl_test_target", default)
enddef

export def ConvertAbsPathToBzlPath(path: string): string
  const rootPath = PathToProjectRoot()
  # TODO: this is garbage.
  return path[len(rootPath) : ]
enddef

def PathToProjectRoot(): string
  const path = expand("%:p:h")
  const parts = split(path, "/")
  const home = getenv("HOME")
  var currentIndex = len(parts) - 1
  while currentIndex >= 0
    const currentParts = parts[0 : currentIndex]
    const pathSubset = "/" .. join(currentParts, "/")
    if pathSubset ==# home
      break
    endif
    if isdirectory(pathSubset .. "/.git")
      return pathSubset
    endif
    currentIndex -= 1
  endwhile
  return ""
enddef

export def NearestDirWithBzlFile(withNamedRule = ''): string
  const currDir = expand("%:p:h")
  const parts = split(currDir, "/")
  const home = getenv("HOME")
  var currentIndex = len(parts) - 1
  while currentIndex >= 0
    var currentParts = parts[0 : currentIndex]
    const pathSubset = "/" .. join(currentParts, "/")
    if pathSubset ==# home
      break
    endif
    const path = pathSubset .. "/BUILD.bazel"
    if filereadable(path) && ContainsRule(path, withNamedRule)
      return pathSubset
    endif
    currentIndex -= 1
  endwhile
  return ""
enddef

def ContainsRule(path: string, rule: string): bool
  if len(rule) == 0
    return true
  endif
  const lines = readfile(path)
  const index = match(lines, '^\s*name = "' .. rule .. '"')
  return index >= 0
enddef
