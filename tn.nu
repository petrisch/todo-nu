# Nuscript to filter all Todos from a Markdown Wiki

# The path to parse
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

      if ($env.LOCALAPPDATA | path exists) {
          let config = $env.LOCALAPPDATA + "/todo-nu/tn.toml"
          let todo_file_path = (open $config).path
          # $todo_file_path

          let all_workitems = get_all_workitems $all $done $todo_file_path
          list  $all_workitems $project $context 
          # get_project $project

      } else { "No config path or file found in local app folder" }
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
def get_all_workitems [a, d, path] {

  if $a and $d {
     echo "you can't have --all and --done at the same time"
     exit
   }

  if $a {
     let list = (bat $path | rg -e '((- \[ \])|(- \[X\])|(- \[o\]))')
     $list

  } else if $d {
     let list = (bat $path | rg -e '((- \[X\])|(- \[o\]))')
     $list

  } else {
     let list = (bat $path | rg -e '- \[ \]')
     $list
  }
}

def get_project [project, path] {

   let projects = (bat $path | rg -e '^# ')
   $projects

}
