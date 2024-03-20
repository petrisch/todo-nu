# Nuscript to filter all Todos from a Markdown Wiki

export def td [
    --all(-a) # All todos
    --done(-d) # Only done todos
    --project(-p): string = "" # All todos within a +project
    --context(-c): string  = "" # All todos within a @context
    --retro(-r): string = "" # A retrospective for todos in git history
    --list(-l) # List all @contexts used
    --version(-v) # Version of todo-nu
        ] {

   let generate_todos = (($retro | is-empty) and ($list == false))
   let list_contexts = ($retro | is-empty)

    # The path to parse
    let CONFIG = (open ~/.config/tn.toml)
    let TODO_FILE_PATH = $CONFIG.path
    # let TODO_FILES = ($TODO_FILE_PATH + "/**/*.md")
    let FILTER = (get_list_filter $all $done)
    let EXCLUDEDIR = $CONFIG.exclude

     if $version {
         let version = "0.0.3"
         $version
      } else if $generate_todos {
         let td = generate_todos $TODO_FILE_PATH $EXCLUDEDIR $FILTER $project $context
         $td
      } else if $list_contexts {
         let td = generate_todos $TODO_FILE_PATH $EXCLUDEDIR $FILTER $project $context
         let l = list_contexts $td
         $l
      } else {
         let r = (get_retrospective $retro $TODO_FILE_PATH $FILTER)
         $r
      }
}

def generate_todos [todo_file_path: path,
                    excludedir: list,
                    filter: string,
                    project: string,
                    context: string] {
         let excludes = (generate_excludes_list $todo_file_path $excludedir)
         let todos = (filter_todos $todo_file_path $filter $excludes)
         # let filtered = (filter_excludes $todos $EXCLUDEDIR)
         # Filter by project and context
         let tn = (get_project_context_filter $todos $project $context)
         # Parse it to a table
         let table = (parse_to_table $tn)
         let t_abs_path = (abs_path_2_file $table)
         let t_glyth = (replace_with_glyth $t_abs_path)
         $t_glyth
}

# Get a list of all @contexts beeing used 
def list_contexts [todos: table] {
    # Get all strings with the pattern "@something", but not if its a code in backticks
    # Doesn't catch multiline code blocks containing this pattern inside.
    let contexts = ($todos | get item | each {|e| parse --regex '(`[^`]*`)|@([^\s]+)' |
                    get capture1 | flatten}) | flatten
    $contexts | uniq --count | compact | filter {|x| $x.value != ""}
}

def get_list_filter [all: bool, done: bool] {

  if ($all and $done) {
     echo "you can't have --all and --done at the same time"
     exit
   }

   let open_str = '(- \[ \])'
   let done_str = '(- \[x\])'
   let partly_str = '(- \[o\])'

  if $all {
     let regex = ($open_str + '|' + $done_str + '|' + $partly_str)
     $regex

  } else if $done {
     let regex = ($done_str + '|' + $partly_str)
     $regex

  } else {
     let regex = $open_str
     $regex
  }
}

def filter_todos [path: string, regex: string, excludes: string] {

    let out = (rg -tmd -n -e $regex $excludes $path --no-follow)
    $out
}

def generate_excludes_list [path: string, excludes: list<string>] {

    let $excludes_list = ""
    # let $out = ($excludes_list | append ($excludes | each {|ex| "-g '!" + ($path | path join $ex) + "\\*'"}) | str join " ")
    let $out = ($excludes_list | append ($excludes | each {|ex| "-g '!" + ($path | path join $ex) + "'"}) | str join " ")
    # let $out = "-g '!{" + ($excludes | each {|ex| ($path | path join $ex + "\\*', ")} | str join "") + "}"
    $out
}

# Get a List of all Work items filtered by +project and @context
def get_project_context_filter [all_workitems: string, project: string, context: string] {

  # Filter them by project or let the project_list be the list if there is no project given
  let project_list = (if (($project | str length) > 2 ) {
      $all_workitems | rg -w $"\\+($project)"
  } else { $all_workitems })

  # Filter above filter by context or let the context_filter be the project_list if there is no context given
  let context_list = (if (($context | str length) > 2 ) {
      $project_list | rg -w $"@($context)"
  } else { $project_list })

  # Print it out
  $context_list
}

# TODO, Its called a list, but IS a string. Can you see that?
def parse_to_table [list: string] {
   $list | lines| parse '{file}.md:{line}:{todo}] {item}' | move item --before file | move todo --before item
}

def abs_path_2_file [list: list] {
    $list | update file {|row| $row.file | path basename}
}

# Get a retrospective list of all DONE things in git
# - [ ] Get the regex into the retrospective as well
def get_retrospective [time: string path: string regex: string] {
    cd $path
    let time_rev = (($time | into datetime | into int) / 1000000000)
    # In the end we skip one, because we dont want the current commit in this
    # TODO I guess what we actually want are "those that have been deleted in the past"
    # So we should compare older commits to the current one and take some diff
    let revs = (run-external --redirect-stdout "git" "rev-list" "--all" $"--max-age=($time_rev)" 
               | lines | skip 1)
    let r = (run-external --redirect-stdout "git" "grep" "-E" "-e" $regex ...$revs 
            | lines | parse '{rev}:{file}:{todo_retro}' | select todo_retro | uniq)
    $r
}

# Open the file of the line specified with an editor
# Doesn't work yet, because the table is out of the scope. Maybe use a module for that.
def otd [table: string, line_number: string] {
    nvim ([$table.file.$line_number, ".md"] |str join)
    # nvim ([(td -c team).file.0, ".md"] |str join)  # This works on cli
}

# Replace the todo with some fancy stuff. The todo arrives like this "  - [x "
def replace_with_glyth [list: table] {
    let t = ($list | each {|td| update todo {get_glyth (($td.todo | into string | parse '{x}[{item}').item.0)}})
    $t
}

def get_glyth [key] {

    let glyths = ({ 
        " ": 😏
        "x": 😀
        "o": 🤔
        "waiting": ⏳ #  For future use
        "team": 👥 #  For future use
        "date": ⏰ #  For future use
        "sprint": 🏃 #  For future use
    })

    ($glyths | get $key)
}

# def parse_depth [depth] {
    
# }

# export identify_todo [text] {
    
#    let indent = "    "
#    let mark_pattern = {partly: 'o', done: 'x', open: ' '}
#    let tasks = {task: "- \[$mark_pattern\]", subtask: "$indent- \[$mark_pattern\]"}

#    match $text {$task.task}, _ => { 'no valid todo, wrong parse' }
# }
