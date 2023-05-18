# Nuscript to filter all Todos from a Markdown Wiki

def td [
    --all
    --done
    --project(-p): string = ""
    --context(-c): string  = ""
    --retro(-r): string = ""
        ] {

   let is_not_retro = ($retro | is-empty)

   if $is_not_retro {
       # The path to parse
       let path = (open ~/.config/tn.toml)
       let todo_file_path = $path.path
       let todo_files = ($todo_file_path + "/**/*.md")

       let filter = get_list_filter $all $done

       let todos = filter_todos $todo_files $filter

       let tn = (get_project_context_filter $todos $project $context)

       let $t = (parse_to_table $tn)
       $t
   } else {
       get_retrospective $retro
   }

}

# Open the file of the line specified with an editor
# Doesn't work yet, because the table is out of the scope. Maybe use a module for that.
def otd [table, line_number] {
    nvim ([$table.file.$line_number, ".md"] |str join)
    # nvim ([(td -c team).file.0, ".md"] |str join)  # This works on cli
}

def parse_to_table [list] {
   $list | lines| parse '{file}.md:{line}:{item}' | move item --before file
}

# Get a List of all Work items filtered by +project and @context
def get_project_context_filter [all_workitems, project, context] {

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

def get_list_filter [all, done] {

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

def filter_todos [list, regex] {

    let out = (rg -tmd -n -e $regex $list)
    $out
}

# How to get a retrospective list of all DONE things in git
# Where time is the unix timestamp from where on the retrospective should be held
# - [ ] Sowohl Pfad wie den regex sind nicht sauber gelöst in get_retro
def get_retrospective [time] {
	let revs = (git rev-list --all --max-age=$time | lines)
	git grep -e '- \[X\]' $revs -- . | lines | parse '{rev}:{file}:{todo}' |
	select todo | uniq
}
