# Todo-nu

Yet another Todo Script which:

- Uses Nushell, Ripgrep and Git
- Is inspired from the todo.txt format and the Zettelkasten ad GTD methods
- Tries to be as simple as possible
- Works for me approach

## Inspiration

I use a wiki in markdown format for my personal documentation.
Since I am less driven by dealines and more driven by documentation and need to switch context rapidly. I like to have information next to each other like:

- "How to do things"
- "What still to do and the next action"

Thats why in Todo-nu every todo item can be listed along other markdown content like:

```
# Topic

This is some documentation

- [x] Give some more information about documentation +docu
- [ ] Publish new documentation version @deployment
- [ ] Advertise new version @maybe +todo-nu

```
Todo-nu parses only the todo lines and lets you filter them.

## Usage

```
td => all open issues
td --all => all issues
td --done => all done issues
td -p todo-nu => only open issues marked with project +todo-nu
td --done -c deployment => only done issues marked wirh context @deployment
td -p todo-nu -c deployment => combinations allowed
```
Even though -p works, its better to use projects by file,
which then is equivalent to a `td | where file==<projectname>` pipeline

### Exclude

There is two exclude mechanisms:

- Exclude subdirectories from the path in the config
- Exclude contexts eg. the "@maybe" context with `td -e maybe`

### List

Sometimes it makes sense to see where are the most todos.
That doesn't mean, there is more todo, but it gives an idea about where more activity is going on.

```
td -l @ => List all @contexts or "+" for projects
```
### Random

Gives a random todo for when you don't know what to pick up next.

```
td -x 
td --all -x => Works also for lists or combined
```

### WIP retrospective

```
td -r 2021-01-01
```
Gives all issues from the git history,
that are not older than that date given.
For now doesn't give back the latest commit,
but also gives back still open and "closed but not deleted" items.
Should compare to what is still in use.
But can be combined with `tn --done -r $date`

### Git blame

Adds a column to the todo list with the last date a todo has been modified.
This helps when doing reviews to find stuff that needs more love.

```
td -b
```
Only works for files directly in path, not in subdirectories.

## Configuration

The script expects a `tn.toml` file similar to the one in this repo in `~/.config`
Give it the directory to search for and a list of directories to exclude.
The logfile is mainly used to supress errors from git and ripgrep and is not properly handled,
but not optional.

## TODO for Todo-nu

- [x] Give it some colors and emojis 🤡
- [x] Give the possibility to exclude subdirectories from search TODO OS "Error 123" on windows
- [x] Give back all projects or contexts like: tn --list -p
- [x] Make a shuffle randomizer giving just one todo or context out if one is in dought 
- [x] Make a filter for @maybes or configurable words.
- [x] Add a git blame column option to display the last date a todo has been updated
- [x] Support - [o] for half done indented lists and make them optional
- [ ] Unify context, project and exclude filters
- [ ] Add some tests from http://www.nushell.sh/book/testing.html 
- [ ] Make searchpath a list for multiple todo sources
- [ ] Get the context and project filters into the retrospective
- [ ] Get the list feature into the retrospective as well
- [ ] Create a Link directly to the file and open it in $EDITOR
      like: nvim +call cursor(<LINE>, <COLUMN>) for calling it directly on the line
- [ ] Or make a nvim plugin, that gets the todos into a telescope fzf list
- [ ] Due dates functionality @maybe
- [ ] Add a config for depth to show only unindented items per default

Priority should be the rank within the file,
or is there a simple better way to do this?

## Non goals

Editing anything in a file. This is a task for the $EDITOR.
+project is rarely used, so combining this with the filename is not a goal anymore.
