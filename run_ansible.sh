
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
version=`cat settings.ini |grep ansible_version | awk -F':' '{print $2}'`
git clone $git_repo
## See if git clone is successful
if [ $? -eq 0 ]
then
	cd $git_repo_dir
        cp ~/.ansible_pass .
	sudo docker run -v "${PWD}":/work:rw --rm public.ecr.aws/f4q9n3z9/ansible:$version ansible-vault decrypt /work/.aws/credentials --vault-password-file /work/.ansible_pass
	sudo docker run --env AWS_SHARED_CREDENTIALS_FILE=/work/.aws/credentials -v "${PWD}":/work:rw -v ~/.ansible/roles:/root/.ansible/roles -v ~/.ssh:/root/.ssh:ro --rm public.ecr.aws/f4q9n3z9/ansible:$version  ansible-playbook $playbook_name $*
	sudo docker run -v "${PWD}":/work:rw --rm public.ecr.aws/f4q9n3z9/ansible:$version ansible-vault encrypt /work/.aws/credentials --vault-password-file /work/.ansible_pass
	cp *.csv ../
	git clean -f -d
else
	echo "Error in cloning git repo"
fi


