# Nuscript to filter all Todos from a Markdown Wiki

# Usage

# tn => all open issues
# tn --all => all issues
# tn --done => all done issues
# tn -p CAD => only open issues from Project CAD
# tn --done -c team => only done issues from context team
# tn +CAD @team => Combinations allowed
# Project an context can be multiple like -p BIM -p CAD


# The path to parse
let path = (open ~/.config/tn.toml)
let todo_file_path = $path.path
let todo_files = ($todo_file_path + "/**/*.md")

def main [
    --all
    --done
    --project(-p): string = ""
    --context(-c): string  = ""
        ] {

   let filter = get_list_filter $all $done

   let todos = filter_todos $todo_files $filter

   let tn = (get_project_context_filter $todos $project $context)

   parse_to_table $tn

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
