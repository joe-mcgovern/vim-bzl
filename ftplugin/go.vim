vim9script

import autoload 'bzl.vim'

command! -nargs=0 BazelFile :call BazelFile()
command! -nargs=0 BazelTest :call BazelTest()
command! -nargs=0 BazelTestNearest :call BazelTestNearest()
# bta -> bazel test all (e.g. all tests within package)
nnoremap <buffer> <leader>bta :BazelTest<CR>
# btn -> bazel test nearest
nnoremap <buffer> <leader>btn :BazelTestNearest<CR>

g:bzl_test_target_go = get(g:, "bzl_test_target_go", "go_default_test")

def BazelTest()
  const bzlPath = BzlPath()
  if bzlPath ==# ""
    return
  endif
  bzl.ExecuteTest(bzlPath, BufferTestTarget())
enddef

def BazelTestNearest()
  # b flag indicates we are doing a backwards (e.g. upwards) search
  # c flag indicates that a match under the cursor is fine too
  const searchPattern = '^func\( (.*)\)\? \(Test.*\)('
  var line = search(searchPattern, 'bc')
  if line ==# 0
    # if we can't find it above us, let's look beneath
    const downwardLine = search(searchPattern)
    if downwardLine ==# 0
      # if there are no matches, see if the user wants to run the suite
      # against the whole package
      echom "bazel debug: could not find test with pattern"
      ConfirmRunSuite()
      return
    endif
    line = downwardLine
  endif
  const lineContent = getline(line)
  const testName = GetTestFilterFromLine(lineContent)
  if testName ==# ""
    echom "bazel debug: could not get test filter from line"
    ConfirmRunSuite()
    return
  endif
  const bzlPath = BzlPath()
  if bzlPath ==# ""
    return
  endif
  const promptResult = confirm("Run test with filter? " .. testName, "&Yes\n&No\n&Run entire suite")
  if promptResult ==# 1
    bzl.ExecuteTestWithFilter(bzlPath, BufferTestTarget(), testName)
  elseif promptResult ==# 2
    return
  elseif promptResult ==# 3
    BazelTest()
    return
  endif
enddef

def GetTestFilterFromLine(line: string): string
  var words = split(line, " ")
  var suiteName = ""
  var testName = ""
  # get the suite name if there is one
  if len(words) >= 3
    if words[1] =~# "^(" && words[2] =~# "^\*.*)"
      const wordWithoutStar = substitute(words[2], "*", "", "")
      suiteName = substitute(wordWithoutStar, ")", "", "")
    endif
  endif
  # get the test name
  for word in words
    if word =~# "^Test.*("
      var parsedWord = split(word, "(")
      testName = parsedWord[0]
      break
    endif
  endfor
  if len(suiteName) > 0
    return suiteName .. "/" .. testName
  endif
  return testName
enddef

def ConfirmRunSuite()
  const promptResult = confirm("could not find nearest test, run entire suite?", "&Yes\n&No")
  if promptResult ==# 1
    BazelTest()
  else
    echom "canceled test request"
    return
  endif
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
