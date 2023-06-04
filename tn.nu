# Nuscript to filter all Todos from a Markdown Wiki

export def td [
    --all
    --done
    --project(-p): string = ""
    --context(-c): string  = ""
    --retro(-r): string = ""
        ] {

   let is_not_retro = ($retro | is-empty)

    # The path to parse
    let PATH = (open ~/.config/tn.toml)
    let TODO_FILE_PATH = $PATH.path
    let TODO_FILES = ($TODO_FILE_PATH + "/**/*.md")
    let FILTER = (get_list_filter $all $done)

   if $is_not_retro {
       let todos = (filter_todos $TODO_FILES $FILTER)
       # Filter by project and context
       let tn = (get_project_context_filter $todos $project $context)
       # Parse it to a table
       let table = (parse_to_table $tn)
       let t_abs_path = (abs_path_2_file $table)
       let t_glyth = (replace_with_glyth $t_abs_path)
       $t_glyth
   } else {
       let r = (get_retrospective $retro $TODO_FILE_PATH $FILTER)
       $r
   }
}

export def get_list_filter [all, done] {

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

export def filter_todos [list, regex] {

    let out = (rg -tmd -n -e $regex $list)
    $out
}

# Get a List of all Work items filtered by +project and @context
export def get_project_context_filter [all_workitems, project, context] {

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

export def parse_to_table [list] {
   $list | lines| parse '{file}.md:{line}:{todo}] {item}' | move item --before file | move todo --before item
}

export def abs_path_2_file [list] {
    $list | update file {|row| $row.file | path basename}
}

# Get a retrospective list of all DONE things in git
# - [ ] Get the regex into the retrospective as well
export def get_retrospective [time path regex] {
    cd $path
    let time_rev = (($time | into datetime | into int) / 1000000000)
    # In the end we skip one, because we dont want the current commit in this
    # TODO I guess what we actually want are "those that have been deleted in the past"
    # So we should compare older commits to the current one and take some diff
    let revs = (run-external --redirect-stdout "git" "rev-list" "--all" $"--max-age=($time_rev)" 
               | lines | skip 1)
    let r = (run-external --redirect-stdout "git" "grep" "-E" "-e" $regex $revs 
            | lines | parse '{rev}:{file}:{todo_retro}' | select todo_retro | uniq)
    $r
}

# Open the file of the line specified with an editor
# Doesn't work yet, because the table is out of the scope. Maybe use a module for that.
def otd [table, line_number] {
    nvim ([$table.file.$line_number, ".md"] |str join)
    # nvim ([(td -c team).file.0, ".md"] |str join)  # This works on cli
}

# Replace the todo with some fancy stuff. The todo arrives like this "  - [x "
export def replace_with_glyth [list] {
    let t = ($list | each {|td| update todo {get_glyth (($td.todo | into string | parse '{x}[{item}').item.0)}})
    $t
}

export def get_glyth [key] {

    let glyths = ({ 
        " ": 😏
        "x": ✅
        "o": 😄
        "waiting": ⏳
        "team": 👥
        "date": ⏰
        "sprint": 🏃
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
