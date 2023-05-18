# Nuscript to filter all Todos from a Markdown Wiki

# The path to parse
let todo_file_path = "C:\\Users\\patrick.joerg\\vimwiki\\**\\*.md"
let version_number = "0.0.1"

def main [
    --all
    --done
    --project(-p): string = "" # the project
    --context(-c): string  = "" # the context
    --version
    ] {

   if $version {

      $version_number

   } else {

      let all_workitems = get_all_workitems $all $done
      list  $all_workitems $project $context
      # get_project $project
   }
}

# Get a List of all Work items filtered by +project and @context
def list [all_workitems, project, context] {

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

# Get all work items, either all, or all DONE. Defaults to OPEN
def get_all_workitems [a, d] {

  if $a and $d {
     echo "you can't have --all and --done at the same time"
     exit
   }

  if $a {
     let list = (bat $todo_file_path | rg -e '((- \[ \])|(- \[X\])|(- \[o\]))')
     $list

  } else if $d {
     let list = (bat $todo_file_path | rg -e '((- \[X\])|(- \[o\]))')
     $list

  } else {
     let list = (bat $todo_file_path | rg -e '- \[ \]')
     $list
  }
}

def get_project [project] {

   let projects = (bat $todo_file_path | rg -e '^# ')
   $projects

}
