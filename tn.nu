def load_config [] {
  let CONFIG = (open ~/.config/tn.toml)
  {
    "TODO_FILE_PATH": $CONFIG.path,
    "PARTIAL": $CONFIG.partial,
    "EXCLUDEDIR": $CONFIG.exclude,
    "LOGFILE": $CONFIG.logfile
  }
}

# Nuscript to filter all Todos from a Markdown Wiki
export def td [
    --all(-a) # All todos
    --done(-d) # Only done todos
    --project(-p): string = "" # All todos within a +project
    --context(-c): string  = "" # All todos within a @context
    --exclude(-e): string = "" # Exclude contexts like @maybe
    --retro(-r): string = "" # A retrospective for todos in git history
    --list(-l): string = "" # List all @contexts or +projects used.
    --rand(-x) # Pick a random todo
    --blame(-b) # include git blame in the output table
    --json(-j) # Output result as json
    --version(-v) # Version of todo-nu
        ] {

  let config = (load_config)

   let generate_todos = (($retro | is-empty) and ($list | is-empty))
   let list_contexts = ($retro | is-empty)
   let filter = (get_list_filter $all $done $config.PARTIAL)

     if $version {
         let version = "0.1.0"
         $version
      } else if $generate_todos {
         let td = generate_todos $config.TODO_FILE_PATH $config.EXCLUDEDIR $filter $project $context $config.LOGFILE
         let td_filtered = (filter_excluded_contexts $exclude $td | sort-by -i file)
         if $blame {
             let td_blamed_filtered = add_blame_info $td_filtered $config.TODO_FILE_PATH $config.LOGFILE
             if $rand { randomize $td_blamed_filtered } else {$td_blamed_filtered}
         } else {
             if $rand { randomize $td_filtered } else if $json { $td_filtered | to json } else { $td_filtered }
         }
      } else if $list_contexts {
           if $list == "@" {
             let td = generate_todos $config.TODO_FILE_PATH $config.EXCLUDEDIR $filter $project $context $config.LOGFILE
             let l = list_contexts $td
             if $rand { randomize $l } else {$l}
          } else if $list == "+" {
             let td = generate_todos $config.TODO_FILE_PATH $config.EXCLUDEDIR $filter $project $context $config.LOGFILE
             let l = list_projects $td
             if $rand { randomize $l } else {$l}
           } else { "Either specify '@' for contexts or '+' for projects" }
      } else {
         let r = (get_retrospective $retro $config.TODO_FILE_PATH $filter)
         if $rand { randomize $r } else {$r}
      }
}

def randomize [to_randomize] {
    let len = $to_randomize | length
    let r = random int ..$len
    $to_randomize | get $r
}

def generate_todos [
                    todo_file_path: path,
                    excludedir: list,
                    filter: string,
                    project: string,
                    context: string,
                    log: string
                  ]: nothing -> table {
         let excludes = (generate_excludes_list $todo_file_path $excludedir)
         let todos = (filter_todos $todo_file_path $filter $excludes $log)
         # Filter by project and context
         let tn = (get_project_context_filter $todos $project $context $log)
         # Parse it to a table
         let table = (parse_to_table $tn)
         let t_abs_path = (abs_path_2_file $table)
         let t_glyth = (replace_with_glyth $t_abs_path)
         $t_glyth
}

# Filter a table by the exclude word, if one is given, treated as a context
def filter_excluded_contexts [exclude: string todos: table]: nothing -> table {
    if ($exclude | is-empty) {
        $todos
    } else {
        $todos | where {|x| not ($x.item | str contains $"@($exclude)")}
    }
}

# Get a list of all @contexts beeing used
def list_contexts [todos: table]: nothing -> table {
    # Get all strings with the pattern "@something", but not if its a code in backticks
    # Doesn't catch multiline code blocks containing this pattern inside.
    let contexts = ($todos | get item | each {|e| parse --regex '(`[^`]*`)|@([^\s]+)' |
                    get capture1 | flatten}) | flatten
    $contexts | uniq --count | compact | where {|x| $x.value != ""} | sort-by -r count
}

