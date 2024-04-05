# Todo-nu

Yet another Todo Script which:

- Uses Nushell, Ripgrep and Git
- Is inspired from the todo.txt format
- Tries to be as simple as possible
- Works for me approach

## Inspiration

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

## Usage

```
tn => all open issues
tn --all => all issues
tn --done => all done issues
tn -p CAD => only open issues from Project CAD
tn --done -c team => only done issues from context team
tn -p CAD -c team => Combinations allowed
tn -l @ => List all @contexts or "+" for projects
```
Project and context can be multiple like -p BIM -p CAD

### WIP retrospective

```
tn -r 2021-01-01
```
Gives all issues from the git history,
that are not older than that date given.
For now doesn't give back the latest commit,
but also gives back still open and "closed but not deleted" items.
Should compare to what is still in use.
But can be combined with `tn --done -r $date`

# Configuration

The script expects a `tn.toml` file similar to the one in this repo in `~/.config`
Give it the directory to search for and a list of directories to exclude.

# TODO for Todo-nu

- [x] Support - [o] for half done indented lists
- [x] Take the project from the title of the last h1 upwards the file

- [x] Give it some colors and emojis 🤡
- [x] Give the possibility to exclude subdirectories from search TODO OS "Error 123" on windows
- [x] Give back all projects or contexts like: tn --list -p
- [x] Make a shuffle randomizer giving just one todo or context out if one is in dought 
- [x] Make a filter for @maybes or configurable words.
- [ ] Unify context, projet and exclude filters
- [ ] Add some tests from http://www.nushell.sh/book/testing.html 
- [ ] Make searchpaths a list
- [ ] Add a config for depth to show only unindented items per default
- [ ] Get the context and project filters into the retrospective
- [ ] Get the list feature into the retrospective as well
- [ ] Group issues by files where they came from
      Not shure where this is going. In Zettelkasten flat hierarchy style wiki,
      every topic should have its own file. So +project should be the title of 
      the file. Then +project should give a combination of the two,
      or could even be used for something else.

- [ ] Create a Link directly to the file and open it in $EDITOR
      see otn function, after that
- [ ] nvim +call cursor(<LINE>, <COLUMN>) for calling it directly on the line
- [ ] Due dates functionality @maybe

Priority should be the rank within the file,
or is there a simple better way to do this?
