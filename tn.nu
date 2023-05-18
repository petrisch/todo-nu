# Nuscript to filter all Todos from a Markdown Wiki

# Usage

# tn => all open issues
# tn --all => all issues
# tn --done => all done issues
# tn -p CAD => only open issues from Project CAD
# tn --done -c team => only done issues from context team
# tn +CAD @team => Combinations allowed
# Project an context can be multiple like -p BIM -p CAD

# TODO
# - [ ] Support - [o] for half done indented lists
# - [ ] Currently only parses text. Do this the nushell way with structured text. 
# - [ ] Group the issues into the files where they came from
# - [ ] Take the project from the title of the last h1 upwards the file
# - [ ] Create a Link directly to the file and open it in $EDITOR
# - [ ] Maybe later due dates
# - [ ] Priority should be the rank within the file
# - [ ] What has been closed lately? Retrospective
# - [ ] toml config file for the path
# - [X] Support --all and --done switches 

# The path to parse
let todo_file_path = "C:\\Users\\patrick.joerg\\vimwiki\\**\\*.md"

def main [
    --all
    --done
    --project(-p): string = "" # the project
    --context(-c): string  = "" # the context
    ] {

   let all_workitems = get_all_workitems $all $done

   list  $all_workitems $project $context
   # get_project $project

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
     let list = (bat $todo_file_path | rg -e '((- \[ \])|(- \[X\]))')
     $list

  } else if $d {
     let list = (bat $todo_file_path | rg -e '- \[X\]')
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
