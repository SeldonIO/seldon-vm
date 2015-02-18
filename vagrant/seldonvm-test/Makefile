dummy:
	@echo dummy

status:
	vagrant global-status

list_boxes:
	vagrant box list

start_env:
	vagrant up

stop_env:
	vagrant halt

destroy_env:
	vagrant destroy -f

connect_ssh:
	vagrant ssh

remove_box:
	vagrant box remove seldonvm || echo ok
	vagrant box list

seldon_server_start:
	vagrant ssh -c '/home/core/seldon/dist/start-all'

seldon_server_stop:
	vagrant ssh -c '/home/core/seldon/dist/stop-all'

