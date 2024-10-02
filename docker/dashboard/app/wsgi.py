import os

from nvflare.dashboard.application import init_app

app = init_app()

with app.app_context():

    from nvflare.dashboard.application.store import Store

    if Store.ready():

        resp = Store.get_project()
        if resp['status'].lower() != 'ok':
            print("Error: Could not get project from the Store")
            exit(1)
        project = resp['project']

        env_vars = {
            'server1': 'NVFL_SERVER1',
            'server2': 'NVFL_SERVER2',
            'ha_mode': 'NVFL_HA_MODE',
            'short_name': 'NVFL_PROJECT_SHORT_NAME',
            'title': 'NVFL_PROJECT_TITLE',
            'description': 'NVFL_PROJECT_DESCRIPTION',
            'app_location': 'NVFL_PROJECT_APP_LOCATION',
            'starting_date': 'NVFL_PROJECT_STARTING_DATE',
            'end_date': 'NVFL_PROJECT_END_DATE',
            'public': 'NVFL_PROJECT_PUBLIC',
            'frozen': 'NVFL_PROJECT_FROZEN'
        }

        project_conf = {}
        for var, env_var in env_vars.items():
            if env_var in os.environ.keys() and len(os.environ[env_var]) > 0:
                project_conf[var] = os.environ[env_var]
                if var in ['public', 'frozen', 'ha_mode']:
                    project_conf[var] = project_conf[var].lower() == 'true'

        if len(project_conf) > 0:
            project.update(project_conf)
            resp = Store.set_project(project)
            if resp['status'].lower() != 'ok':
                print('Error: Could not update project configuration')
                exit(1)
            else:
                print('Project configuration updated')