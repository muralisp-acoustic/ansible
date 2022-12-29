
#!/bin/bash
if [ $# -eq 0 ]
then
	echo "Usage: ./run_ansible.sh <git_repo> <playbook_name> <optional_parameters>"
fi
#docker run -v "${PWD}":/work:ro -v ~/.ansible/roles:/root/.ansible/roles -v ~/.ssh:/root/.ssh:ro --rm spy86/ansible:latest ansible-playbook playbook.yml
git_repo=$1
git_repo_dir=`echo $git_repo | grep -o "/.*\.git" | sed -n 's/\///p'`
shift
playbook_name=$2
shift
cd /opt;git clone $git_repo
## See if git clone is successful
if [ $? -ne 0 ]
then
	cd /opt/$git_repo_dir
	ansible-vault decrypt config.yml --vault-password-file ~/.ansible_pass
	sudo docker run --env AWS_SHARED_CREDENTIALS_FILE=/work/.aws/credentials -v "${PWD}":/work:rw -v ~/.ansible/roles:/root/.ansible/roles -v ~/.ssh:/root/.ssh:ro --rm ansible_from_ubuntu:latest  ansible-playbook $playbook_name $*
	cp /opt/*.csv /media
	git clean -f -d
else
	echo "Error in cloning git repo"
fi


