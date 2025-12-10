

make_project:
	socrates_cli --project millisoc_tech -data ../ --flow AddNewProject

build_nic400:
	socrates_cli --project millisoc_tech -data ../ --flow build.configured.component configuredComponentName=nic400_millisoc_main