# Get a list of all +projects beeing used. Although a project should actually be a file.
# One approach could be to count both the appearences of "+" and the same word as filename
#Not of much need for now.
def list_projects [todos: table]: nothing -> table {
    # Get all strings with the pattern "+something", but not if its a code in backticks
    # Doesn't catch multiline code blocks containing this pattern inside.
    let projects = ($todos | get item | each {|e| parse --regex '(`[^`]*`)|\+([^\s]+)' |
                    get capture1 | flatten}) | flatten
    $projects | uniq --count | compact | where {|x| $x.value != ""} | sort-by count
}

# Creates a filter string that can be used in rg later
def get_list_filter [all: bool, done: bool, partial: bool]: nothing -> string {

  if ($all and $done) {
     print ("You can't have --all and --done at the same time")
     exit
   }

   mut regTable = { open: {regex: '(- \[ \])'
                           enabled: true}
                    done: {regex: '(- \[x\])'
                           enabled: true}
                    partly: {regex: '(- \[o\])'
                           enabled: true} }

  if $all {
     $regTable
  } else if $done {
     $regTable.open.enabled = false
     $regTable.partly.enabled = false
  } else {
     if $partial == false { $regTable.partly.enabled = false }
     $regTable.done.enabled = false
  }

  let regex = ($regTable | transpose name value | get value |
               each {|v| if $v.enabled { [] | append $v.regex }} | flatten )
  $regex | str join "|"
}

# Uses ripgrep to filter all todos from regular text
# Excludes currently not working, see https://github.com/petrisch/todo-nu/issues/6
def filter_todos [path: string, regex: string, excludes: string, log: string]: nothing -> string {

    let out = (rg -tmd -n -e $regex $path err> $log) # $excludes $path --no-follow err> $log)
    $out
}

# Generates a string for ripgrep that excludes paths
def generate_excludes_list [path: string, excludes: list<string>]: nothing -> string {

    let $excludes_list = ""
    let $out = ($excludes_list | append ($excludes | each {|ex| "-g '!" + ($path | path join $ex) + "'"}) | str join " ")
    $out
}

# Get a List of all work items filtered by +project and @context
def get_project_context_filter [all_workitems: string, project: string, context: string, log: string]: nothing -> string {

  # Filter them by project or let the project_list be the list if there is no project given
  let project_list = (if (($project | str length) > 2 ) {
      $all_workitems | rg -w $"\\+($project err> $log)"
  } else { $all_workitems })

  # Filter above filter by context or let the context_filter be the project_list if there is no context given
  let context_list = (if (($context | str length) > 2 ) {
      $project_list | rg -w $"@($context err> $log)"
  } else { $project_list })

  $context_list
}

# Parse the string given by ripgrep to a table
def parse_to_table [todos_string: string] {
   $todos_string | lines| parse '{file}.md:{line}:{todo}] {item}' | move item --before file | move todo --before item
}

def abs_path_2_file [list: list] {
    $list | update file {|row| $row.file | path basename}
}

# Get the git blame for the last time a todo has been touched
def add_blame_info [todo: list, path: string, log: string] {
    cd $path
    let todo_blame = ($todo | insert blame blame)
    $todo_blame | par-each {|x|
      update blame (git blame -L ($x.line | append ["," $x.line] |
      str join "") ($x.file | append ".md" | str join "") err> $log |
        parse "{commit} {author} {date} {time}" | get date.0? )}
}

# Get a retrospective list of all DONE things in git
def get_retrospective [time: string, path: string, regex: string] {
    cd $path
    let time_rev = (($time | into datetime | into int) / 1000000000)
    # In the end we skip one, because we dont want the current commit in this
    # TODO I guess what we actually want are "those that have been deleted in the past"
    # So we should compare older commits to the current one and take some diff
    let revs = (run-external "git" "rev-list" "--all" $"--max-age=($time_rev)"
               | lines | skip 1)
    let r = (run-external "git" "grep" "-E" "-e" $regex ...$revs
            | lines | parse '{rev}:{file}:{todo_retro}' | select todo_retro | uniq)
    $r
}

# Open the file of the line specified with an editor.
export def otd [table: table, item_number: int] {
  let config = (load_config)
  let item = ($table | get $item_number)
  try {
    run-external ($env.EDITOR) ([($config.TODO_FILE_PATH), "/", ($item.file), ".md"] | str join) "-c" ($item.line)
  } catch {
    print $"Couldn't parse table to open in ($env.EDITOR)"
  }
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
