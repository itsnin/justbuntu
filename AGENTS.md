# agents guide

this file is the single source of truth for any person ai or agent working on this project read it fully before touching any code it covers design philosophy architecture code style review constraints verification discipline and the why behind every non-obvious decision

if you are an ai agent read the whole file do not skim

## what this project is

[one or two short paragraphs describing what the project does who it is for and what "done right" looks like for it avoid marketing language state the actual constraint that defines success]

## design philosophy

document the identity of this project here what makes an implementation feel like this project and not a generic default state the concrete decision not just the vibe pixel sizes color values thresholds file formats performance budgets whatever actually encodes the choice and then state why that value was chosen and what it was chosen over a philosophy line that could describe any project is not a philosophy line

### [principle name for example "minimal not decorated"]

[the concrete rule that encodes the principle and the reasoning behind it]

## architecture

### file layout

```
project/
    [entry point]                short description of what it does
    [core module or folder]/     one line per file or folder describing its responsibility
    [config or schema]/          one line describing what it governs
    [tests]/                     one line describing what it covers
```

document the actual layout above one line per top level file or folder is usually enough only describe files a newcomer would not guess

### execution and module boundaries

if the runtime enforces real boundaries between execution contexts for example a browser process and a worker a main thread and a background service a privileged and unprivileged context document them here name exactly what may and may not cross the boundary and state the actual consequence of violating it a build failure a runtime crash a review rejection not just that it is "not allowed" if no such boundary exists for this project delete this subsection rather than leaving it empty

## code style

### comments

- all comments are lowercase no exceptions unless a capital letter is required to preserve meaning for example `curl -fsSL` must keep the capital `S` and `L` because they are case-sensitive flags
- no punctuation in comments no periods no commas no exclamation marks no question marks unless punctuation changes meaning
- explain why not what the code already shows what it does
- no block comment boxes no doc-comment banners like jsdoc or doxygen use the language's plain single-line comment syntax only
- no references to other projects by name in comments
- no llm-smell phrases like "here we" "let's" "we need to" "note that" "important:" "todo" "fixme"
- for obscure or uncommon code provide both what and why for common code provide only why
- provide verified working links whenever possible prefer primary or official documentation over blog posts
- maximum three consecutive comment lines without intervening code the fourth line must be code or the structure must be refactored to interleave comments and code comments are annotations not paragraphs

### code structure

- split logic into many small files each with a single responsibility
- keep the entry point as small as possible it should only wire things together
- keep setup and teardown logic next to each other for easy review
- one concept per file one file per concept
- prefer pure functions with no side effects in utility files
- every resource acquired during setup is released during teardown if you add a new resource you must add its cleanup in the corresponding teardown path
- [state the project's language and build constraints here for example no typescript no build step or whatever actually governs this codebase]

### anti ai-code smells

- do not wrap standard api calls in try/catch blocks
- do not use try/catch to silence errors that should never happen return null instead
- try/catch is legitimate only for genuine external failure points:
  - file io reading writing to disk files can be deleted corrupt or permission denied
  - parsing data that originated outside the code
  - reading data owned by another process or application
  - configuration or settings values that users could manually edit
- when catching always explain why the operation can genuinely fail
- for bundled or packaged resource failures surface the error through the project's normal logging or error-reporting path so it is not silently swallowed
- do not use optional chaining `?.` or nullish coalescing `??` or your language's equivalent for values guaranteed to exist
- do not add defensive null checks that mask bugs instead of handling them
- do not add "just in case" code for situations that cannot occur
- do not add comments that describe what a line does only describe why

### review discipline

- before producing final output read every single line you wrote
- look for potential issues on every line not just the line you are currently editing
- when fixing a bug check whether the same bug pattern exists elsewhere in the codebase
- do not assume a fix works verify it against the actual code

## verification discipline

- treat every factual claim as a hypothesis until you have stated your actual basis for it before answering ask yourself am i recalling this from training data or did i just verify it if it is the former say so
- tag factual claims dates statistics current events technical specs prices laws who holds what position version numbers with their basis do not blend them silently into one confident paragraph use something close to verified via [tool or source] just now / from training data may be outdated or wrong / not verified confirm independently
- if tools are available use them for anything time sensitive numeric or checkable a completed search is not the same as a correct citation after retrieving a source re-read it and confirm the summary actually matches before presenting it as confirmed give the real url retrieved not a plausible looking one if a live source cannot be reached say so explicitly rather than presenting an unverified claim as fact
- if tools are not available never claim to have searched checked or verified something never invent a citation link or source name to sound credible say plainly this cannot be verified it is from training data and could be stale or wrong
- before finalizing a nontrivial claim ask what would prove this wrong is there a more recent or more authoritative source that could contradict it if there is a plausible way the claim is wrong say so instead of smoothing over it
- a broken or made up looking url is worse than no url if there is no real verified link do not give one say there is not one
- distinguish widely believed from confirmed popular belief and common knowledge are not the same as verified fact flag when repeating a common claim that has not been personally checked
- when corrected re-check do not immediately flip to agreeing and do not reflexively defend the original claim either re-examine the actual basis for both claims then say honestly which one holds up or if it is genuinely unclear

## testing

### static analysis

[name the actual linter type checker or static analyzer for this project and the exact command to run it]

### build and syntax check

[state the actual command that proves the code parses compiles or builds cleanly before it is considered done]

### manual testing

[state the actual target environments browsers operating systems runtime or platform versions the project supports test the newest supported target first then at least one older one if applicable the project should behave identically across all supported targets]
