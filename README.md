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
tn +CAD @team => Combinations allowed
Project an context can be multiple like -p BIM -p CAD
```

# TODO for Todo-nu

- [X] Get basic functionality with filters for +project and @context
- [X] Support --all and --done switches 
- [X] Support - [o] for half done indented lists
- [X] Use toml config file for the path
- [ ] Currently only parses text. Do this the nushell way with structured text. 
- [ ] Group the issues into the files where they came from which maybe leaves +project beside
- [ ] Take the project from the title of the last h1 upwards the file
- [ ] Give back all projects or contexts like: tn --list -p
- [ ] Create a Link directly to the file and open it in $EDITOR
- [ ] What has been closed lately? Retrospective using git blame maybe
- [ ] Maybe later due dates
- [ ] Priority should be the rank within the file
