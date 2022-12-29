
#!/bin/bash
if [ $# -eq 0 ]
then
	echo "Usage: ./run_ansible.sh <git_repo> <playbook_name> <optional_parameters>"
fi
#docker run -v "${PWD}":/work:ro -v ~/.ansible/roles:/root/.ansible/roles -v ~/.ssh:/root/.ssh:ro --rm spy86/ansible:latest ansible-playbook playbook.yml
git_repo=$1
git_repo_dir=`echo $git_repo | grep -o "/.*\.git" | sed -n -e 's/\///' -e 's/\.git//p'`
shift
playbook_name=$1
shift
git clone $git_repo
## See if git clone is successful
if [ $? -eq 0 ]
then
	cd $git_repo_dir
        cp ~/.ansible_pass .
	sudo docker run -v "${PWD}":/work:rw --rm ansible_from_ubuntu:latest ansible-vault decrypt /work/.aws/credentials --vault-password-file /work/.ansible_pass
	sudo docker run --env AWS_SHARED_CREDENTIALS_FILE=/work/.aws/credentials -v "${PWD}":/work:rw -v ~/.ansible/roles:/root/.ansible/roles -v ~/.ssh:/root/.ssh:ro --rm ansible_from_ubuntu:latest ansible-playbook $playbook_name $*
	cp *.csv ../
	git clean -f -d
else
	echo "Error in cloning git repo"
fi


