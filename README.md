# Todo-nu

Yet another Todo Script which:

- Uses Nushell, Ripgrep and Git
- Is inspired from the todo.txt format
- Tries to be as simple as possible
- Works for me approach

# Inspiration

I use a vimwiki in markdown format for my personal documentation.
Since I am not heavily driven by dealines, but more driven by documentation,
I like to have the information about:

- "How to do things"
- "What still to do and todo next"

next to each other.
Thats why in Todo-nu every todo item is listed along other markdown content like:

```
# Topic

This is some documentation

- [ ] give some more information about documentation +docu

```
Todo-nu parses only the todo lines and lets you filter them.

# Usage

```
tn => all open issues
tn --all => all issues
tn --done => all done issues
tn -p CAD => only open issues from Project CAD
tn --done -c team => only done issues from context team
tn -p CAD -c team => Combinations allowed
Project and context can be multiple like -p BIM -p CAD
tn -r 2021-01-01 gives all issues from the git history,
      that are not older than that date => Experimental
```

# Configuration

The script expects a `tn.toml` file similar to the one in this repo in `~/.config`
Currently only with the path to the directory to parse.

# TODO for Todo-nu

- [x] Get basic functionality with filters for +project and @context
- [x] Support --all and --done switches 
- [x] Support - [o] for half done indented lists
- [x] Use toml config file for the path
- [x] Currently only parses text. Do this the nushell way with structured text. 
- [x] Take the project from the title of the last h1 upwards the file
- [x] What has been closed lately? Retrospective using git blame maybe
      => Won't do, probably not worth it

- [ ] Add come tests from http://www.nushell.sh/book/testing.html 
- [ ] Add a config for depth to show only unindented items per default
- [ ] Group issues by files where they came from
      Not shure where this is going. In Zettelkasten flat hierarchy style wiki,
      every topic should have its own file. So +project should be the title of 
      the file. Then +project should give a combination of the two.

- [ ] Give back all projects or contexts like: tn --list -p
- [ ] Make a filter for @maybes or configurable words.
- [ ] Create a Link directly to the file and open it in $EDITOR
      see otn function after that
- [ ] nvim +call cursor(<LINE>, <COLUMN>) for calling it directly on the line
- [ ] Due dates functionality @maybe
- [ ] Give it some colors and emojis 🤡  

Priority should be the rank within the file,
or is there a simple better way to do this?
