process download_git_and_references {
  //errorStrategy 'ignore' // Ignore errors
  tag "download"


output:
   path 'L1EM' , emit: L1EM_git ,  optional: true

script:

  """
  # Enable error handling but continue the script on failure
  set +e

  git clone https://github.com/FenyoLab/L1EM.git


  """

}
