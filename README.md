Run it from anywhere, and it does a mysqldump and ZIP archive. You tell it where to put those. Before doing the backup it checks free space and displays directory information and size, and then the user confirms, to execute the backup. Just tell it the directory of the site, and it checks the wp-config to get the db name, user and pass. 

## Usage 

It takes 3 arguments:

- directory of site
- directory to place backup files
- name for backup files

## Example

    sh wp_back-upper.sh my_site_dir my_backups_dir the_name_for_the_backup_files 