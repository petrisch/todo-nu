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

   if $is_not_retro {
       let filter = (get_list_filter $all $done)
       let todos = (filter_todos $TODO_FILES $filter)
       let tn = (get_project_context_filter $todos $project $context)

       let t = (parse_to_table $tn)
       $t
   } else {
       let r = (get_retrospective $retro $TODO_FILE_PATH)
       $r
   }
}

# Open the file of the line specified with an editor
# Doesn't work yet, because the table is out of the scope. Maybe use a module for that.
def otd [table, line_number] {
    nvim ([$table.file.$line_number, ".md"] |str join)
    # nvim ([(td -c team).file.0, ".md"] |str join)  # This works on cli
}

export def parse_to_table [list] {
   $list | lines| parse '{file}.md:{line}:{item}' | move item --before file
   # $list
   # $list | lines| parse -r '(?P<file>\w+).md:-[{state}] {line}:{item}' | move item --before file
}

# def parse_depth [depth] {
    
# }

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

# Get a retrospective list of all DONE things in git
# - [ ] Get the regex into the retrospective as well
export def get_retrospective [time path] {
    cd $path
    # On any unix system we can assume a "date" command in the path.
    # Since we need git for this anyway, gitforwindows comes with the date command as well.
    # However usually this is not in the path and it would be confusing with the builtin date
    # if it was. So to get this to work we copy git"date" as unix_date_on_windows to path.
    # This needs also msys-2.0.dll, msys-iconv-2.dll and msys-intl-8.dll in path.
    # Would be nice if we could do this with the builtin nu"date".
    let time_rev = if ($nu.os-info.family == 'windows') {
	    run-external --redirect-stdout "unix_date_on_windows" "-d" ($time) "+%s" | into int
    } else { 
	    run-external --redirect-stdout "date" "-d" ($time) "+%s" | into int
	}
    let revs = (run-external --redirect-stdout "git" "rev-list" "--all" $"--max-age=($time_rev)" 
               | lines)
    let r = (run-external --redirect-stdout "git" "grep" "-e" '- \[x\]' $revs 
            | lines | parse '{rev}:{file}:{todo_retro}' | select todo_retro | uniq)
    $r
}
