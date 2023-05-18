# Nuscript to filter all Todos from a Markdown Wiki
# Highly opiniated :-)

# let todo_file_path = "~\\vimwiki\\**\\*.md"
let todo_file_path = "C:\\Users\\patrick.joerg\\vimwiki\\**\\*.md"

# def main [project: string, context: string] {
def main [
    --project(-p): string = "" # the project
    --context(-c): string  = "" # the context
    ] {

   list  $project $context
   # get_project $project

}

# Get a List of all Work items filtered by +project and @context
def list [project, context] {

  # Get all open work items
  let list = (bat $todo_file_path | rg -e '- \[ \]') 

  # Filter them by project or let the project_list be the list if there is no project given
  let project_list = (if (($project | str length) > 2 ) {
      $list | rg  -w $"\\+($project)"
  } else { $list })

  # Filter above filter by context or let the context_filter be the project_list if there is no context given
  let context_list = (if (($context | str length) > 2 ) {
      $project_list | rg  -w $"@($context)"
  } else { $project_list })

  # Print it out
  $context_list

}

def get_project [project] {

   let projects = (bat $todo_file_path | rg -e '^# ')
   $projects

}

# tn => all open issues
# tn all => all isues
# tn +CAD => only Project CAD
# tn @team => only context team
# tn +CAD @team => Combinations allowed

# Create a Link directly to the file and open it in $EDITOR

# Maybe later due dates
# Priority should be the rank within the file
# What has been closed lately? Retrospective
